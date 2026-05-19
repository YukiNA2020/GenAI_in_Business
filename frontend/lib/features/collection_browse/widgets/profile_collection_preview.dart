import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_item.dart';
import '../providers/app_navigation_provider.dart';
import '../utils/collectory_room_catalog.dart';
import '../providers/collection_list_provider.dart';
import '../providers/member3_ui_settings_provider.dart';
import '../services/collection_query_service.dart';
import 'collectory_handoff_header.dart';
import 'collection_card.dart';
import 'collection_grid.dart';
import 'design/collectory_favorite_tags.dart';
import 'design/collectory_pill_toggle.dart';
import 'design/collectory_top_bar.dart';

/// Profile tab: stats API + recent [CollectionCard] + category preview (Member 3 phase 4).
class ProfileCollectionPreview extends ConsumerStatefulWidget {
  const ProfileCollectionPreview({super.key});

  @override
  ConsumerState<ProfileCollectionPreview> createState() =>
      _ProfileCollectionPreviewState();
}

class _ProfileCollectionPreviewState
    extends ConsumerState<ProfileCollectionPreview> {
  String _activeFavoriteTag = CollectoryFavoriteTags.labels.first;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(userStatsProvider);
    final list = ref.watch(collectionListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final publicPreview = ref.watch(profilePublicPreviewProvider);
    final pad = CollectoryColors.screenPadding;

    final categoryNames = categoriesAsync.when(
      data: (cats) => {for (final c in cats) c.id: c.name},
      loading: () => <String, String>{},
      error: (_, __) => <String, String>{},
    );

    return statsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CollectoryColors.textLabel),
      ),
      error: (_, __) => _buildScrollBody(
        ref: ref,
        pad: pad,
        stats: demoUserStatsFallback,
        allItems: list.items,
        categoryNames: categoryNames,
        publicPreview: publicPreview,
      ),
      data: (stats) => _buildScrollBody(
        ref: ref,
        pad: pad,
        stats: stats,
        allItems: list.items,
        categoryNames: categoryNames,
        publicPreview: publicPreview,
      ),
    );
  }

  Widget _buildScrollBody({
    required WidgetRef ref,
    required double pad,
    required UserStats stats,
    required List<CollectionItem> allItems,
    required Map<String, String> categoryNames,
    required bool publicPreview,
  }) {
    final exhibits = stats.totalCollections.toString();
    final rooms = stats.categoryCount.toString().padLeft(2, '0');
    final publicCount = stats.publicCollections.toString();
    final lastAdded = _resolveLastAdded(allItems, stats.recentCollections);

    var recent = _resolveRecentExhibits(stats, allItems);
    if (publicPreview) {
      recent = recent.where((e) => e.visibility == 'public').toList();
    }
    final favoriteCategoryId =
        CollectoryFavoriteTags.categorySlugForTag(_activeFavoriteTag);
    final favoriteItems = _filterProfileItems(
      allItems,
      publicOnly: publicPreview,
      categoryId: favoriteCategoryId,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 10, pad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CollectoryTopBar(
            contextTitle: 'Profile',
            trailing: Material(
              color: CollectoryColors.btnPrimaryBg,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => openShareRoom(ref),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Icon(
                    Icons.settings,
                    size: 17,
                    color: CollectoryColors.btnPrimaryText,
                  ),
                ),
              ),
            ),
          ),
          const _HairlineDivider(),
          const SizedBox(height: 14),
          Text('PRIVATE MUSEUM', style: CollectoryHandoffHeader.metaLabel()),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProfileAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tong',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: CollectoryColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Monthly rooms, concert memories, minerals, and small personal archives.',
                      style: CollectoryHandoffHeader.bodySecondary()
                          .copyWith(fontSize: 13, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const _HairlineDivider(margin: EdgeInsets.symmetric(vertical: 14)),
          Row(
            children: [
              Expanded(child: _StatColumn(value: exhibits, label: 'Exhibits')),
              Expanded(child: _StatColumn(value: rooms, label: 'Rooms')),
              Expanded(child: _StatColumn(value: publicCount, label: 'Public')),
              Expanded(child: _LastAddedStatColumn(display: lastAdded)),
            ],
          ),
          const SizedBox(height: 16),
          _VisibilityCard(
            publicPreview: publicPreview,
            onToggle: () {
              ref.read(profilePublicPreviewProvider.notifier).state =
                  !publicPreview;
            },
            onOpenSettings: () => openShareRoom(ref),
          ),
          const SizedBox(height: 20),
          Text(
            'Recent exhibits',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CollectoryColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No recent exhibits yet.',
                style: CollectoryHandoffHeader.bodySecondary(),
              ),
            )
          else
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
                          onTap: () => openItemDetail(ref, recent[i].id),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Favorite tags',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CollectoryColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          CollectoryFavoriteTagRow(
            activeTag: _activeFavoriteTag,
            onTagTap: (tag) => setState(() => _activeFavoriteTag = tag),
          ),
          const SizedBox(height: 12),
          if (favoriteItems.isEmpty)
            Text(
              publicPreview
                  ? 'No public exhibits in this category.'
                  : 'No exhibits in this category.',
              style: CollectoryHandoffHeader.bodySecondary(),
            )
          else
            CollectionGrid(
              items: favoriteItems,
              categoryNames: categoryNames,
              onItemTap: (item) => openItemDetail(ref, item.id),
            ),
          const SizedBox(height: 20),
          Text(
            'Collection rooms',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CollectoryColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < CollectoryRoomCatalog.rooms.length; i++) ...[
                  if (i > 0) const SizedBox(width: 7),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final spec = CollectoryRoomCatalog.rooms[i];
                        return _RoomPreviewCard(
                          room: spec.roomCode,
                          title: spec.monthYear,
                          color: spec.cardColor,
                          preview: spec.isPreview,
                          onTap: () => openCollectionRoom(ref, roomIndex: i),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Settings',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CollectoryColors.textPrimary,
            ),
          ),
          const _HairlineDivider(),
          InkWell(
            onTap: () => openShareRoom(ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Account and privacy',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: CollectoryColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '→',
                    style: CollectoryHandoffHeader.metaLabel().copyWith(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _HairlineDivider(),
        ],
      ),
    );
  }
}

