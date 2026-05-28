// 负责人：成员 E / 成员 5 — 阶段四：正式 Create 表单主体
// INTEGRATION_IMPLEMENTATION_PATH.md §7.3–7.5
// 所有字段通过 CollectionFormProvider 管理状态；AI 面板通过外部集成。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/models/collection_room.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';
import '../../collection_browse/widgets/design/collectory_favorite_tags.dart';
import '../../collection_browse/widgets/design/collectory_pill_toggle.dart';
import '../providers/collection_form_provider.dart';
import 'category_selector.dart';
import 'image_picker_field.dart';
import 'room_selector.dart';
import 'tag_input_field.dart';

/// 正式 Create flow 表单。AI 面板通过外部 [AiSuggestionPanel] 集成。
class CollectionForm extends ConsumerStatefulWidget {
  const CollectionForm({
    super.key,
    required this.rooms,
    this.onSaved,
    this.onCancel,
  });

  final List<CollectionRoomSummary> rooms;
  final void Function(int collectionId)? onSaved;
  final VoidCallback? onCancel;

  @override
  ConsumerState<CollectionForm> createState() => _CollectionFormState();
}

class _CollectionFormState extends ConsumerState<CollectionForm> {
  final _titleController = TextEditingController();
  final _storyController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  bool _titleSynced = false;
  bool _storySynced = false;

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _onTitleChanged(String value) {
    ref.read(collectionFormProvider.notifier).updateTitle(value);
  }

  void _onStoryChanged(String value) {
    ref.read(collectionFormProvider.notifier).updateStory(value);
  }

  void _onLocationChanged(String value) {
    ref.read(collectionFormProvider.notifier).updateLocation(value);
  }

  void _onDateChanged(String value) {
    ref.read(collectionFormProvider.notifier).updateDateAcquired(value);
  }

  Future<void> _save() async {
    final result = await ref.read(collectionFormProvider.notifier).save();
    if (result.id != null) {
      widget.onSaved?.call(result.id!);
    } else if (result.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
    }
  }

  InputDecoration _inputDecoration({String? hint, int maxLines = 1}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFFAF8F5),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: maxLines > 1 ? 12 : 11,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CollectoryColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CollectoryColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CollectoryColors.borderDark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(collectionFormProvider);

    // 同步 TextEditingController（初始或 AI 更新后）
    if (!_titleSynced && form.title.isNotEmpty) {
      _titleController.text = form.title;
      _titleSynced = true;
    }
    if (!_storySynced && form.story.isNotEmpty) {
      _storyController.text = form.story;
      _storySynced = true;
    }

    final pad = CollectoryColors.screenPadding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 头部栏
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
          child: Row(
            children: [
              TextButton(
                onPressed: widget.onCancel,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CollectoryColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Curator mode',
                  textAlign: TextAlign.center,
                  style: CollectoryHandoffHeader.bodySecondary()
                      .copyWith(fontSize: 14),
                ),
              ),
              FilledButton(
                onPressed: form.isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  backgroundColor: CollectoryColors.btnPrimaryBg,
                  foregroundColor: CollectoryColors.btnPrimaryText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  form.isSaving ? 'Saving…' : 'Save',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: CollectoryColors.borderLight),

        // 表单主体（可滚动）
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEW EXHIBIT',
                    style: CollectoryHandoffHeader.metaLabel()),
                const SizedBox(height: 6),
                Text(
                  'Capture the object, choose its room, and save the story.',
                  style: CollectoryHandoffHeader.bodySecondary()
                      .copyWith(fontSize: 13, height: 1.35),
                ),
                const SizedBox(height: 20),

                // 图片选择器
                ImagePickerField(
                  imageBytes: form.imageBytes,
                  imageFilename: form.imageFilename,
                  onImagePicked: ({
                        required List<int> bytes,
                        required String filename,
                        required String mimeType,
                      }) {
                        ref.read(collectionFormProvider.notifier).setImage(
                              bytes: bytes,
                              filename: filename,
                              mimeType: mimeType,
                            );
                      },
                  onClearImage: () {
                    ref.read(collectionFormProvider.notifier).clearImage();
                  },
                ),
                const SizedBox(height: 20),

