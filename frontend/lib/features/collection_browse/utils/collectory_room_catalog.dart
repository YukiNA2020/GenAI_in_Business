import 'package:flutter/material.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_item.dart';
import '../models/collection_room.dart';

/// 月度 Room 元数据 — Gallery / Profile / Collection room 共用
class CollectoryRoomSpec {
  const CollectoryRoomSpec({
    required this.index,
    required this.roomCode,
    required this.monthYear,
    required this.monthName,
    required this.monthAbbrev,
    required this.month,
    required this.year,
    required this.cardColor,
    required this.isPreview,
    required this.galleryBlurb,
    required this.roomBlurb,
    required this.reflection,
    required this.designTimeline,
  });

  final int index;
  final String roomCode;
  final String monthYear;
  final String monthName;
  final String monthAbbrev;
  final int month;
  final int year;
  final Color cardColor;
  final bool isPreview;
  final String galleryBlurb;
  final String roomBlurb;
  final String reflection;
  final List<RoomTimelineEntry> designTimeline;

  String get archiveTitle => '$monthName $year Archive';

  String get collectionLabel => '$monthName collection';

  String get dateRangeLabel {
    final lastDay = switch (month) {
      2 => 28,
      4 || 6 || 9 || 11 => 30,
      _ => 31,
    };
    return '$monthName 1–$lastDay, $year';
  }
}

class RoomTimelineEntry {
  const RoomTimelineEntry(this.date, this.label, this.dotColor);

  final String date;
  final String label;
  final Color dotColor;
}

abstract final class CollectoryRoomCatalog {
  static const List<CollectoryRoomSpec> rooms = [
    CollectoryRoomSpec(
      index: 0,
      roomCode: 'ROOM 01',
      monthYear: 'May 2026',
      monthName: 'May',
      monthAbbrev: 'MAY',
      month: 5,
      year: 2026,
      cardColor: CollectoryColors.room01,
      isPreview: false,
      galleryBlurb:
          'A monthly room for objects, tickets, minerals, and memories collected in May.',
      roomBlurb: 'A monthly room of objects collected around live music, '
          'small discoveries, and memory fragments.',
      reflection: 'This room captures a month of live music, saved tickets, '
          'and small discoveries with a warm nostalgic mood.',
      designTimeline: [
        RoomTimelineEntry('MAY 03', 'First ticket saved', Color(0xFF171512)),
        RoomTimelineEntry('MAY 11', 'Vinyl added to room', Color(0xFFC98250)),
        RoomTimelineEntry('MAY 18', 'Mineral tagged', Color(0xFF171512)),
      ],
    ),
    CollectoryRoomSpec(
      index: 1,
      roomCode: 'ROOM 02',
      monthYear: 'Jun 2026',
      monthName: 'Jun',
      monthAbbrev: 'JUN',
      month: 6,
      year: 2026,
      cardColor: CollectoryColors.room02,
      isPreview: true,
      galleryBlurb:
          'A monthly room for summer tickets, travel memories, and objects collected in June.',
      roomBlurb: 'A quieter June archive for travel tickets, postcards, '
          'and objects waiting to be catalogued.',
      reflection: 'June leans toward travel fragments and softer greens — '
          'a room still taking shape before the month ends.',
      designTimeline: [
        RoomTimelineEntry('JUN 05', 'Postcard from trip', Color(0xFF171512)),
        RoomTimelineEntry('JUN 12', 'Ticket stub filed', Color(0xFFC98250)),
        RoomTimelineEntry('JUN 20', 'Mineral shelf started', Color(0xFF171512)),
      ],
    ),
    CollectoryRoomSpec(
      index: 2,
      roomCode: 'ROOM 03',
      monthYear: 'Jul 2026',
      monthName: 'Jul',
      monthAbbrev: 'JUL',
      month: 7,
      year: 2026,
      cardColor: CollectoryColors.room03,
      isPreview: true,
      galleryBlurb:
          'A monthly room for late-summer minerals, vinyl finds, and memories collected in July.',
      roomBlurb: 'A July preview room for minerals, vinyl, and memory objects '
          'you plan to add as the month unfolds.',
      reflection:
          'July is reserved for deeper mineral stories and late-summer vinyl — '
          'preview the mood before exhibits arrive.',
      designTimeline: [
        RoomTimelineEntry('JUL 02', 'Room opened', Color(0xFF171512)),
        RoomTimelineEntry('JUL 09', 'Fluorite tagged', Color(0xFFC98250)),
        RoomTimelineEntry('JUL 17', 'Vinyl catalogued', Color(0xFF171512)),
      ],
    ),
  ];

