// 成员 E 阶段三·任务五联调：Profile 与收藏列表共享的统计/最近展品逻辑（成员 C + 成员 E 共用）

import '../models/collection_item.dart';
import '../services/collection_query_service.dart';

List<CollectionItem> resolveRecentExhibits(
  UserStats stats,
  List<CollectionItem> allItems, {
  bool publicOnly = false,
}) {
  var recent = _sortByNewestAcquired(
    allItems.isNotEmpty ? allItems : stats.recentCollections,
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

/// Last added = 全库与 Recent exhibits 中「最新一条」的日期（取较晚者）。
ProfileLastAddedDisplay resolveLastAdded({
  required List<CollectionItem> allItems,
  required List<CollectionItem> recentExhibits,
}) {
  CollectionItem? newest;
  var newestSortable = '';

  void considerPool(List<CollectionItem> items) {
    if (items.isEmpty) return;
    final top = _sortByNewestAcquired(items).first;
    final sortable = _sortableDate(top);
    if (sortable.isEmpty) return;
    if (newest == null || sortable.compareTo(newestSortable) > 0) {
      newest = top;
      newestSortable = sortable;
    }
  }

  considerPool(recentExhibits);
  considerPool(allItems);

  final picked = newest;
  if (picked == null) return profileLastAddedEmpty;
  final raw = _itemDisplayDate(picked);
  if (raw == null) return profileLastAddedEmpty;
  return _parseLastAddedDate(raw);
}

ProfileLastAddedDisplay resolveLastAddedForProfile(
  UserStats stats,
  List<CollectionItem> allItems, {
  bool publicOnly = false,
}) {
  final recent = resolveRecentExhibits(
    stats,
    allItems,
    publicOnly: publicOnly,
  );
  return resolveLastAdded(allItems: allItems, recentExhibits: recent);
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
