import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/collection_item.dart';
import '../models/collection_query_state.dart';
import '../models/collection_room.dart';
import '../services/collection_query_service.dart';
import '../services/room_reflection_service.dart';

final collectionQueryServiceProvider = Provider<CollectionQueryService>((ref) {
  return CollectionQueryService();
});

final roomReflectionServiceProvider = Provider<RoomReflectionService>((ref) {
  return RoomReflectionService();
});

final categoriesProvider = FutureProvider<List<CategoryOption>>((ref) async {
  return ref.watch(collectionQueryServiceProvider).fetchCategories();
});

final allTagsProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(collectionQueryServiceProvider).fetchAllTags();
});

final roomsProvider = FutureProvider<List<CollectionRoomSummary>>((ref) async {
  return ref.watch(collectionQueryServiceProvider).fetchRooms();
});

final roomDetailProvider =
    FutureProvider.family<CollectionRoomDetail, int>((ref, roomId) async {
  return ref.watch(collectionQueryServiceProvider).fetchRoomById(roomId);
});

/// Design-time fallback when backend is offline (Room / Share / Profile).
const demoUserStatsFallback = UserStats(
  totalCollections: 24,
  categoryCount: 4,
  publicCollections: 8,
  recentCollections: [],
);

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final service = ref.read(collectionQueryServiceProvider);
  if (!await service.checkHealth()) {
    throw ApiException(
      code: 'BACKEND_OFFLINE',
      message:
          'Cannot reach $apiBaseUrl. Start backend: cd backend && npm run dev',
    );
  }
  return service.fetchUserStats(demoUserId);
});

/// GET /api/health — backend 与 SQLite 是否可用
final backendReachableProvider = FutureProvider<bool>((ref) async {
  return ref.read(collectionQueryServiceProvider).checkHealth();
});

class CollectionListState {
  const CollectionListState({
    this.query = CollectionQueryState.initial,
    this.items = const [],
    this.total = 0,
    this.loading = false,
    this.loadingMore = false,
    this.refreshing = false,
    this.error,
    this.wallDisplayPage = 1,
  });

  final CollectionQueryState query;
  final List<CollectionItem> items;
  final int total;
  final bool loading;
  final bool loadingMore;
  final bool refreshing;
  final String? error;
  /// UI page for collection wall (6 cards per page).
  final int wallDisplayPage;

  bool get hasMore => items.length < total;

  int get totalWallPages {
    if (total <= 0) return 1;
    final pages = (total / query.pageSize).ceil();
    return pages < 1 ? 1 : pages;
  }

  bool get needsWallPagination => total > query.pageSize;

  /// At most [query.pageSize] items for the current wall page.
  List<CollectionItem> get wallVisibleItems {
    if (!needsWallPagination) return items;
    final start = (wallDisplayPage - 1) * query.pageSize;
    if (start >= items.length) return const [];
    final end = start + query.pageSize;
    return items.sublist(start, end > items.length ? items.length : end);
  }
}

class CollectionListNotifier extends StateNotifier<CollectionListState> {
  CollectionListNotifier(this._service) : super(const CollectionListState());

  final CollectionQueryService _service;
  bool _busy = false;

  Future<void> _load({required bool append}) async {
    if (_busy) return;
    if (append && (!state.hasMore || state.loadingMore)) return;
    _busy = true;
    state = state.copyWith(
      loading: !append && !state.refreshing,
      loadingMore: append,
      clearError: true,
    );
    try {
      final result = await _service.fetchCollections(state.query);
      state = state.copyWith(
        items: append ? [...state.items, ...result.items] : result.items,
        total: result.total,
        loading: false,
        loadingMore: false,
        refreshing: false,
        error: null,
        wallDisplayPage: append ? state.wallDisplayPage : 1,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        loading: false,
        loadingMore: false,
        refreshing: false,
        error: e.message,
        items: append ? state.items : [],
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        loadingMore: false,
        refreshing: false,
        error: e.toString(),
        items: append ? state.items : [],
      );
    } finally {
      _busy = false;
    }
  }

  void setQuery(CollectionQueryState query) {
    final filtersChanged = query.keyword != state.query.keyword ||
        query.category != state.query.category ||
        query.tag != state.query.tag ||
        query.visibility != state.query.visibility ||
        query.sortBy != state.query.sortBy;
    final next = filtersChanged && query.page == state.query.page
        ? query.copyWith(page: 1)
        : query;
    state = state.copyWith(query: next);
    _load(append: next.page > 1);
  }

  void updateFilters({
    String? keyword,
    String? category,
    bool clearCategory = false,
    String? tag,
    bool clearTag = false,
    int? year,
    bool clearYear = false,
    int? month,
    bool clearMonth = false,
    SortOption? sortBy,
  }) {
    final next = state.query.copyWith(
      keyword: keyword,
      category: category,
      clearCategory: clearCategory,
      tag: tag,
      clearTag: clearTag,
      year: year,
      clearYear: clearYear,
      month: month,
      clearMonth: clearMonth,
      sortBy: sortBy,
      page: 1,
    );
    state = state.copyWith(query: next);
    _load(append: false);
  }

  void clearAllFilters() {
    final next = CollectionQueryState.initial.copyWith(
      pageSize: state.query.pageSize,
    );
    state = state.copyWith(query: next, wallDisplayPage: 1);
    _load(append: false);
  }

  Future<void> goToWallPage(int page) async {
    if (page < 1 || page > state.totalWallPages) return;
    final needed = page * state.query.pageSize;
    var guard = 0;
    while (state.items.length < needed && state.hasMore && guard < 20) {
      guard++;
      await loadMore();
    }
    state = state.copyWith(wallDisplayPage: page);
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.loading ||
        state.loadingMore ||
        state.refreshing ||
        _busy) {
      return;
    }
    state = state.copyWith(
      query: state.query.copyWith(page: state.query.page + 1),
    );
    await _load(append: true);
  }

  /// 下拉刷新：保留 keyword / category / tag / sort，从第 1 页重载。
  Future<void> refresh() async {
    if (state.refreshing) return;
    state = state.copyWith(
      refreshing: true,
      query: state.query.copyWith(page: 1),
      clearError: true,
    );
    await _load(append: false);
  }
}

extension _Copy on CollectionListState {
  CollectionListState copyWith({
    CollectionQueryState? query,
    List<CollectionItem>? items,
    int? total,
    bool? loading,
    bool? loadingMore,
    bool? refreshing,
    String? error,
    int? wallDisplayPage,
    bool clearError = false,
  }) {
    return CollectionListState(
      query: query ?? this.query,
      items: items ?? this.items,
      total: total ?? this.total,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      refreshing: refreshing ?? this.refreshing,
      error: clearError ? null : (error ?? this.error),
      wallDisplayPage: wallDisplayPage ?? this.wallDisplayPage,
    );
  }
}

/// Profile-specific collection provider — always fetches all collections
/// across pages, independent of Gallery filter state.
final profileCollectionsProvider =
    FutureProvider<List<CollectionItem>>((ref) async {
  return ref.watch(collectionQueryServiceProvider).fetchAllCollections();
});

/// Backward-compatible alias used across gallery/profile widgets.
final allCollectionsProvider = profileCollectionsProvider;

final collectionListProvider =
    StateNotifierProvider<CollectionListNotifier, CollectionListState>((ref) {
  final notifier =
      CollectionListNotifier(ref.watch(collectionQueryServiceProvider));
  Future.microtask(() => notifier.setQuery(CollectionQueryState.initial));
  return notifier;
});
