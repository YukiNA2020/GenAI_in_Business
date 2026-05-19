import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_item.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../services/collection_query_service.dart';
import '../utils/collectory_room_catalog.dart';
import '../utils/gallery_layers.dart';
import '../widgets/collectory_handoff_header.dart';
import '../widgets/design/collectory_top_bar.dart';
import '../widgets/design/exhibit_illustrations.dart';

/// Figma Collectory - Collection Room / Mobile.png
/// 单屏无滚动；按所选月度 room 展示标题、日期与 Highlights / Timeline。
class CollectionRoomPage extends ConsumerWidget {
  const CollectionRoomPage({
    super.key,
    required this.roomIndex,
  });

  /// 0=May 1=Jun 2=Jul — Gallery / Profile 同月下标进入同一页面配置
  final int roomIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = CollectoryColors.screenPadding;
    final room = CollectoryRoomCatalog.forIndex(roomIndex);
    final statsAsync = ref.watch(userStatsProvider);
    final list = ref.watch(collectionListProvider);
    final roomItems = CollectoryRoomCatalog.itemsInRoom(list.items, room);

    return ColoredBox(
      color: CollectoryColors.bgApp,
      child: SafeArea(
        child: statsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: CollectoryColors.textLabel),
          ),
          error: (_, __) => _roomBody(
            ref: ref,
            pad: pad,
            room: room,
            roomItems: roomItems,
            allItems: list.items,
            exhibitCount: roomItems.isNotEmpty
                ? roomItems.length
                : (room.isPreview ? 0 : demoUserStatsFallback.totalCollections),
          ),
          data: (stats) {
            final pool = roomItems.isNotEmpty
                ? roomItems
                : CollectoryRoomCatalog.itemsInRoom(stats.recentCollections, room);
            final count = pool.isNotEmpty
                ? pool.length
                : (room.isPreview ? 0 : (stats.totalCollections > 0 ? stats.totalCollections : 24));
            return _roomBody(
              ref: ref,
              pad: pad,
              room: room,
              roomItems: pool,
              allItems: list.items,
              exhibitCount: count,
            );
          },
        ),
      ),
    );
  }

  Widget _roomBody({
    required WidgetRef ref,
    required double pad,
    required CollectoryRoomSpec room,
    required List<CollectionItem> roomItems,
    required List<CollectionItem> allItems,
    required int exhibitCount,
  }) {
    final highlights = _resolveHighlights(room, roomItems);
    final timeline = _resolveTimeline(room, roomItems);

    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, 10, pad, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CollectoryBackBar(
              backLabel: 'Rooms',
              centerTitle: 'Collection room',
              onBack: () => closeCollectionRoom(ref),
              trailing: Material(
                color: CollectoryColors.btnPrimaryBg,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => openShareRoom(ref),
                  borderRadius: BorderRadius.circular(10),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.north_east,
                      color: CollectoryColors.btnPrimaryText,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.roomCode, style: CollectoryHandoffHeader.metaLabel()),
                      const SizedBox(height: 4),
                      Text(
                        room.archiveTitle,
                        style: CollectoryHandoffHeader.pageTitle().copyWith(
                          fontSize: 28,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
                if (room.isPreview)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CollectoryColors.bgApp,
                      border: Border.all(color: CollectoryColors.textLabel),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Preview',
                      style: CollectoryHandoffHeader.metaLabel().copyWith(
                        fontSize: 9,
                        height: 1,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              room.roomBlurb,
              style: CollectoryHandoffHeader.bodySecondary().copyWith(
                fontSize: 13,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            _StatsCard(
              exhibitCount: exhibitCount,
              room: room,
            ),
            const SizedBox(height: 8),
            _AiReflectionCard(reflection: room.reflection),
            const Spacer(flex: 2),
            Text(
              'Highlights',
              style: CollectoryHandoffHeader.sectionTitle().copyWith(fontSize: 17),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 118,
              child: Row(
                children: [
                  for (var i = 0; i < highlights.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: i < highlights.length - 1 ? 7 : 0,
                        ),
                        child: _HighlightCard(
                          highlight: highlights[i],
                          onTap: () => _openRoomHighlight(
                            ref,
                            allItems,
                            highlights[i].categorySlug,
                            highlights[i].itemId,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Text(
              'Room timeline',
              style: CollectoryHandoffHeader.sectionTitle().copyWith(fontSize: 17),
            ),
            const SizedBox(height: 6),
            for (var i = 0; i < timeline.length; i++) ...[
              _TimelineRow(entry: timeline[i]),
              if (i < timeline.length - 1) const SizedBox(height: 6),
            ],
            const Spacer(flex: 2),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ref.read(collectionRoomIndexProvider.notifier).state =
                          roomIndex;
                      goToGalleryTab(ref);
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Open wall'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      closeMember3Overlay(ref);
                      ref.read(member3TabIndexProvider.notifier).state = 2;
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      foregroundColor: CollectoryColors.textPrimary,
                      side: const BorderSide(color: CollectoryColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Add exhibit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<_RoomHighlight> _resolveHighlights(
  CollectoryRoomSpec room,
  List<CollectionItem> roomItems,
) {
  if (roomItems.isEmpty) {
    return _designHighlightsFor(room);
  }

  final sorted = [...roomItems]
    ..sort((a, b) {
      final da = a.dateAcquired ?? a.createdAt ?? '';
      final db = b.dateAcquired ?? b.createdAt ?? '';
      return db.compareTo(da);
    });

  return sorted.take(3).map((item) {
    final spec = galleryLayerSpecs.firstWhere(
      (s) => item.category != null && s.categorySlugs.contains(item.category),
      orElse: () => galleryLayerSpecs.first,
    );
    return _RoomHighlight(
      exhibitId: item.id.toString().padLeft(3, '0'),
      title: item.title,
      kind: ExhibitIcon.fromCategory(item.category) ?? ExhibitIconKind.vinyl,
      color: Color(spec.cardColor),
      categorySlug: item.category ?? spec.categorySlugs.first,
      itemId: item.id,
    );
  }).toList();
}

List<_RoomHighlight> _designHighlightsFor(CollectoryRoomSpec room) {
  return switch (room.index) {
    1 => const [
        _RoomHighlight(
          exhibitId: '—',
          title: 'June archive',
          kind: ExhibitIconKind.ticket,
          color: Color(0xFFD5E0DC),
          categorySlug: 'ticket',
        ),
        _RoomHighlight(
          exhibitId: '—',
          title: 'Travel postcard',
          kind: ExhibitIconKind.memory,
          color: Color(0xFFE8E4DC),
          categorySlug: 'postcard',
        ),
        _RoomHighlight(
          exhibitId: '—',
          title: 'Shelf mineral',
          kind: ExhibitIconKind.mineral,
          color: Color(0xFFDCD5EA),
          categorySlug: 'mineral',
        ),
      ],
    2 => const [
        _RoomHighlight(
          exhibitId: '—',
          title: 'July fluorite',
          kind: ExhibitIconKind.mineral,
          color: Color(0xFFDCD5EA),
          categorySlug: 'mineral',
        ),
        _RoomHighlight(
          exhibitId: '—',
          title: 'Summer vinyl',
          kind: ExhibitIconKind.vinyl,
          color: Color(0xFFC7A679),
          categorySlug: 'vinyl',
        ),
        _RoomHighlight(
          exhibitId: '—',
          title: 'Memory ticket',
          kind: ExhibitIconKind.ticket,
          color: Color(0xFFD5E0DC),
          categorySlug: 'ticket',
        ),
      ],
    _ => const [
        _RoomHighlight(
          exhibitId: '014',
          title: 'Signed Vinyl',
          kind: ExhibitIconKind.vinyl,
          color: Color(0xFFC7A679),
          categorySlug: 'vinyl',
        ),
        _RoomHighlight(
          exhibitId: '015',
          title: 'Concert Ticket',
          kind: ExhibitIconKind.ticket,
          color: Color(0xFFD5E0DC),
          categorySlug: 'ticket',
        ),
        _RoomHighlight(
          exhibitId: '022',
          title: 'Green Fluorite',
          kind: ExhibitIconKind.mineral,
          color: Color(0xFFDCD5EA),
          categorySlug: 'mineral',
        ),
      ],
  };
}

List<_TimelineEntry> _resolveTimeline(
  CollectoryRoomSpec room,
  List<CollectionItem> roomItems,
) {
  if (roomItems.isEmpty) {
    return room.designTimeline
        .map(
          (e) => _TimelineEntry(e.date, e.label, e.dotColor),
        )
        .toList();
  }

  final sorted = [...roomItems]
    ..sort((a, b) {
      final da = a.dateAcquired ?? a.createdAt ?? '';
      final db = b.dateAcquired ?? b.createdAt ?? '';
      return db.compareTo(da);
    });

  return sorted.take(3).map((item) {
    final dateLabel = CollectoryRoomCatalog.formatTimelineDate(
      item.dateAcquired ?? item.createdAt,
      room,
    );
    final label = item.title.length > 28
        ? '${item.title.substring(0, 28)}…'
        : item.title;
    return _TimelineEntry(dateLabel, label, const Color(0xFF171512));
  }).toList();
}

void _openRoomHighlight(
  WidgetRef ref,
  List<CollectionItem> items,
  String categorySlug,
  int? itemId,
) {
  if (itemId != null) {
    openItemDetail(ref, itemId);
    return;
  }
  GalleryLayerSpec? spec;
  for (final s in galleryLayerSpecs) {
    if (s.categorySlugs.contains(categorySlug)) {
      spec = s;
      break;
    }
  }
  if (spec != null) {
    for (final item in items) {
      if (spec.categorySlugs.contains(item.category)) {
        openItemDetail(ref, item.id);
        return;
      }
    }
  }
  goToGalleryTab(ref, categorySlug: categorySlug);
}

class _RoomHighlight {
  const _RoomHighlight({
    required this.exhibitId,
    required this.title,
    required this.kind,
    required this.color,
    required this.categorySlug,
    this.itemId,
  });

  final String exhibitId;
  final String title;
  final ExhibitIconKind kind;
  final Color color;
  final String categorySlug;
  final int? itemId;
}

class _TimelineEntry {
  const _TimelineEntry(this.date, this.label, this.dotColor);

  final String date;
  final String label;
  final Color dotColor;
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.exhibitCount,
    required this.room,
  });

  final int exhibitCount;
  final CollectoryRoomSpec room;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: room.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CollectoryColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$exhibitCount',
                  style: CollectoryHandoffHeader.pageTitle().copyWith(fontSize: 34),
                ),
                Text(
                  'exhibits in this room',
                  style: CollectoryHandoffHeader.bodySecondary().copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ROOM MOOD', style: CollectoryHandoffHeader.metaLabel()),
                const SizedBox(height: 2),
                Text(
                  room.isPreview ? 'preview, forming' : 'warm, loud, nostalgic',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: CollectoryColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  room.dateRangeLabel,
                  style: CollectoryHandoffHeader.bodySecondary().copyWith(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiReflectionCard extends StatelessWidget {
  const _AiReflectionCard({required this.reflection});

  final String reflection;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: CollectoryColors.btnPrimaryBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI ROOM REFLECTION',
                  style: CollectoryHandoffHeader.metaLabel().copyWith(
                    color: const Color(0xFFC98250),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reflection,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.35,
                    color: CollectoryColors.btnPrimaryText,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: CollectoryColors.btnPrimaryBg,
              backgroundColor: CollectoryColors.btnPrimaryText,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Redo', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.highlight,
    required this.onTap,
  });

  final _RoomHighlight highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlight.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: ExhibitIcon(kind: highlight.kind, size: 36)),
              const Spacer(),
              Text(
                highlight.exhibitId == '—'
                    ? 'PREVIEW'
                    : 'EXH ${highlight.exhibitId}',
                style: CollectoryHandoffHeader.metaLabel().copyWith(fontSize: 8),
              ),
              Text(
                highlight.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: CollectoryColors.textPrimary,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});

  final _TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: entry.dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 52,
          child: Text(
            entry.date,
            style: CollectoryHandoffHeader.metaLabel().copyWith(
              fontSize: 9,
              color: CollectoryColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            entry.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CollectoryColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
