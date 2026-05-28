// 负责人：成员 E / 成员 5 — 阶段四：正式 Create 页
// INTEGRATION_IMPLEMENTATION_PATH.md §7 — AI tags 写入正式 Tag input，不再仅 SnackBar
// Add Tab（Tab 2）指向此页；旧 AddExhibitDesignPage 保留为手测入口。

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/providers/app_navigation_provider.dart';
import '../../collection_browse/providers/collection_list_provider.dart';
import '../../collection_browse/utils/collectory_room_catalog.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';
import '../../collection_browse/widgets/design/collectory_favorite_tags.dart';
import '../../collection_browse/widgets/design/collectory_pill_toggle.dart';
import '../models/ai_form_payload.dart';
import '../models/collection_form_state.dart';
import '../providers/collection_form_provider.dart';
import '../utils/ai_category_mapping.dart';
import '../widgets/ai_suggestion_panel.dart';
import '../widgets/category_selector.dart';
import '../widgets/image_picker_field.dart';
import '../widgets/room_selector.dart';
import '../widgets/tag_input_field.dart';

/// 正式 Create 页 — 成员 B 表单 + 成员 E AI 面板整合。
/// AI tags 通过 [CollectionFormNotifier.mergeTags] 写入正式 TagInputField。
class CreateCollectionPage extends ConsumerStatefulWidget {
  const CreateCollectionPage({super.key});

  @override
  ConsumerState<CreateCollectionPage> createState() =>
      _CreateCollectionPageState();
}

class _CreateCollectionPageState extends ConsumerState<CreateCollectionPage> {
  final _titleController = TextEditingController();
  final _storyController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  String? _storyGenerationSeed;
  String? _lastAiGeneratedStory;

  void _rememberStorySeed(String value) {
    final seed = value.trim();
    _storyGenerationSeed = seed.isEmpty ? null : seed;
    _lastAiGeneratedStory = null;
  }

