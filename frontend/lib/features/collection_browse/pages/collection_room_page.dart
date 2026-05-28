import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_item.dart';
import '../models/collection_room.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../utils/collectory_room_catalog.dart';
import '../utils/gallery_layers.dart';
import '../widgets/collectory_handoff_header.dart';
import '../widgets/design/collectory_top_bar.dart';
import '../widgets/design/exhibit_illustrations.dart';

/// Figma Collectory - Collection Room / Mobile.png
/// 单屏无滚动；按所选 room（来自 /api/rooms）展示标题、日期与 Highlights / Timeline。
class CollectionRoomPage extends ConsumerWidget {
  const CollectionRoomPage({
    super.key,
    required this.roomId,
  });

  /// room ID from /api/rooms
  final int roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = CollectoryColors.screenPadding;
    final allItems = ref.watch(allCollectionsProvider).valueOrNull ??
        ref.watch(collectionListProvider).items;
    final fallbackRoom = CollectoryRoomCatalog.fallbackDetailForRoomId(
      roomId,
      allItems,
    );
    if (fallbackRoom != null) {
      return ColoredBox(
        color: CollectoryColors.bgApp,
        child: SafeArea(
          child: _roomBody(
            ref: ref,
            pad: pad,
            room: fallbackRoom,
            roomItems: fallbackRoom.collections,
            exhibitCount: fallbackRoom.collections.length,
          ),
        ),
      );
    }

    final roomAsync = ref.watch(roomDetailProvider(roomId));

