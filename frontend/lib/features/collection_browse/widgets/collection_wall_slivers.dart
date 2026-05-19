import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/collectory_theme.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../services/collection_query_service.dart';
import 'category_filter_tabs.dart';
import 'collectory_handoff_header.dart';
import 'collection_grid.dart';
import 'collection_search_bar.dart';
import 'collection_sort_toggle.dart';
import 'empty_collection_state.dart';
import 'loading_skeleton.dart';
import 'tag_filter_sheet.dart';

/// Member 3 收藏墙：搜索 / 筛选 / 分页 / 刷新（嵌入 Gallery Tab）
class CollectionWallSlivers extends ConsumerStatefulWidget {
  const CollectionWallSlivers({
    super.key,
    required this.scrollController,
    this.showWallHeader = true,
  });

  final ScrollController scrollController;
  final bool showWallHeader;

  @override
  ConsumerState<CollectionWallSlivers> createState() =>
      _CollectionWallSliversState();
}

class _CollectionWallSliversState extends ConsumerState<CollectionWallSlivers> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final controller = widget.scrollController;
    if (!controller.hasClients) return;
    final pos = controller.position;
    if (!pos.hasContentDimensions) return;

    final listState = ref.read(collectionListProvider);
    if (listState.needsWallPagination) return;

    if (!listState.hasMore ||
        listState.loading ||
        listState.loadingMore ||
        listState.refreshing) {
      return;
    }

    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(collectionListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(collectionListProvider.notifier).updateFilters(keyword: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(collectionListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final tagsAsync = ref.watch(allTagsProvider);
    final pad = CollectoryColors.screenPadding;

    final categoryNames = categoriesAsync.when(
      data: (cats) => {for (final c in cats) c.id: c.name},
      loading: () => <String, String>{},
      error: (_, __) => <String, String>{},
    );

    final categoryTabs = [
      const CategoryTab(id: null, name: 'All'),
      ...?categoriesAsync.when(
        data: (cats) =>
            cats.map((c) => CategoryTab(id: c.id, name: c.name)).toList(),
        loading: () => null,
        error: (_, __) => null,
      ),
    ];

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showWallHeader) ...[
                  Text(
                    'YOUR COLLECTIONS',
                    style: CollectoryHandoffHeader.metaLabel(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Collection wall',
                    style: CollectoryHandoffHeader.sectionTitle(),
                  ),
                  const SizedBox(height: 8),
                ],
                ref.watch(backendReachableProvider).when(
                  data: (ok) {
                    if (ok) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'API offline — start backend at $apiBaseUrl',
                        style: CollectoryHandoffHeader.bodySecondary().copyWith(
                          fontSize: 12,
                          color: const Color(0xFF8B3A2A),
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                CollectionSearchBar(
                  controller: _searchController,
                  searching:
                      listState.loading && listState.query.keyword.isNotEmpty,
                  onChanged: _onSearchChanged,
                  onClear: () => ref
                      .read(collectionListProvider.notifier)
                      .updateFilters(keyword: ''),
                ),
                const SizedBox(height: 16),
                CategoryFilterTabs(
                  tabs: categoryTabs,
                  activeId: listState.query.category,
                  onSelect: (id) {
                    ref.read(collectionListProvider.notifier).updateFilters(
                          category: id,
                          clearCategory: id == null,
                        );
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: const TextStyle(fontSize: 11),
                      side: const BorderSide(color: CollectoryColors.borderLight),
                    ),
                    onPressed: () {
                      tagsAsync.whenData((tags) {
                        showTagFilterSheet(
                          context: context,
                          tags: tags,
                          selectedTag: listState.query.tag,
                          onSelect: (tag) => ref
                              .read(collectionListProvider.notifier)
                              .updateFilters(
                                tag: tag,
                                clearTag: tag == null,
                              ),
                        );
                      });
                    },
                    child: Text(
                      listState.query.tag != null
                          ? 'Tag: ${listState.query.tag}'
                          : 'Tags',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CollectionSortToggle(
                  value: listState.query.sortBy,
                  onChanged: (v) => ref
                      .read(collectionListProvider.notifier)
                      .updateFilters(sortBy: v),
                ),
                if (listState.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE8E4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8C4BC)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(listState.error!)),
                        TextButton(
                          onPressed: () => ref
                              .read(collectionListProvider.notifier)
                              .refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  '${listState.total} exhibits',
                  style: CollectoryHandoffHeader.bodySecondary(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (listState.loading && listState.items.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: CollectoryColors.screenPadding,
              ),
              child: LoadingSkeleton(),
            ),
          )
        else if (listState.items.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: EmptyCollectionState(
                actionLabel: 'Clear filters',
                onAction: () {
                  _searchController.clear();
                  ref.read(collectionListProvider.notifier).updateFilters(
                        keyword: '',
                        clearCategory: true,
                        clearTag: true,
                      );
                },
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CollectionGrid(
                    items: listState.wallVisibleItems,
                    categoryNames: categoryNames,
                    onItemTap: (item) => openItemDetail(ref, item.id),
                  ),
                  if (listState.needsWallPagination) ...[
                    const SizedBox(height: 14),
                    _WallPaginationBar(
                      currentPage: listState.wallDisplayPage,
                      totalPages: listState.totalWallPages,
                      totalItems: listState.total,
                      pageSize: listState.query.pageSize,
                      loading: listState.loadingMore,
                      onPrev: listState.wallDisplayPage > 1
                          ? () => ref
                              .read(collectionListProvider.notifier)
                              .goToWallPage(listState.wallDisplayPage - 1)
                          : null,
                      onNext: listState.wallDisplayPage < listState.totalWallPages
                          ? () => ref
                              .read(collectionListProvider.notifier)
                              .goToWallPage(listState.wallDisplayPage + 1)
                          : null,
                    ),
                  ] else if (listState.hasMore && listState.items.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Showing ${listState.items.length} of ${listState.total}',
                      textAlign: TextAlign.center,
                      style: CollectoryHandoffHeader.bodySecondary().copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        if (listState.loadingMore && !listState.needsWallPagination)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Loading more…',
                      style: TextStyle(color: CollectoryColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (!listState.hasMore &&
            listState.items.isNotEmpty &&
            !listState.needsWallPagination)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Center(
                child: Text(
                  '— End of collection · ${listState.items.length} exhibits —',
                  style: CollectoryHandoffHeader.bodySecondary().copyWith(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WallPaginationBar extends StatelessWidget {
  const _WallPaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.loading,
    required this.onPrev,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool loading;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final start = (currentPage - 1) * pageSize + 1;
    final end = (currentPage * pageSize).clamp(0, totalItems);

    return Column(
      children: [
        Text(
          'Page $currentPage of $totalPages · $start–$end of $totalItems',
          textAlign: TextAlign.center,
          style: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 12),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: loading ? null : onPrev,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(88, 36),
                side: const BorderSide(color: CollectoryColors.borderLight),
              ),
              child: const Text('Previous'),
            ),
            const SizedBox(width: 12),
            if (loading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              OutlinedButton(
                onPressed: onNext,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(88, 36),
                  side: const BorderSide(color: CollectoryColors.borderLight),
                ),
                child: const Text('Next'),
              ),
          ],
        ),
      ],
    );
  }
}