List<CollectionItem> _resolveRecentExhibits(
  UserStats stats,
  List<CollectionItem> allItems,
) {
  final pool = allItems.isNotEmpty ? allItems : stats.recentCollections;
  return _sortByNewestAcquired(pool).take(5).toList();
}

/// Newest first by [dateAcquired], then [createdAt].
List<CollectionItem> _sortByNewestAcquired(List<CollectionItem> items) {
  final copy = [...items];
  copy.sort((a, b) {
    final da = _sortableDate(a);
    final db = _sortableDate(b);
    return db.compareTo(da);
  });
  return copy;
}

String _sortableDate(CollectionItem item) {
  final acquired = item.dateAcquired?.trim();
  if (acquired != null && acquired.isNotEmpty) return acquired;
  return item.createdAt?.trim() ?? '';
}

List<CollectionItem> _filterProfileItems(
  List<CollectionItem> items, {
  required bool publicOnly,
  String? categoryId,
}) {
  var out = items;
  if (publicOnly) {
    out = out.where((e) => e.visibility == 'public').toList();
  }
  if (categoryId != null && categoryId.isNotEmpty) {
    out = out.where((e) => e.category == categoryId).toList();
  }
  return out;
}

String? _itemDisplayDate(CollectionItem item) {
  final acquired = item.dateAcquired?.trim();
  if (acquired != null && acquired.isNotEmpty) return acquired;
  final created = item.createdAt?.trim();
  if (created != null && created.isNotEmpty) return created;
  return null;
}

class _LastAddedDisplay {
  const _LastAddedDisplay({this.year, required this.monthDay});

  final String? year;
  final String monthDay;
}

const _lastAddedEmpty = _LastAddedDisplay(monthDay: '—');

_LastAddedDisplay _parseLastAddedDate(String raw) {
  final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(raw.trim());
  if (iso != null) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = int.parse(iso.group(2)!);
    final day = int.parse(iso.group(3)!);
    if (month >= 1 && month <= 12) {
      return _LastAddedDisplay(
        year: iso.group(1),
        monthDay: '${months[month - 1]} $day',
      );
    }
    return _LastAddedDisplay(year: iso.group(1), monthDay: raw.substring(5, 10));
  }
  return _LastAddedDisplay(monthDay: raw.length > 9 ? raw.substring(0, 9) : raw);
}

_LastAddedDisplay _resolveLastAdded(
  List<CollectionItem> allItems,
  List<CollectionItem> recentFromStats,
) {
  final pool = allItems.isNotEmpty ? allItems : recentFromStats;
  if (pool.isEmpty) return _lastAddedEmpty;
  final newest = _sortByNewestAcquired(pool).first;
  final raw = _itemDisplayDate(newest);
  if (raw == null) return _lastAddedEmpty;
  return _parseLastAddedDate(raw);
}

class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider({this.margin});

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: const Divider(
        height: 1,
        thickness: 1,
        color: CollectoryColors.borderLight,
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: CollectoryColors.catVinyl,
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: CollectoryColors.btnPrimaryBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: CollectoryColors.catTicket,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Matches numeric stat columns: fixed value band + grey label baseline.
class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  static const double _valueBandHeight = 40;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _valueBandHeight,
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: CollectoryColors.textPrimary,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Text(
          label,
          style: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LastAddedStatColumn extends StatelessWidget {
  const _LastAddedStatColumn({required this.display});

  final _LastAddedDisplay display;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _StatColumn._valueBandHeight,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (display.year != null)
                  Text(
                    display.year!,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: CollectoryColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                Text(
                  display.monthDay,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: CollectoryColors.textPrimary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        Text(
          'Last added',
          style: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _VisibilityCard extends StatelessWidget {
  const _VisibilityCard({
    required this.publicPreview,
    required this.onToggle,
    required this.onOpenSettings,
  });

  final bool publicPreview;
  final VoidCallback onToggle;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEDE4D9),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenSettings,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MUSEUM VISIBILITY',
                      style: CollectoryHandoffHeader.metaLabel(),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      publicPreview ? 'Public preview' : 'Private by default',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CollectoryColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      publicPreview
                          ? 'Showing public exhibits only (visitor view).'
                          : 'Toggle on to preview what visitors see.',
                      style: CollectoryHandoffHeader.bodySecondary()
                          .copyWith(fontSize: 11, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CollectoryPillToggle(
                value: publicPreview,
                onChanged: onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomPreviewCard extends StatelessWidget {
  const _RoomPreviewCard({
    required this.room,
    required this.title,
    required this.color,
    required this.onTap,
    this.preview = false,
  });

  final String room;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CollectoryColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (preview)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CollectoryColors.bgApp,
                          border: Border.all(color: CollectoryColors.textLabel),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Preview',
                          style: CollectoryHandoffHeader.metaLabel().copyWith(
                            fontSize: 8,
                            height: 1,
                          ),
                        ),
                      )
                    else
                      Text(
                        room,
                        style: CollectoryHandoffHeader.metaLabel().copyWith(
                          fontSize: 9,
                          height: 1.1,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: CollectoryColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: CollectoryColors.btnPrimaryBg,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