    return ColoredBox(
      color: CollectoryColors.bgApp,
      child: SafeArea(
        child: roomAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: CollectoryColors.textLabel),
          ),
          error: (e, _) => _roomBody(
            ref: ref,
            pad: pad,
            room: null,
            roomItems: const [],
            exhibitCount: demoUserStatsFallback.totalCollections,
          ),
          data: (room) {
            final byMonth =
                CollectoryRoomCatalog.itemsForApiRoomMonth(allItems, room.month);
            final roomItems =
                byMonth.length >= room.collections.length ? byMonth : room.collections;
            return _roomBody(
              ref: ref,
              pad: pad,
              room: room,
              roomItems: roomItems,
              exhibitCount: roomItems.length,
            );
          },
        ),
      ),
    );
  }

  Widget _roomBody({
    required WidgetRef ref,
    required double pad,
    required CollectionRoomDetail? room,
    required List<CollectionItem> roomItems,
    required int exhibitCount,
  }) {
    final label = room?.label ?? room?.month ?? 'Collection room';
    final month = room?.month ?? '';
    final highlights = _resolveHighlights(roomItems);
    final timeline = _resolveTimeline(roomItems, room?.month);

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
                      Text(month, style: CollectoryHandoffHeader.metaLabel()),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: CollectoryHandoffHeader.pageTitle().copyWith(
                          fontSize: 28,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Monthly collection archive',
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
              month: month,
            ),
            const SizedBox(height: 8),
            _AiReflectionCard(
              reflection: roomItems.isEmpty
                  ? 'Start adding exhibits to this room to see AI reflections.'
                  : 'A rich month of memories — $exhibitCount exhibits collected.',
            ),
            const Spacer(flex: 2),
            Text(
              'Highlights',
              style:
                  CollectoryHandoffHeader.sectionTitle().copyWith(fontSize: 17),
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
                          onTap: () =>
                              _openRoomHighlight(ref, roomItems, highlights[i]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Text(
              'Room timeline',
              style:
                  CollectoryHandoffHeader.sectionTitle().copyWith(fontSize: 17),
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
                      ref.read(selectedRoomIdProvider.notifier).state = roomId;
                      final roomYearMonth = _extractYearMonth(room?.month);
                      goToGalleryTab(
                        ref,
                        year: roomYearMonth?.$1,
                        month: roomYearMonth?.$2,
                        scrollToCollectionWall: true,
                      );
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
                      side:
                          const BorderSide(color: CollectoryColors.borderLight),
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

  List<_RoomHighlight> _resolveHighlights(List<CollectionItem> roomItems) {
    if (roomItems.isEmpty) {
      return const [
        _RoomHighlight(
          exhibitId: '—',
          title: 'No exhibits yet',
          kind: ExhibitIconKind.vinyl,
          color: Color(0xFFC7A679),
          categorySlug: 'vinyl',
        ),
        _RoomHighlight(
          exhibitId: '—',
          title: 'Start collecting',
          kind: ExhibitIconKind.mineral,
          color: Color(0xFFDCD5EA),
          categorySlug: 'mineral',
        ),
        _RoomHighlight(
          exhibitId: '—',
          title: 'Add your first item',
          kind: ExhibitIconKind.ticket,
          color: Color(0xFFD5E0DC),
          categorySlug: 'ticket',
        ),
      ];
    }

    final sorted = [...roomItems]..sort((a, b) {
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

  List<_TimelineEntry> _resolveTimeline(
    List<CollectionItem> roomItems,
    String? roomMonth,
  ) {
    if (roomItems.isEmpty) {
      final month = _extractYearMonth(roomMonth)?.$2;
      if (month == 6 || month == 7) {
        final mm = month.toString().padLeft(2, '0');
        return [
          _TimelineEntry('$mm/03', 'Preview: collection moment placeholder', const Color(0xFF6F655B)),
          _TimelineEntry('$mm/02', 'Preview: timeline note placeholder', const Color(0xFF8E7760)),
          _TimelineEntry('$mm/01', 'Preview: upcoming exhibit slot', const Color(0xFF6F655B)),
        ];
      }
      return const [];
    }

    final sorted = [...roomItems]..sort((a, b) {
        final da = a.dateAcquired ?? a.createdAt ?? '';
        final db = b.dateAcquired ?? b.createdAt ?? '';
        return db.compareTo(da);
      });

    return sorted.take(3).map((item) {
      final dateLabel = _formatDate(item.dateAcquired ?? item.createdAt);
      final label = item.title.length > 28
          ? '${item.title.substring(0, 28)}…'
          : item.title;
      return _TimelineEntry(dateLabel, label, const Color(0xFF171512));
    }).toList();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    try {
      final parts = dateStr.substring(0, 10).split('-');
      if (parts.length >= 3) {
        final month = int.tryParse(parts[1]);
        final day = int.tryParse(parts[2]);
        if (month != null && day != null) {
          return '${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
        }
      }
    } catch (_) {}
    return dateStr;
  }

  (int, int)? _extractYearMonth(String? monthLabel) {
    if (monthLabel == null || monthLabel.isEmpty) return null;
    final numeric = RegExp(r'(\d{4})-(\d{2})').firstMatch(monthLabel);
    if (numeric != null) {
      final year = int.tryParse(numeric.group(1)!);
      final month = int.tryParse(numeric.group(2)!);
      if (year != null && month != null) return (year, month);
    }
    final text = RegExp(r'([A-Za-z]{3,9})\s+(\d{4})').firstMatch(monthLabel);
    if (text != null) {
      final monthName = text.group(1)!.toLowerCase();
      final year = int.tryParse(text.group(2)!);
      final monthMap = {
        'jan': 1,
        'january': 1,
        'feb': 2,
        'february': 2,
        'mar': 3,
        'march': 3,
        'apr': 4,
        'april': 4,
        'may': 5,
        'jun': 6,
        'june': 6,
        'jul': 7,
        'july': 7,
        'aug': 8,
        'august': 8,
        'sep': 9,
        'sept': 9,
        'september': 9,
        'oct': 10,
        'october': 10,
        'nov': 11,
        'november': 11,
        'dec': 12,
        'december': 12,
      };
      final month = monthMap[monthName];
      if (year != null && month != null) return (year, month);
    }
    return null;
  }

  void _openRoomHighlight(
    WidgetRef ref,
    List<CollectionItem> items,
    _RoomHighlight highlight,
  ) {
    if (highlight.itemId != null) {
      openItemDetail(ref, highlight.itemId!);
      return;
    }
    GalleryLayerSpec? spec;
    for (final s in galleryLayerSpecs) {
      if (s.categorySlugs.contains(highlight.categorySlug)) {
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
    goToGalleryTab(
      ref,
      categorySlug: highlight.categorySlug,
      scrollToCollectionWall: true,
    );
  }
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
    required this.month,
  });

  final int exhibitCount;
  final String month;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
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
                  style: CollectoryHandoffHeader.pageTitle()
                      .copyWith(fontSize: 34),
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
                  'warm, loud, nostalgic',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: CollectoryColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  month,
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
                style:
                    CollectoryHandoffHeader.metaLabel().copyWith(fontSize: 8),
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
