import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_item.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../widgets/category_filter_tabs.dart';
import '../widgets/collectory_handoff_header.dart';
import '../widgets/collection_card.dart';
import '../widgets/collection_grid.dart';
import '../widgets/empty_collection_state.dart';

/// 阶段五 V3.1：公开浏览（最近公开 / 按类别 + 社交占位）
class PublicCollectionsPage extends ConsumerStatefulWidget {
  const PublicCollectionsPage({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<PublicCollectionsPage> createState() =>
      _PublicCollectionsPageState();
}

class _PublicCollectionsPageState extends ConsumerState<PublicCollectionsPage> {
  String? _categoryId;

  @override
  Widget build(BuildContext context) {
    final future = ref.watch(_publicCollectionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: future.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: EdgeInsets.all(CollectoryColors.screenPadding),
            child: Text('$e'),
          ),
          data: (items) {
            final categoryNames = categoriesAsync.when(
              data: (cats) => {for (final c in cats) c.id: c.name},
              loading: () => <String, String>{},
              error: (_, __) => <String, String>{},
            );

            final categoryTabs = [
              const CategoryTab(id: null, name: 'All'),
              ...?categoriesAsync.when(
                data: (cats) => cats
                    .where((c) => items.any((i) => i.category == c.id))
                    .map((c) => CategoryTab(id: c.id, name: c.name))
                    .toList(),
                loading: () => null,
                error: (_, __) => null,
              ),
            ];

            final recent = _sortRecentPublic(items);
            final filtered = _categoryId == null
                ? items
                : items.where((i) => i.category == _categoryId).toList();

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(_publicCollectionsProvider);
              },
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  CollectoryColors.screenPadding,
                  24,
                  CollectoryColors.screenPadding,
                  80,
                ),
                children: [
                  if (widget.onClose != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                      ),
                    ),
                  const CollectoryHandoffHeader(
                    contextTitle: 'Public browse',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PUBLIC EXHIBITS',
                    style: CollectoryHandoffHeader.metaLabel(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Public collections',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CollectoryHandoffHeader.pageTitle().copyWith(
                      fontSize: 24,
                      height: 1.1,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (items.isEmpty)
                    const EmptyCollectionState(
                      title: '暂无公开收藏',
                      description: '将收藏设为 public 后会出现在此列表。',
                    )
                  else ...[
                    if (recent.isNotEmpty) ...[
                      _SectionTitle('Recent public'),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < recent.length; i++) ...[
                                if (i > 0) const SizedBox(width: 12),
                                SizedBox(
                                  width: 168,
                                  child: CollectionCard(
                                    item: recent[i],
                                    categoryLabel: recent[i].category != null
                                        ? categoryNames[recent[i].category!]
                                        : null,
                                    onTap: () => openPublicItemDetail(
                                      ref,
                                      recent[i].id,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _SectionTitle('Browse by category'),
                    const SizedBox(height: 10),
                    if (categoryTabs.length > 1)
                      CategoryFilterTabs(
                        tabs: categoryTabs,
                        activeId: _categoryId,
                        onSelect: (id) => setState(() => _categoryId = id),
                      ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      Text(
                        'No public exhibits in this category.',
                        style: CollectoryHandoffHeader.bodySecondary(),
                      )
                    else
                      CollectionGrid(
                        items: filtered,
                        categoryNames: categoryNames,
                        onItemTap: (item) =>
                            openPublicItemDetail(ref, item.id),
                      ),
                  ],
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _SocialPlaceholderButton(label: '点赞'),
                      _SocialPlaceholderButton(label: '评论'),
                      _SocialPlaceholderButton(label: '收藏'),
                      _SocialPlaceholderButton(label: '关注'),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: CollectoryColors.textPrimary,
      ),
    );
  }
}

class _SocialPlaceholderButton extends StatelessWidget {
  const _SocialPlaceholderButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: null,
      child: Text(label),
    );
  }
}

List<CollectionItem> _sortRecentPublic(List<CollectionItem> items) {
  final copy = [...items];
  copy.sort((a, b) {
    final da = a.dateAcquired ?? '';
    final db = b.dateAcquired ?? '';
    return db.compareTo(da);
  });
  return copy.take(5).toList();
}

final _publicCollectionsProvider = FutureProvider<List<CollectionItem>>((ref) {
  return ref.read(collectionQueryServiceProvider).fetchPublicCollections();
});
