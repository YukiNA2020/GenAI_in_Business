// 成员 E 阶段三·任务五联调：Profile 与收藏列表共享的统计/最近展品逻辑（成员 C + 成员 E 共用）

import '../models/collection_item.dart';
import '../services/collection_query_service.dart';
import 'collectory_room_catalog.dart';

/// Profile 顶栏四项统计（展品 / 有内容的 room / 公开 / 最近添加）
class ProfileStatsDisplay {
  const ProfileStatsDisplay({
    required this.exhibits,
    required this.rooms,
    required this.publicCount,
    required this.lastAdded,
  });

  final int exhibits;
  final int rooms;
  final int publicCount;
  final ProfileLastAddedDisplay lastAdded;

  String get exhibitsLabel => exhibits.toString();

  String get roomsLabel => rooms.toString().padLeft(2, '0');

  String get publicLabel => publicCount.toString();
}

ProfileStatsDisplay resolveProfileStatsDisplay({
  required List<CollectionItem> museumCatalogItems,
  required UserStats stats,
}) {
  final hasCatalog = museumCatalogItems.isNotEmpty;
  final exhibits =
      hasCatalog ? museumCatalogItems.length : stats.totalCollections;
  final rooms = hasCatalog
      ? CollectoryRoomCatalog.rooms
          .where(
            (spec) =>
                CollectoryRoomCatalog.itemsInRoom(museumCatalogItems, spec)
                    .isNotEmpty,
          )
          .length
      : stats.categoryCount;
  final publicCount = hasCatalog
      ? museumCatalogItems
          .where((e) => e.visibility == 'public')
          .length
      : stats.publicCollections;
  final lastAdded =
      resolveLastAdded(museumCatalogItems, stats.recentCollections);
  return ProfileStatsDisplay(
    exhibits: exhibits,
    rooms: rooms,
    publicCount: publicCount,
    lastAdded: lastAdded,
  );
}

/// Recent row on Profile — full museum catalog only (not Gallery wall filters).
List<CollectionItem> resolveRecentExhibits(
  UserStats stats,
  List<CollectionItem> museumCatalogItems, {
  bool publicOnly = false,
}) {
  var recent = _sortByNewestAcquired(
    museumCatalogItems.isNotEmpty
        ? museumCatalogItems
        : stats.recentCollections,
  ).take(5).toList();
  if (publicOnly) {
    recent = recent.where((e) => e.visibility == 'public').toList();
  }
  return recent;
}

List<CollectionItem> filterProfileItems(
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

class ProfileLastAddedDisplay {
  const ProfileLastAddedDisplay({this.year, required this.monthDay});

  final String? year;
  final String monthDay;
}

const profileLastAddedEmpty = ProfileLastAddedDisplay(monthDay: '—');

ProfileLastAddedDisplay resolveLastAdded(
  List<CollectionItem> allItems,
  List<CollectionItem> recentFromStats,
) {
  final pool = allItems.isNotEmpty ? allItems : recentFromStats;
  if (pool.isEmpty) return profileLastAddedEmpty;
  final newest = _sortByNewestAcquired(pool).first;
  final raw = _itemDisplayDate(newest);
  if (raw == null) return profileLastAddedEmpty;
  return _parseLastAddedDate(raw);
}

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

String? _itemDisplayDate(CollectionItem item) {
  final acquired = item.dateAcquired?.trim();
  if (acquired != null && acquired.isNotEmpty) return acquired;
  final created = item.createdAt?.trim();
  if (created != null && created.isNotEmpty) return created;
  return null;
}

ProfileLastAddedDisplay _parseLastAddedDate(String raw) {
  final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(raw.trim());
  if (iso != null) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = int.parse(iso.group(2)!);
    final day = int.parse(iso.group(3)!);
    if (month >= 1 && month <= 12) {
      return ProfileLastAddedDisplay(
        year: iso.group(1),
        monthDay: '${months[month - 1]} $day',
      );
    }
    return ProfileLastAddedDisplay(
      year: iso.group(1),
      monthDay: raw.substring(5, 10),
    );
  }
  return ProfileLastAddedDisplay(
    monthDay: raw.length > 9 ? raw.substring(0, 9) : raw,
  );
}
