// 负责人：成员 E / 成员 5 — 阶段四：正式表单状态管理
// INTEGRATION_IMPLEMENTATION_PATH.md §7.4

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collection_browse/providers/collection_list_provider.dart';
import '../../collection_browse/services/collection_query_service.dart';
import '../models/collection_form_state.dart';

final collectionFormProvider =
    StateNotifierProvider<CollectionFormNotifier, CollectionFormState>((ref) {
  return CollectionFormNotifier(ref);
});

class CollectionFormNotifier extends StateNotifier<CollectionFormState> {
  CollectionFormNotifier(this._ref) : super(const CollectionFormState());

  final Ref _ref;

  void updateTitle(String value) => state = state.copyWith(title: value);
  void updateCategory(String? value) =>
      state = state.copyWith(category: value);
  void updateDateAcquired(String value) =>
      state = state.copyWith(dateAcquired: value);
  void updateLocation(String value) =>
      state = state.copyWith(location: value);
  void updateStory(String value) => state = state.copyWith(story: value);
  void updateVisibility(String value) =>
      state = state.copyWith(visibility: value);
  void updateRoomId(int? value) => state = state.copyWith(roomId: value);

  void addTag(String tag) => state = state.copyWith(tags: state.addTag(tag));

  void removeTag(String tag) =>
      state = state.copyWith(tags: state.removeTag(tag));

  /// AI tags 合并入实际 tag input 状态。
  void mergeTags(List<String> incoming) =>
      state = state.copyWith(tags: state.mergeTags(incoming));

  void setImage({
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) {
    state = state.copyWith(
      imageBytes: bytes,
      imageFilename: filename,
      imageMimeType: mimeType,
    );
  }

  void clearImage() {
    state = state.copyWith(clearImage: true);
  }

  void updateCustomField(String key, String value) {
    final updated = Map<String, String>.from(state.customFields);
    if (value.trim().isEmpty) {
      updated.remove(key);
    } else {
      updated[key] = value.trim();
    }
    state = state.copyWith(customFields: updated);
  }

  void reset() {
    state = const CollectionFormState();
  }

  Future<({int? id, String? error})> save() async {
    final s = state;
    if (s.isSaving) return (id: null, error: null);

    if (s.title.trim().isEmpty) {
      return (id: null, error: 'Title is required');
    }

    state = s.copyWith(isSaving: true, clearError: true);
    try {
      final service = _ref.read(collectionQueryServiceProvider);
      final created = await service.createCollection(
        title: s.title.trim(),
        category: s.category,
        story: s.story.trim(),
        visibility: s.visibility,
        tags: s.tags,
        userId: demoUserId,
        roomId: s.roomId != null && s.roomId! > 0 ? s.roomId : null,
        dateAcquired: s.dateAcquired != null && s.dateAcquired!.trim().isNotEmpty
            ? s.dateAcquired!.trim()
            : null,
        location: s.location.trim().isNotEmpty ? s.location.trim() : null,
        categoryTemplate: s.category,
        customFields: s.customFields.isNotEmpty ? jsonEncode(s.customFields) : null,
      );

      // 图片上传（独立于主创建 — 失败不阻塞保存）
      if (s.hasImage) {
        state = state.copyWith(isUploadingImage: true);
        try {
          await service.uploadCollectionImage(
            created.id,
            bytes: s.imageBytes!,
            filename: s.imageFilename ?? 'photo.jpg',
          );
        } catch (_) {
          // 图片上传失败不阻塞 — 文本收藏已保存
          state = state.copyWith(
            isUploadingImage: false,
            saveError:
                'Exhibit saved, but photo upload failed. You can add it later.',
          );
        }
      }

      // invalidate 相关 providers
      _ref.invalidate(userStatsProvider);
      _ref.invalidate(roomsProvider);
      if (s.roomId != null && s.roomId! > 0) {
        _ref.invalidate(roomDetailProvider(s.roomId!));
      }
      await _ref.read(collectionListProvider.notifier).refresh();

      state = state.copyWith(
        isSaving: false,
        isUploadingImage: false,
        savedSuccessfully: true,
        savedCollectionId: created.id,
      );
      return (id: created.id, error: null);
    } on ApiException catch (e) {
      state = state.copyWith(
        isSaving: false,
        isUploadingImage: false,
        saveError: e.message,
      );
      return (id: null, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        isUploadingImage: false,
        saveError: e.toString(),
      );
      return (id: null, error: e.toString());
    }
  }
}
