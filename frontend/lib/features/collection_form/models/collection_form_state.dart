// 负责人：成员 E / 成员 5 — 阶段四：正式表单状态
// INTEGRATION_IMPLEMENTATION_PATH.md §7.3

/// 正式 Create flow 的完整表单状态。
class CollectionFormState {
  const CollectionFormState({
    this.title = '',
    this.category,
    this.dateAcquired,
    this.location = '',
    this.story = '',
    this.tags = const [],
    this.visibility = 'private',
    this.roomId,
    this.imageBytes,
    this.imageFilename,
    this.imageMimeType,
    this.customFields = const {},
    this.isSaving = false,
    this.isUploadingImage = false,
    this.saveError,
    this.savedSuccessfully = false,
    this.savedCollectionId,
  });

  final String title;
  final String? category;
  final String? dateAcquired;
  final String location;
  final String story;
  final List<String> tags;
  final String visibility;
  final int? roomId;
  final List<int>? imageBytes;
  final String? imageFilename;
  final String? imageMimeType;
  final Map<String, String> customFields;
  final bool isSaving;
  final bool isUploadingImage;
  final String? saveError;
  final bool savedSuccessfully;
  final int? savedCollectionId;

  bool get hasImage => imageBytes != null && imageBytes!.isNotEmpty;
  bool get isPublic => visibility == 'public';

  /// AI tags 合并到现有 tags（去重、规范化、限 10 个）。
  List<String> mergeTags(List<String> incoming) {
    final normalized = <String>{};
    for (final tag in [...tags, ...incoming]) {
      final t = _normalizeTag(tag);
      if (t.isNotEmpty) normalized.add(t);
    }
    return normalized.take(10).toList();
  }

  /// 单个添加 tag。
  List<String> addTag(String tag) {
    final t = _normalizeTag(tag);
    if (t.isEmpty || tags.contains(t) || tags.length >= 10) return tags;
    return [...tags, t];
  }

  /// 移除 tag。
  List<String> removeTag(String tag) {
    return tags.where((t) => t != tag).toList();
  }

  CollectionFormState copyWith({
    String? title,
    String? category,
    String? dateAcquired,
    String? location,
    String? story,
    List<String>? tags,
    String? visibility,
    int? roomId,
    List<int>? imageBytes,
    String? imageFilename,
    String? imageMimeType,
    Map<String, String>? customFields,
    bool? isSaving,
    bool? isUploadingImage,
    String? saveError,
    bool? savedSuccessfully,
    int? savedCollectionId,
    bool clearImage = false,
    bool clearError = false,
  }) {
    return CollectionFormState(
      title: title ?? this.title,
      category: category ?? this.category,
      dateAcquired: dateAcquired ?? this.dateAcquired,
      location: location ?? this.location,
      story: story ?? this.story,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      roomId: roomId ?? this.roomId,
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      imageFilename: clearImage ? null : (imageFilename ?? this.imageFilename),
      imageMimeType: clearImage ? null : (imageMimeType ?? this.imageMimeType),
      customFields: customFields ?? this.customFields,
      isSaving: isSaving ?? this.isSaving,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      saveError: clearError ? null : (saveError ?? this.saveError),
      savedSuccessfully: savedSuccessfully ?? this.savedSuccessfully,
      savedCollectionId:
          savedCollectionId ?? this.savedCollectionId,
    );
  }

  static String _normalizeTag(String raw) {
    return raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
