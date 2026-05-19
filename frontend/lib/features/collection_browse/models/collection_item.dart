import 'dart:convert';

String? _parseImageUrl(Map<String, dynamic> json) {
  final raw = json['imageUrl'] ?? json['image_url'];
  if (raw == null) return null;
  final s = raw.toString().trim();
  return s.isEmpty ? null : s;
}

class CollectionItem {
  const CollectionItem({
    required this.id,
    required this.title,
    this.category,
    this.dateAcquired,
    this.location,
    this.story,
    this.imageUrl,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.visibility,
    this.categoryTemplate,
    this.customFields,
  });

  final int id;
  final String title;
  final String? category;
  final String? dateAcquired;
  final String? location;
  final String? story;
  final String? imageUrl;
  final List<String> tags;
  final String? createdAt;
  final String? updatedAt;
  final int? userId;
  final String? visibility;
  final String? categoryTemplate;
  final String? customFields;

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    List<String> tags = [];
    if (rawTags is List) {
      tags = rawTags.map((e) => e.toString()).toList();
    }
    return CollectionItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      category: json['category'] as String?,
      dateAcquired: json['dateAcquired'] as String? ??
          json['date_acquired'] as String?,
      location: json['location'] as String?,
      story: json['story'] as String?,
      imageUrl: _parseImageUrl(json),
      tags: tags,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String?,
      userId: (json['userId'] as num?)?.toInt(),
      visibility: json['visibility'] as String?,
      categoryTemplate: json['categoryTemplate'] as String?,
      customFields: json['customFields'] as String?,
    );
  }
}

/// 按 GET /api/categories 的 fields 顺序展示 customFields（计划阶段二·任务 5）
List<MapEntry<String, String>> orderedCustomFieldEntries(
  Map<String, String>? custom,
  List<String> categoryFieldKeys,
) {
  if (custom == null || custom.isEmpty) return [];
  final used = <String>{};
  final ordered = <MapEntry<String, String>>[];
  for (final key in categoryFieldKeys) {
    final value = custom[key];
    if (value != null && value.isNotEmpty) {
      ordered.add(MapEntry(key, value));
      used.add(key);
    }
  }
  for (final e in custom.entries) {
    if (!used.contains(e.key) && e.value.isNotEmpty) {
      ordered.add(e);
    }
  }
  return ordered;
}

Map<String, String>? parseCustomFields(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final out = <String, String>{};
    decoded.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        out[key.toString()] = value.toString();
      }
    });
    return out.isEmpty ? null : out;
  } catch (_) {
    return null;
  }
}