  static CollectoryRoomSpec forIndex(int index) {
    if (index < 0 || index >= rooms.length) return rooms.first;
    return rooms[index];
  }

  static int fallbackRoomIdForIndex(int index) => -(index + 1);

  static int? fallbackIndexFromRoomId(int roomId) {
    if (roomId >= 0) return null;
    final index = -roomId - 1;
    if (index < 0 || index >= rooms.length) return null;
    return index;
  }

  static List<CollectionRoomSummary> fallbackSummaries({
    List<CollectionItem> items = const [],
  }) {
    return [
      for (final spec in rooms)
        CollectionRoomSummary(
          id: fallbackRoomIdForIndex(spec.index),
          month: spec.monthYear,
          label: spec.archiveTitle,
          collectionCount: itemsInRoom(items, spec).length,
        ),
    ];
  }

  static CollectionRoomDetail? fallbackDetailForRoomId(
    int roomId,
    List<CollectionItem> items,
  ) {
    final index = fallbackIndexFromRoomId(roomId);
    if (index == null) return null;
    final spec = forIndex(index);
    return CollectionRoomDetail(
      id: roomId,
      month: spec.monthYear,
      label: spec.archiveTitle,
      collections: itemsInRoom(items, spec),
    );
  }

  static int? _monthOf(CollectionItem item) {
    final raw = item.dateAcquired ?? item.createdAt;
    if (raw == null || raw.length < 7) return null;
    return int.tryParse(raw.substring(5, 7));
  }

  /// 属于该月 room 的藏品；May 无日期匹配时回退全量（demo seed）
  static List<CollectionItem> itemsInRoom(
    List<CollectionItem> items,
    CollectoryRoomSpec spec,
  ) {
    final byMonth =
        items.where((item) => _monthOf(item) == spec.month).toList();
    if (byMonth.isNotEmpty) return byMonth;
    if (spec.index == 0) return items;
    return [];
  }

  /// Home / Gallery 主卡片 — ROOM 01（May 2026）藏品数
  static int mayRoomExhibitCount(List<CollectionItem> items) {
    return itemsInRoom(items, rooms.first).length;
  }

  /// 解析 API room.month（如 `2026-05`）对应的藏品
  static List<CollectionItem> itemsForApiRoomMonth(
    List<CollectionItem> items,
    String roomMonth,
  ) {
    if (roomMonth.length < 7) return const [];
    final year = int.tryParse(roomMonth.substring(0, 4));
    final month = int.tryParse(roomMonth.substring(5, 7));
    if (year == null || month == null) return const [];
    final specIndex = rooms.indexWhere((s) => s.year == year && s.month == month);
    if (specIndex >= 0) {
      return itemsInRoom(items, rooms[specIndex]);
    }
    return items
        .where((item) {
          final raw = item.dateAcquired ?? item.createdAt;
          if (raw == null || raw.length < 7) return false;
          return raw.startsWith(roomMonth);
        })
        .toList();
  }

  static String formatTimelineDate(String? raw, CollectoryRoomSpec spec) {
    if (raw != null && raw.length >= 10) {
      final parts = raw.substring(0, 10).split('-');
      if (parts.length == 3) {
        final day = int.tryParse(parts[2]);
        if (day != null) {
          return '${spec.monthAbbrev} ${day.toString().padLeft(2, '0')}';
        }
      }
    }
    return '—';
  }
}
