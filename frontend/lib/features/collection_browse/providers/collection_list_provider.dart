import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/collection_item.dart';
import '../models/collection_query_state.dart';
import '../services/collection_query_service.dart';

final collectionQueryServiceProvider = Provider<CollectionQueryService>((ref) {
  return CollectionQueryService();
});

final categoriesProvider = FutureProvider<List<CategoryOption>>((ref) async {
  return ref.watch(collectionQueryServiceProvider).fetchCategories();
});

final allTagsProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(collectionQueryServiceProvider).fetchAllTags();
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
    final pages = (total / CollectionQueryState.wallPageSize).ceil();
    return pages < 1 ? 1 : pages;
  }

  bool get needsWallPagination => total > CollectionQueryState.wallPageSize;

  /// At most [CollectionQueryState.wallPageSize] items for the current wall page.
  List<CollectionItem> get wallVisibleItems {
    if (!needsWallPagination) return items;
    final pageSize = CollectionQueryState.wallPageSize;
    final start = (wallDisplayPage - 1) * pageSize;
    if (start >= items.length) return const [];
    final end = start + pageSize;
    return items.sublist(start, end > items.length ? items.length : end);
  }
}

class CollectionListNotifier extends StateNotifier<CollectionListState> {
  CollectionListNotifier(this._service) : super(const CollectionListState());

  final CollectionQueryService _service;
  bool _busy = false;

  Future<void> _waitForIdle() async {
    for (var i = 0; _busy && i < 200; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  }

  Future<void> _load({required bool append}) async {
    await _waitForIdle();
    if (_busy) {
      state = state.copyWith(loading: false, loadingMore: false, refreshing: false);
      return;
    }
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
        query.filterYear != state.query.filterYear ||
        query.filterMonth != state.query.filterMonth ||
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
    int? filterYear,
    int? filterMonth,
    bool clearYear = false,
    bool clearMonth = false,
    SortOption? sortBy,
  }) {
    final next = state.query.copyWith(
      keyword: keyword,
      category: category,
      clearCategory: clearCategory,
      tag: tag,
      clearTag: clearTag,
      filterYear: filterYear,
      filterMonth: filterMonth,
      clearYear: clearYear,
      clearMonth: clearMonth,
      sortBy: sortBy,
      page: 1,
      pageSize: CollectionQueryState.wallPageSize,
    );
    state = state.copyWith(query: next, wallDisplayPage: 1);
    _load(append: false);
  }

  /// Room Open wall → Gallery wall 并预选年月
  Future<void> applyWallDateFilter({
    required int year,
    required int month,
  }) async {
    state = state.copyWith(
      query: CollectionQueryState.initial.copyWith(
        filterYear: year,
        filterMonth: month,
      ),
      wallDisplayPage: 1,
      clearError: true,
    );
    await _load(append: false);
  }

  Future<void> goToWallPage(int page) async {
    if (page < 1 || page > state.totalWallPages) return;
    final needed = page * CollectionQueryState.wallPageSize;
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

  /// Collection wall — 清空年月 / 搜索 / 分类 / 标签等筛选
  Future<void> clearAllWallFilters() => resetWallFilters();

  /// Leave Gallery tab: reset wall filters (Home/Profile use [collectionArchiveProvider]).
  Future<void> resetWallFilters() async {
    state = state.copyWith(
      query: CollectionQueryState.initial,
      wallDisplayPage: 1,
      clearError: true,
    );
    await _load(append: false);
  }

  /// Home/Profile room → Open wall：先批量拉取，再在 wall 上以每页 6 条分页展示。
  Future<void> loadRoomArchiveWall() async {
    state = state.copyWith(
      query: CollectionQueryState.initial.copyWith(pageSize: 100, page: 1),
      wallDisplayPage: 1,
      clearError: true,
    );
    await _load(append: false);
    var guard = 0;
    while (state.hasMore && guard < 15) {
      guard++;
      state = state.copyWith(
        query: state.query.copyWith(page: state.query.page + 1),
      );
      await _load(append: true);
    }
    state = state.copyWith(
      query: CollectionQueryState.initial.copyWith(page: 1),
      wallDisplayPage: 1,
    );
  }

  /// 下拉刷新：保留 keyword / category / tag / sort，从第 1 页重载。
  Future<void> refresh() async {
    state = state.copyWith(
      refreshing: true,
      query: state.query.copyWith(page: 1),
      clearError: true,
    );
    try {
      await _load(append: false);
    } finally {
      if (state.refreshing) {
        state = state.copyWith(refreshing: false, loading: false);
      }
    }
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

final collectionListProvider =
    StateNotifierProvider<CollectionListNotifier, CollectionListState>((ref) {
  return CollectionListNotifier(ref.watch(collectionQueryServiceProvider));
});

/// Unfiltered catalog for Home / Profile / Room / Gallery header (not wall filters).
class CollectionArchiveNotifier extends StateNotifier<CollectionListState> {
  CollectionArchiveNotifier(this._service) : super(const CollectionListState());

  final CollectionQueryService _service;
  bool _busy = false;

  static const _archiveQuery = CollectionQueryState(
    page: 1,
    pageSize: 100,
  );

  Future<void> _waitForIdle() async {
    for (var i = 0; _busy && i < 200; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  }

  Future<void> _load() async {
    await _waitForIdle();
    if (_busy) {
      state = state.copyWith(loading: false, refreshing: false);
      return;
    }
    _busy = true;
    state = state.copyWith(
      loading: !state.refreshing && state.items.isEmpty,
      clearError: true,
    );
    try {
      final result = await _service.fetchCollections(_archiveQuery);
      state = state.copyWith(
        query: _archiveQuery,
        items: result.items,
        total: result.total,
        loading: false,
        refreshing: false,
        error: null,
        wallDisplayPage: 1,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        loading: false,
        refreshing: false,
        error: e.message,
        items: [],
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        refreshing: false,
        error: e.toString(),
        items: [],
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(refreshing: true, clearError: true);
    try {
      await _load();
    } finally {
      if (state.refreshing) {
        state = state.copyWith(refreshing: false, loading: false);
      }
    }
  }
}

final collectionArchiveProvider =
    StateNotifierProvider<CollectionArchiveNotifier, CollectionListState>((ref) {
  return CollectionArchiveNotifier(ref.watch(collectionQueryServiceProvider));
});

/// Home + Profile exhibit source — always unfiltered; never [collectionListProvider].
final collectionMuseumCatalogProvider = Provider<CollectionListState>((ref) {
  return ref.watch(collectionArchiveProvider);
});

/// Reload wall + archive after create / update / delete.
Future<void> refreshCollectionCatalog({
  required CollectionArchiveNotifier archive,
  required CollectionListNotifier wall,
}) async {
  await Future.wait([
    archive.refresh(),
    wall.refresh(),
  ]);
}
