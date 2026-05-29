import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_form/models/ai_form_payload.dart';
import '../../collection_form/services/ai_suggestion_service.dart';
import '../models/collection_item.dart';
import '../models/collection_room.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../services/collection_query_service.dart';
import '../utils/collectory_room_catalog.dart';
import '../widgets/collectory_handoff_header.dart';
import '../widgets/collection_exhibit_image.dart';
import '../widgets/design/collectory_favorite_tags.dart';
import '../widgets/design/collectory_pill_toggle.dart';
import '../widgets/design/exhibit_illustrations.dart';

/// 编辑展品 — 对接 PUT /api/collections/:id 与 POST …/image
class EditCollectionPage extends ConsumerStatefulWidget {
  const EditCollectionPage({
    super.key,
    required this.collectionId,
  });

  final int collectionId;

  @override
  ConsumerState<EditCollectionPage> createState() => _EditCollectionPageState();
}

class _EditCollectionPageState extends ConsumerState<EditCollectionPage> {
  final _titleController = TextEditingController();
  final _storyController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();

  CollectionItem? _item;
  String _activeTag = CollectoryFavoriteTags.labels.first;
  bool _privateMuseum = true;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingImage = false;
  String? _error;
  int _imageVersion = 0;
  int? _selectedRoomId;

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final item = await ref
          .read(collectionQueryServiceProvider)
          .fetchById(widget.collectionId);
      if (!mounted) return;
      _applyItem(item);
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyItem(CollectionItem item) {
    _item = item;
    _titleController.text = item.title;
    _storyController.text = item.story ?? '';
    _locationController.text = item.location ?? '';
    _dateController.text = item.dateAcquired ?? '';
    _activeTag = CollectoryFavoriteTags.tagForCategorySlug(item.category);
    if (item.tags.isNotEmpty) {
      final match = CollectoryFavoriteTags.labels
          .where((l) => item.tags.contains(l))
          .toList();
      if (match.isNotEmpty) _activeTag = match.first;
    }
    _privateMuseum = item.visibility != 'public';
    _selectedRoomId = item.roomId;
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

  Future<void> _suggestStory() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add a title first for story suggestions')),
      );
      return;
    }
    final tag = _activeTag.toLowerCase();
    final payload = AiFormPayload(
      description: _storyController.text.trim().isNotEmpty
          ? _storyController.text.trim()
          : title,
      title: title,
      category: tag,
      location:
          _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      dateAcquired:
          _dateController.text.trim().isNotEmpty ? _dateController.text.trim() : null,
    );
    try {
      final story = await ref.read(aiSuggestionServiceProvider).generateStory(payload);
      if (!mounted) return;
      setState(() => _storyController.text = story);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Story generation failed: $e')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read image file')),
      );
      return;
    }
    setState(() => _uploadingImage = true);
    try {
      final updated =
          await ref.read(collectionQueryServiceProvider).uploadCollectionImage(
                widget.collectionId,
                bytes: bytes,
                filename: file.name.isNotEmpty ? file.name : 'photo.jpg',
              );
      if (!mounted) return;
      setState(() {
        _item = updated;
        _imageVersion++;
        _uploadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo updated')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _uploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final category =
          CollectoryFavoriteTags.categorySlugForTag(_activeTag) ?? 'mineral';
      final previousRoomId = _item?.roomId;
      final apiRoomId = _selectedRoomId != null && _selectedRoomId! > 0
          ? _selectedRoomId
          : null;
      final updated =
          await ref.read(collectionQueryServiceProvider).updateCollection(
                widget.collectionId,
                title: title,
                category: category,
                story: _storyController.text.trim(),
                location: _locationController.text.trim(),
                dateAcquired: _dateController.text.trim(),
                visibility: _privateMuseum ? 'private' : 'public',
                tags: [_activeTag],
                roomId: apiRoomId,
              );
      ref.invalidate(userStatsProvider);
      ref.invalidate(roomsProvider);
      ref.invalidate(allCollectionsProvider);
      if (previousRoomId != null && previousRoomId > 0) {
        ref.invalidate(roomDetailProvider(previousRoomId));
      }
      if (apiRoomId != null) {
        ref.invalidate(roomDetailProvider(apiRoomId));
      }
      await ref.read(collectionListProvider.notifier).refresh();
      if (!mounted) return;
      setState(() {
        _item = updated;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exhibit saved')),
      );
      openItemDetail(ref, widget.collectionId);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  ExhibitIconKind _iconKindForTag(String tag) {
    return switch (tag) {
      'Music' => ExhibitIconKind.vinyl,
      'Ticket' => ExhibitIconKind.ticket,
      'Mineral' => ExhibitIconKind.mineral,
      _ => ExhibitIconKind.memory,
    };
  }

  @override
  Widget build(BuildContext context) {
    final pad = CollectoryColors.screenPadding;

    if (_loading) {
      return const ColoredBox(
        color: CollectoryColors.bgApp,
        child: Center(
          child: CircularProgressIndicator(color: CollectoryColors.textLabel),
        ),
      );
    }

    if (_error != null) {
      return ColoredBox(
        color: CollectoryColors.bgApp,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    final item = _item!;
    final list = ref.watch(collectionListProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final fallbackRooms =
        CollectoryRoomCatalog.fallbackSummaries(items: list.items);
    final roomOptions = roomsAsync.maybeWhen(
      data: (rooms) => rooms.isNotEmpty ? rooms : fallbackRooms,
      error: (_, __) => fallbackRooms,
      orElse: () => roomsAsync.valueOrNull ?? fallbackRooms,
    );

    return ColoredBox(
      color: CollectoryColors.bgApp,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => openItemDetail(ref, widget.collectionId),
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
                    onPressed: _saving ? null : _save,
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
                      _saving ? 'Saving…' : 'Save',
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EDIT EXHIBIT',
                        style: CollectoryHandoffHeader.metaLabel()),
                    const SizedBox(height: 6),
                    Text(
                      'Refine the story, tags, and visibility of this piece.',
                      style: CollectoryHandoffHeader.bodySecondary()
                          .copyWith(fontSize: 13, height: 1.35),
                    ),
                    const SizedBox(height: 20),
                    _PhotoCard(
                      item: item,
                      imageVersion: _imageVersion,
                      uploading: _uploadingImage,
                      fallbackIcon: _iconKindForTag(_activeTag),
                      onChangePhoto: _pickAndUploadImage,
                    ),
                    const SizedBox(height: 20),
                    _FieldBlock(
                      label: 'EXHIBIT TITLE',
                      child: TextField(
                        controller: _titleController,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: _inputDecoration(
                          hint: 'Name of this object',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldBlock(
                      label: 'LOCATION',
                      child: TextField(
                        controller: _locationController,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: _inputDecoration(
                          hint: 'e.g. Congo, Hong Kong, home shelf',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldBlock(
                      label: 'DATE ACQUIRED',
                      child: TextField(
                        controller: _dateController,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: _inputDecoration(hint: 'YYYY-MM-DD'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldBlock(
                      label: 'ROOM',
                      child: _RoomDropdown(
                        rooms: roomOptions,
                        selectedRoomId: _selectedRoomId,
                        decoration: _inputDecoration(hint: 'Choose a room'),
                        onChanged: (roomId) {
                          setState(() => _selectedRoomId = roomId);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AiAssistCard(onSuggest: _suggestStory),
                    const SizedBox(height: 20),
                    Text('TAGS', style: CollectoryHandoffHeader.metaLabel()),
                    const SizedBox(height: 8),
                    CollectoryFavoriteTagRow(
                      activeTag: _activeTag,
                      onTagTap: (tag) => setState(() => _activeTag = tag),
                    ),
                    const SizedBox(height: 24),
                    const Divider(
                        height: 1, color: CollectoryColors.borderLight),
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
                                  _privateMuseum
                                      ? 'Only you can see this exhibit'
                                      : 'Visible in public browse',
                                  style: CollectoryHandoffHeader.bodySecondary()
                                      .copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          CollectoryPillToggle(
                            value: _privateMuseum,
                            onChanged: () {
                              setState(() => _privateMuseum = !_privateMuseum);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ID ${item.id} · ${item.category ?? 'uncategorized'}',
                      style: CollectoryHandoffHeader.bodySecondary()
                          .copyWith(fontSize: 11),
                    ),
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

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.item,
    required this.imageVersion,
    required this.uploading,
    required this.fallbackIcon,
    required this.onChangePhoto,
  });

  final CollectionItem item;
  final int imageVersion;
  final bool uploading;
  final ExhibitIconKind fallbackIcon;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CollectoryColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CollectoryColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 168,
            child: Stack(
              fit: StackFit.expand,
              children: [
                KeyedSubtree(
                  key: ValueKey('edit-photo-$imageVersion-${item.imageUrl}'),
                  child: CollectionExhibitImage(
                    item: item,
                    borderRadius: BorderRadius.zero,
                    overlayInitialOnly: false,
                  ),
                ),
                if (uploading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ExhibitIcon(kind: fallbackIcon, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exhibit photo',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: CollectoryColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Replace the thumbnail shown in your gallery and detail view.',
                        style: CollectoryHandoffHeader.bodySecondary()
                            .copyWith(fontSize: 11, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: uploading ? null : onChangePhoto,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    side: const BorderSide(color: CollectoryColors.borderDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    uploading ? '…' : 'Change',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiAssistCard extends StatelessWidget {
  const _AiAssistCard({required this.onSuggest});

  final VoidCallback onSuggest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F0E8), Color(0xFFEDE6DC)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CollectoryColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CollectoryColors.btnPrimaryBg.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              size: 22,
              color: CollectoryColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Story assistant',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CollectoryColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Draft a curator note from your title and tag — you can edit before saving.',
                  style: CollectoryHandoffHeader.bodySecondary()
                      .copyWith(fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onSuggest,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Suggest story draft',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CollectoryColors.textPrimary,
                      decoration: TextDecoration.underline,
                      decorationColor: CollectoryColors.textLabel,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