  String? _storyContextForAiPayload(CollectionFormState form) {
    final story = form.story.trim();
    final seed = _storyGenerationSeed?.trim();
    final lastGenerated = _lastAiGeneratedStory?.trim();

    if (story.isEmpty) {
      return seed?.isNotEmpty == true ? seed : null;
    }

    if (lastGenerated != null && story == lastGenerated) {
      return seed?.isNotEmpty == true ? seed : null;
    }

    _rememberStorySeed(story);
    return story;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(collectionFormProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String? get _imageDataUrl {
    final s = ref.read(collectionFormProvider);
    if (s.imageBytes == null || s.imageBytes!.isEmpty) return null;
    final mime = s.imageMimeType ?? 'image/jpeg';
    return 'data:$mime;base64,${base64Encode(s.imageBytes!)}';
  }

  Future<void> _handleSave() async {
    final result = await ref.read(collectionFormProvider.notifier).save();
    if (!mounted) return;
    if (result.id != null) {
      ref.read(collectionFormProvider.notifier).reset();
      _titleController.clear();
      _storyController.clear();
      _locationController.clear();
      _dateController.clear();
      _storyGenerationSeed = null;
      _lastAiGeneratedStory = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exhibit created successfully')),
      );
      openItemDetail(ref, result.id!);
    } else if (result.error != null) {
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
    final list = ref.watch(collectionListProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final fallbackRooms =
        CollectoryRoomCatalog.fallbackSummaries(items: list.items);
    final roomOptions = roomsAsync.maybeWhen(
      data: (rooms) => rooms.isNotEmpty ? rooms : fallbackRooms,
      error: (_, __) => fallbackRooms,
      orElse: () => roomsAsync.valueOrNull ?? fallbackRooms,
    );
    final pad = CollectoryColors.screenPadding;

    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, 8, pad, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 头部栏
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(member3TabIndexProvider.notifier).state = 1;
                  },
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
                  onPressed: form.isSaving ? null : _handleSave,
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
            const _HairlineDivider(),
            const SizedBox(height: 8),

            // 可滚动表单体
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('NEW EXHIBIT',
                        style: CollectoryHandoffHeader.metaLabel()),
                    const SizedBox(height: 6),
                    Text(
                      'Capture the object, choose its room, and save the story.',
                      style: CollectoryHandoffHeader.bodySecondary()
                          .copyWith(fontSize: 13, height: 1.35),
                    ),
                    const SizedBox(height: 14),

                    // 图片选择区
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
                    const SizedBox(height: 14),

                    // 标题
                    _FieldBlock(
                      label: 'EXHIBIT TITLE *',
                      child: TextField(
                        controller: _titleController,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: _inputDecoration(
                          hint: 'e.g. Signed vinyl, ticket, green fluorite',
                        ),
                        onChanged: (v) {
                          ref
                              .read(collectionFormProvider.notifier)
                              .updateTitle(v);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

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
                    const SizedBox(height: 10),

                    // 地点 + 日期 并行
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _FieldBlock(
                            label: 'LOCATION',
                            child: TextField(
                              controller: _locationController,
                              style: GoogleFonts.inter(fontSize: 14),
                              decoration: _inputDecoration(
                                hint: 'e.g. Hong Kong',
                              ),
                              onChanged: (v) {
                                ref
                                    .read(collectionFormProvider.notifier)
                                    .updateLocation(v);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _FieldBlock(
                            label: 'DATE ACQUIRED',
                            child: TextField(
                              controller: _dateController,
                              style: GoogleFonts.inter(fontSize: 14),
                              decoration: _inputDecoration(hint: 'YYYY-MM-DD'),
                              onChanged: (v) {
                                ref
                                    .read(collectionFormProvider.notifier)
                                    .updateDateAcquired(v);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Room
                    _FieldBlock(
                      label: 'ROOM',
                      child: FormRoomSelector(
                        rooms: roomOptions,
                        selectedRoomId: form.roomId,
                        allowNull: true,
                        onChanged: (roomId) {
                          ref
                              .read(collectionFormProvider.notifier)
                              .updateRoomId(roomId);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 故事
                    _FieldBlock(
                      label: 'STORY NOTE',
                      child: TextField(
                        controller: _storyController,
                        maxLines: 3,
                        minLines: 2,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: _inputDecoration(
                          hint: 'Why is this object meaningful?',
                          maxLines: 3,
                        ),
                        onChanged: (v) {
                          ref
                              .read(collectionFormProvider.notifier)
                              .updateStory(v);
                          _rememberStorySeed(v);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // AI 面板（§7.4 — callbacks 写正式表单状态）
                    AiSuggestionPanel(
                      hasImageForAnalysis: () => _imageDataUrl != null,
                      buildPayload: () {
                        final currentForm = ref.read(collectionFormProvider);
                        final storyContext =
                            _storyContextForAiPayload(currentForm);
                        final titleContext = currentForm.title.trim();
                        return AiFormPayload(
                          description: storyContext ??
                              (titleContext.isNotEmpty
                                  ? titleContext
                                  : 'collectible'),
                          title: currentForm.title.isNotEmpty
                              ? currentForm.title
                              : null,
                          category: currentForm.category != null
                              ? apiSlugToAiCategory[currentForm.category]
                              : null,
                          location: currentForm.location.isNotEmpty
                              ? currentForm.location
                              : null,
                          dateAcquired:
                              currentForm.dateAcquired?.isNotEmpty == true
                                  ? currentForm.dateAcquired
                                  : null,
                          imageDescription: storyContext,
                          imageDataUrl: _imageDataUrl,
                        );
                      },
                      onImageAnalysisApplied: (result) {
                        final n = ref.read(collectionFormProvider.notifier);
                        n.updateTitle(result.suggestedTitle);
                        _titleController.text = result.suggestedTitle;
                        final tag =
                            tagLabelForAiCategory(result.suggestedCategory);
                        if (tag != null) {
                          final slug =
                              CollectoryFavoriteTags.categorySlugForTag(tag);
                          if (slug != null) n.updateCategory(slug);
                        }
                        n.updateStory(result.description);
                        _storyController.text = result.description;
                        _rememberStorySeed(result.description);
                        // §7.4 — AI tags 写入正式 Tag input
                        n.mergeTags(result.suggestedTags);
                      },
                      onTitleSelected: (title) {
                        ref
                            .read(collectionFormProvider.notifier)
                            .updateTitle(title);
                        _titleController.text = title;
                      },
                      onCategoryTagSelected: (tag) {
                        final slug =
                            CollectoryFavoriteTags.categorySlugForTag(tag);
                        if (slug != null) {
                          ref
                              .read(collectionFormProvider.notifier)
                              .updateCategory(slug);
                        }
                      },
                      onTagsSuggested: (tags) {
                        // §7.4 — AI tags 写入正式 Tag input，不再仅 SnackBar
                        ref
                            .read(collectionFormProvider.notifier)
                            .mergeTags(tags);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tags added: ${tags.join(', ')}'),
                          ),
                        );
                      },
                      onStoryApplied: (story) {
                        _lastAiGeneratedStory =
                            story.trim().isEmpty ? null : story.trim();
                        ref
                            .read(collectionFormProvider.notifier)
                            .updateStory(story);
                        _storyController.text = story;
                      },
                      onStoryStyleChange: () {
                        _storyContextForAiPayload(
                          ref.read(collectionFormProvider),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Tags — 正式 Tag Input（AI tags 写入此处）
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
                    const SizedBox(height: 14),

                    // Quick category（旧 Favorite tags 兼容）
                    Text('QUICK CATEGORY',
                        style: CollectoryHandoffHeader.metaLabel()),
                    const SizedBox(height: 6),
                    CollectoryFavoriteTagRow(
                      activeTag: CollectoryFavoriteTags.tagForCategorySlug(
                          form.category),
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
                    const SizedBox(height: 18),

                    // 可见性
                    const _HairlineDivider(),
                    const SizedBox(height: 10),
                    Text('VISIBILITY',
                        style: CollectoryHandoffHeader.metaLabel()),
                    const SizedBox(height: 6),
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
                              ref
                                  .read(collectionFormProvider.notifier)
                                  .updateVisibility(
                                    form.isPublic ? 'private' : 'public',
                                  );
                            },
                          ),
                        ],
                      ),
                    ),

                    // 保存错误
                    if (form.saveError != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CollectoryColors.catTicket
                              .withValues(alpha: 0.15),
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

                    // 底部留白
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: CollectoryColors.borderLight,
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
