import 'package:flutter/material.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_item.dart';

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
      roomBlurb:
          'A monthly room of objects collected around live music, '
          'small discoveries, and memory fragments.',
      reflection:
          'This room captures a month of live music, saved tickets, '
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
      roomBlurb:
          'A quieter June archive for travel tickets, postcards, '
          'and objects waiting to be catalogued.',
      reflection:
          'June leans toward travel fragments and softer greens — '
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
      roomBlurb:
          'A July preview room for minerals, vinyl, and memory objects '
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

  /// Gallery 顶栏 room 条固定高亮「当前月」（demo 回退 May 2026 / ROOM 01）
  static int currentMonthRoomIndex() {
    final now = DateTime.now();
    for (var i = 0; i < rooms.length; i++) {
      final spec = rooms[i];
      if (spec.month == now.month && spec.year == now.year) {
        return i;
      }
    }
    return 0;
  }

  static CollectoryRoomSpec get currentMonthRoom =>
      forIndex(currentMonthRoomIndex());

  static const List<String> wallMonthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String monthLabel(int month) =>
      month >= 1 && month <= 12 ? wallMonthLabels[month - 1] : '—';

  /// Collection wall 年份下拉（去重排序）
  static List<int> get wallFilterYears {
    final years = rooms.map((r) => r.year).toSet().toList()..sort();
    return years;
  }

  static int? _yearOf(CollectionItem item) {
    final raw = item.dateAcquired ?? item.createdAt;
    if (raw == null || raw.length < 4) return null;
    return int.tryParse(raw.substring(0, 4));
  }

  static int? _monthOf(CollectionItem item) {
    final raw = item.dateAcquired ?? item.createdAt;
    if (raw == null || raw.length < 7) return null;
    return int.tryParse(raw.substring(5, 7));
  }

  /// 属于该 room 对应年月的藏品（优先 dateAcquired，否则 createdAt）
  static bool itemMatchesRoom(CollectionItem item, CollectoryRoomSpec spec) {
    return _yearOf(item) == spec.year && _monthOf(item) == spec.month;
  }

  static List<CollectionItem> itemsInRoom(
    List<CollectionItem> items,
    CollectoryRoomSpec spec,
  ) {
    return items.where((item) => itemMatchesRoom(item, spec)).toList();
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
