import 'collection_item.dart';

class CollectionRoomSummary {
  const CollectionRoomSummary({
    required this.id,
    required this.month,
    this.label,
    this.createdAt,
    this.collectionCount,
  });

  final int id;
  final String month;
  final String? label;
  final String? createdAt;
  final int? collectionCount;

  factory CollectionRoomSummary.fromJson(Map<String, dynamic> json) {
    return CollectionRoomSummary(
      id: (json['id'] as num).toInt(),
      month: json['month'] as String,
      label: json['label'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      collectionCount: (json['collectionCount'] as num?)?.toInt() ??
          (json['collection_count'] as num?)?.toInt(),
    );
  }
}

class CollectionRoomDetail extends CollectionRoomSummary {
  const CollectionRoomDetail({
    required super.id,
    required super.month,
    super.label,
    super.createdAt,
    this.collections = const [],
  });

  final List<CollectionItem> collections;

  factory CollectionRoomDetail.fromJson(Map<String, dynamic> json) {
    final collectionsList = (json['collections'] as List?);
    final collections = collectionsList
            ?.map((e) => CollectionItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return CollectionRoomDetail(
      id: (json['id'] as num).toInt(),
      month: json['month'] as String,
      label: json['label'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      collections: collections,
    );
  }
}
