import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_room.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../providers/member3_ui_settings_provider.dart';
import '../services/collection_query_service.dart';
import '../utils/collectory_room_catalog.dart';
import '../widgets/collectory_handoff_header.dart';
import '../../collection_form/models/ai_form_payload.dart';
import '../../collection_form/models/ai_image_analysis.dart';
import '../../collection_form/utils/ai_category_mapping.dart';
import '../../collection_form/widgets/ai_suggestion_panel.dart';
import '../widgets/design/collectory_favorite_tags.dart';
import '../widgets/design/collectory_pill_toggle.dart';
import '../widgets/design/exhibit_illustrations.dart';

/// Figma Collectory - Add New Exhibit — 单屏无滚动
/// AI 建议面板挂钩：成员 E / 成员 5（阶段二·任务五），供成员 B 后续迁入正式 Create 页
class AddExhibitDesignPage extends ConsumerStatefulWidget {
  const AddExhibitDesignPage({super.key});

  @override
  ConsumerState<AddExhibitDesignPage> createState() =>
      _AddExhibitDesignPageState();
}

class _AddExhibitDesignPageState extends ConsumerState<AddExhibitDesignPage> {
  final _titleController = TextEditingController();
  final _storyController = TextEditingController();
  String _activeTag = CollectoryFavoriteTags.labels.first;
  bool _saving = false;
  String? _imageDescription;
  String? _pendingAiTagsNote;
  static const ExhibitIconKind _demoPhotoKind = ExhibitIconKind.vinyl;

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _saveDraft() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final selectedRoomId = ref.read(selectedRoomIdProvider);
      final apiRoomId =
          selectedRoomId != null && selectedRoomId > 0 ? selectedRoomId : null;
      await ref.read(collectionQueryServiceProvider).createCollection(
            title: title,
            story: _storyController.text,
            category: CollectoryFavoriteTags.categorySlugForTag(_activeTag),
            visibility:
                ref.read(addPrivateMuseumProvider) ? 'private' : 'public',
            userId: demoUserId,
            roomId: apiRoomId,
          );
      ref.invalidate(userStatsProvider);
      ref.invalidate(roomsProvider);
      ref.invalidate(allCollectionsProvider);
      if (apiRoomId != null) {
        ref.invalidate(roomDetailProvider(apiRoomId));
      }
      await ref.read(collectionListProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exhibit saved via API')),
      );
      cancelAddToRoom(ref);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFFAF8F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
    final privateMuseum = ref.watch(addPrivateMuseumProvider);
    final list = ref.watch(collectionListProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final fallbackRooms =
        CollectoryRoomCatalog.fallbackSummaries(items: list.items);
    final roomOptions = roomsAsync.maybeWhen(
      data: (rooms) => rooms.isNotEmpty ? rooms : fallbackRooms,
      error: (_, __) => fallbackRooms,
      orElse: () => roomsAsync.valueOrNull ?? fallbackRooms,
    );
    final selectedRoomId = ref.watch(selectedRoomIdProvider);
    final activeRoomId = selectedRoomId != null &&
            roomOptions.any((room) => room.id == selectedRoomId)
        ? selectedRoomId
        : roomOptions.firstOrNull?.id;
    if (activeRoomId != null && activeRoomId != selectedRoomId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(selectedRoomIdProvider.notifier).state = activeRoomId;
      });
    }
    final pad = CollectoryColors.screenPadding;
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, 8, pad, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () => cancelAddToRoom(ref),
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
                OutlinedButton(
                  onPressed: _saving ? null : _saveDraft,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    minimumSize: const Size(0, 30),
                    side: const BorderSide(color: CollectoryColors.borderDark),
                    foregroundColor: CollectoryColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    _saving ? 'Saving…' : 'Draft',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const _HairlineDivider(),
            const SizedBox(height: 12),
            Text('NEW EXHIBIT', style: CollectoryHandoffHeader.metaLabel()),
            const SizedBox(height: 6),
            Text(
              'Add a new exhibit.',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: CollectoryColors.textPrimary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Capture the object, choose its monthly room, and save the story before it fades.',
              style: CollectoryHandoffHeader.bodySecondary()
                  .copyWith(fontSize: 13, height: 1.35),
            ),
            const Spacer(flex: 2),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CollectoryColors.bgSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ExhibitIcon(kind: _demoPhotoKind, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add photo or scan',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: CollectoryColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Use camera, gallery, or scan a ticket/mineral label.',
                          style: CollectoryHandoffHeader.bodySecondary()
                              .copyWith(fontSize: 11, height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _imageDescription =
                                    _mockImageDescriptionForKind(
                                  _demoPhotoKind,
                                );
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Demo photo attached — tap Recognize in AI panel.',
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 30),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              backgroundColor: CollectoryColors.btnPrimaryBg,
                              foregroundColor: CollectoryColors.btnPrimaryText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Upload',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            _FieldBlock(
              label: 'EXHIBIT TITLE',
              child: TextField(
                controller: _titleController,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: _inputDecoration(
                  hint: 'e.g. Signed vinyl, ticket, green fluorite',
                ),
              ),
            ),
            const SizedBox(height: 8),
            _FieldBlock(
              label: 'ROOM',
              child: _RoomDropdown(
                rooms: roomOptions,
                selectedRoomId: activeRoomId,
                decoration: _inputDecoration(hint: 'Choose a room'),
                onChanged: (roomId) {
                  if (roomId == null) return;
                  ref.read(selectedRoomIdProvider.notifier).state = roomId;
                },
              ),
            ),
            const SizedBox(height: 8),
            _FieldBlock(
              label: 'STORY NOTE',
              child: TextField(
                controller: _storyController,
                maxLines: 2,
                minLines: 2,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: _inputDecoration(
                  hint: 'Why is this object meaningful?',
                ),
              ),
            ),
            const SizedBox(height: 8),
            AiSuggestionPanel(
              hasImageForAnalysis: () =>
                  (_imageDescription?.trim().isNotEmpty ?? false),
              buildPayload: () {
                final slug =
                    CollectoryFavoriteTags.categorySlugForTag(_activeTag);
                final note = _storyController.text.trim();
                return AiFormPayload(
                  description:
                      note.isEmpty ? (_imageDescription ?? 'collectible photo') : note,
                  title: _titleController.text.trim().isEmpty
                      ? null
                      : _titleController.text.trim(),
                  category:
                      slug == null ? null : apiSlugToAiCategory[slug],
                  imageDescription: _imageDescription,
                );
              },
              onImageAnalysisApplied: _applyImageAnalysis,
              onTitleSelected: (title) {
                _titleController.text = title;
              },
              onCategoryTagSelected: (tag) {
                setState(() => _activeTag = tag);
              },
              onTagsSuggested: (tags) {
                setState(() {
                  _pendingAiTagsNote = tags.join(' · ');
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('AI tags: ${tags.join(', ')}')),
                );
              },
              onStoryApplied: (story) {
                _storyController.text = story;
              },
              onStoryReset: () {
                _storyController.clear();
              },
            ),
            if (_pendingAiTagsNote != null) ...[
              const SizedBox(height: 4),
              Text(
                'AI tags: $_pendingAiTagsNote',
                style: CollectoryHandoffHeader.bodySecondary()
                    .copyWith(fontSize: 10),
              ),
            ],
            const Spacer(flex: 2),
            Text('TAGS', style: CollectoryHandoffHeader.metaLabel()),
            const SizedBox(height: 8),
            CollectoryFavoriteTagRow(
              activeTag: _activeTag,
              onTagTap: (tag) => setState(() => _activeTag = tag),
            ),
            const Spacer(flex: 3),
            const _HairlineDivider(),
            const SizedBox(height: 8),
            Text('VISIBILITY', style: CollectoryHandoffHeader.metaLabel()),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Private museum',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: CollectoryColors.textPrimary,
                    ),
                  ),
                ),
                CollectoryPillToggle(
                  value: privateMuseum,
                  onChanged: () {
                    ref.read(addPrivateMuseumProvider.notifier).state =
                        !privateMuseum;
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _HairlineDivider(),
          ],
        ),
      ),
    );
  }

  void _applyImageAnalysis(AiImageAnalysis result) {
    _titleController.text = result.suggestedTitle;
    final tag = tagLabelForAiCategory(result.suggestedCategory);
    setState(() {
      if (tag != null) _activeTag = tag;
      _storyController.text = result.description;
      _pendingAiTagsNote = result.suggestedTags.join(' · ');
      _imageDescription = result.description;
    });
  }

  static String _mockImageDescriptionForKind(ExhibitIconKind kind) {
    return switch (kind) {
      ExhibitIconKind.ticket => 'A faded exhibition ticket photo with slightly worn edges and clear printed text',
      ExhibitIconKind.vinyl => 'A vinyl record cover with saturated colors and a visible central circular label',
      ExhibitIconKind.mineral => 'A close-up of a natural mineral specimen with crystal reflections on the surface',
      _ => 'A collectible item photo with soft lighting, suitable for category recognition',
    };
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

class _RoomDropdown extends StatelessWidget {
  const _RoomDropdown({
    required this.rooms,
    required this.selectedRoomId,
    required this.decoration,
    required this.onChanged,
  });

  final List<CollectionRoomSummary> rooms;
  final int? selectedRoomId;
  final InputDecoration decoration;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final value =
        rooms.any((room) => room.id == selectedRoomId) ? selectedRoomId : null;
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration: decoration,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
      items: [
        for (final room in rooms)
          DropdownMenuItem<int>(
            value: room.id,
            child: Text(
              _labelFor(room),
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: CollectoryColors.textPrimary,
              ),
            ),
          ),
      ],
      onChanged: rooms.isEmpty ? null : onChanged,
    );
  }

  String _labelFor(CollectionRoomSummary room) {
    final label = room.label ?? room.month;
    final count = room.collectionCount;
    if (count == null) return '$label · ${room.month}';
    return '$label · ${room.month} · $count exhibits';
  }
}