                // 标题
                _FieldBlock(
                  label: 'EXHIBIT TITLE *',
                  child: TextField(
                    controller: _titleController,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: _inputDecoration(
                      hint: 'e.g. Signed vinyl, ticket, green fluorite',
                    ),
                    onChanged: _onTitleChanged,
                  ),
                ),
                const SizedBox(height: 12),

                // 分类
                _FieldBlock(
                  label: 'CATEGORY',
                  child: CategorySelector(
                    selectedSlug: form.category,
                    onChanged: (slug) {
                      ref
                          .read(collectionFormProvider.notifier)
                          .updateCategory(slug);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // 地点
                _FieldBlock(
                  label: 'LOCATION',
                  child: TextField(
                    controller: _locationController,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: _inputDecoration(
                      hint: 'e.g. Congo, Hong Kong, home shelf',
                    ),
                    onChanged: _onLocationChanged,
                  ),
                ),
                const SizedBox(height: 12),

                // 日期
                _FieldBlock(
                  label: 'DATE ACQUIRED',
                  child: TextField(
                    controller: _dateController,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: _inputDecoration(hint: 'YYYY-MM-DD'),
                    onChanged: _onDateChanged,
                  ),
                ),
                const SizedBox(height: 12),

                // Room
                _FieldBlock(
                  label: 'ROOM',
                  child: FormRoomSelector(
                    rooms: widget.rooms,
                    selectedRoomId: form.roomId,
                    allowNull: true,
                    onChanged: (roomId) {
                      ref
                          .read(collectionFormProvider.notifier)
                          .updateRoomId(roomId);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // 故事
                _FieldBlock(
                  label: 'STORY NOTE',
                  child: TextField(
                    controller: _storyController,
                    maxLines: 4,
                    minLines: 3,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: _inputDecoration(
                      hint: 'Why is this object meaningful?',
                      maxLines: 4,
                    ),
                    onChanged: _onStoryChanged,
                  ),
                ),
                const SizedBox(height: 16),

                // Tags（正式 Tag input — AI tags 写入此处）
                _FieldBlock(
                  label: 'TAGS',
                  child: TagInputField(
                    tags: form.tags,
                    onAddTag: (tag) {
                      ref.read(collectionFormProvider.notifier).addTag(tag);
                    },
                    onRemoveTag: (tag) {
                      ref
                          .read(collectionFormProvider.notifier)
                          .removeTag(tag);
                    },
                    maxTags: 10,
                  ),
                ),

                // 旧 Favorite tags 保留作为快速 category + rough tags（兼容）
                const SizedBox(height: 16),
                Text('QUICK CATEGORY',
                    style: CollectoryHandoffHeader.metaLabel()),
                const SizedBox(height: 6),
                CollectoryFavoriteTagRow(
                  activeTag:
                      CollectoryFavoriteTags.tagForCategorySlug(form.category),
                  onTagTap: (tag) {
                    final slug =
                        CollectoryFavoriteTags.categorySlugForTag(tag);
                    if (slug != null) {
                      ref
                          .read(collectionFormProvider.notifier)
                          .updateCategory(slug);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // 控制
                const Divider(height: 1, color: CollectoryColors.borderLight),
                const SizedBox(height: 16),
                Text('VISIBILITY',
                    style: CollectoryHandoffHeader.metaLabel()),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: CollectoryColors.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CollectoryColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Private museum',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: CollectoryColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              form.isPublic
                                  ? 'Visible in public browse'
                                  : 'Only you can see this exhibit',
                              style: CollectoryHandoffHeader.bodySecondary()
                                  .copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      CollectoryPillToggle(
                        value: !form.isPublic,
                        onChanged: () {
                          ref.read(collectionFormProvider.notifier).updateVisibility(
                                form.isPublic ? 'private' : 'public',
                              );
                        },
                      ),
                    ],
                  ),
                ),

                // 保存错误
                if (form.saveError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CollectoryColors.catTicket.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: CollectoryColors.textPrimary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            form.saveError!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: CollectoryColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CollectoryHandoffHeader.metaLabel()),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}
