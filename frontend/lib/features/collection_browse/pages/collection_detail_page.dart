import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../../core/theme/collectory_tokens.dart';
import '../models/collection_item.dart'
    show CollectionItem, orderedCustomFieldEntries, parseCustomFields;
import '../models/collection_room.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../services/collection_query_service.dart';
import '../widgets/collectory_handoff_header.dart';
import '../widgets/collection_exhibit_image.dart';
import '../widgets/design/collectory_top_bar.dart';
import '../widgets/design/collectory_divider.dart';
import '../widgets/empty_collection_state.dart';
import '../widgets/loading_skeleton.dart';

/// Exhibit detail — 大图 + Story + 元数据（含地点 / 标签 / customFields）
class CollectionDetailPage extends ConsumerStatefulWidget {
  const CollectionDetailPage({
    super.key,
    required this.collectionId,
    this.isPublicView = false,
    this.onBack,
  });

  final int collectionId;
  final bool isPublicView;
  final VoidCallback? onBack;

  @override
  ConsumerState<CollectionDetailPage> createState() =>
      _CollectionDetailPageState();
}

class _CollectionDetailPageState extends ConsumerState<CollectionDetailPage> {
  CollectionItem? _item;
  Map<String, String> _categoryNames = {};
  List<String> _categoryFieldKeys = [];
  bool _loading = true;
  String? _error;
  bool _notFound = false;

  static const _featuredCardBg = Color(0xFFEBE4D8);
  static const _storyScrollThreshold = 280;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _notFound = false;
    });
    try {
      final service = ref.read(collectionQueryServiceProvider);
      final cats = await service.fetchCategories();
      final item = await service.fetchById(widget.collectionId);
      if (!mounted) return;
      List<String> categoryFieldKeys = [];
      if (item.category != null) {
        for (final c in cats) {
          if (c.id == item.category) {
            categoryFieldKeys = c.fields;
            break;
          }
        }
      }
      setState(() {
        _item = item;
        _categoryNames = {for (final c in cats) c.id: c.name};
        _categoryFieldKeys = categoryFieldKeys;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _notFound = e.code == 'NOT_FOUND';
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openEdit() {
    final item = _item;
    if (item == null) return;
    openEditCollection(ref, item.id);
  }

  Future<void> _confirmDelete() async {
    final item = _item;
    if (item == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete exhibit?'),
        content: Text('Remove "${item.title}" from your gallery?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFF8B3A2A)),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(collectionQueryServiceProvider).deleteById(item.id);
      ref.read(collectionListProvider.notifier).refresh();
      ref.invalidate(userStatsProvider);
      if (mounted) _handleBack();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (widget.isPublicView) {
      closeDetailToPublicBrowse(ref);
    } else {
      closeDetailToGallery(ref);
    }
  }

  Future<void> _shareExhibit() async {
    final item = _item;
    if (item == null) return;
    final link = 'https://collectory.app/exhibits/${item.id}';
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share exhibit'),
        content: SelectableText(link),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    if (raw.length >= 10) {
      final parts = raw.substring(0, 10).split('-');
      if (parts.length == 3) {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (m != null && d != null && m >= 1 && m <= 12) {
          return '${months[m - 1]} $d, ${parts[0]}';
        }
      }
    }
    return raw;
  }

  String _archiveLabel(String? dateAcquired) {
    if (dateAcquired == null || dateAcquired.length < 7) {
      return 'Collectory Archive';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final parts = dateAcquired.substring(0, 10).split('-');
    if (parts.length == 3) {
      final m = int.tryParse(parts[1]);
      if (m != null && m >= 1 && m <= 12) {
        return '${months[m - 1]} ${parts[0]} Archive';
      }
    }
    return 'Collectory Archive';
  }

  String _featuredCaption(CollectionItem item) {
    final story = item.story?.trim();
    if (story != null && story.isNotEmpty) {
      for (final sep in ['. ', '。', '! ', '！']) {
        final i = story.indexOf(sep);
        if (i > 16 && i < 140) {
          final end = i + (sep == '。' || sep == '！' ? 1 : sep.length);
          return story.substring(0, end).trim();
        }
      }
      if (story.length <= 100) return story;
      return '${story.substring(0, 97).trim()}…';
    }
    if (item.location != null && item.location!.isNotEmpty) {
      return 'Collected from ${item.location}.';
    }
    return 'Part of your Collectory gallery.';
  }

  String _typeLabel(String? category, String? categoryName) {
    if (category == 'vinyl') return 'Vinyl + ticket';
    if (categoryName != null && categoryName.isNotEmpty) {
      return categoryName;
    }
    switch (category) {
      case 'ticket':
        return 'Ticket';
      case 'postcard':
        return 'Postcard';
      case 'mineral':
        return 'Mineral';
      case 'crystal':
        return 'Crystal';
      case 'souvenir':
        return 'Souvenir';
      case 'stamp':
        return 'Stamp';
      default:
        return 'Collection';
    }
  }

  String _moodLabel(List<String> tags) {
    if (tags.length > 1) return tags[1];
    if (tags.isNotEmpty) return tags.first;
    return '—';
  }

  String _roomLabel(CollectionItem item, List<CollectionRoomSummary>? rooms) {
    final roomId = item.roomId;
    if (roomId == null) return 'Unassigned';
    final room = rooms?.where((r) => r.id == roomId).firstOrNull;
    if (room == null) return 'Room $roomId';
    final label = room.label?.trim().isNotEmpty == true ? room.label! : null;
    return label ?? room.month;
  }

  @override
  Widget build(BuildContext context) {
    final pad = CollectoryColors.screenPadding;

    if (_loading) {
      return const Column(
        children: [
          SafeArea(bottom: false, child: SizedBox(height: 48)),
          Expanded(child: DetailLoadingSkeleton()),
        ],
      );
    }

    if (_notFound) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: EmptyCollectionState(
            title: 'Exhibit not found',
            description: 'This exhibit is no longer in your gallery.',
            actionLabel: 'Back to gallery',
            onAction: _handleBack,
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final item = _item!;
    final publicView = widget.isPublicView;
    final rooms = ref.watch(roomsProvider).valueOrNull;
    final roomLabel = _roomLabel(item, rooms);
    final categoryName =
        item.category != null ? _categoryNames[item.category!] : null;
    final exhibitId = item.id.toString().padLeft(3, '0');
    final mood = _moodLabel(item.tags);
    final typeLabel = _typeLabel(item.category, categoryName);
    final caption = _featuredCaption(item);
    final custom = parseCustomFields(item.customFields);
    final customEntries = orderedCustomFieldEntries(custom, _categoryFieldKeys);
    final storyText = item.story?.isNotEmpty == true
        ? item.story!
        : 'No story saved for this exhibit yet.';
    final needsScroll = storyText.length > _storyScrollThreshold ||
        item.tags.isNotEmpty ||
        customEntries.isNotEmpty ||
        (item.location != null && item.location!.isNotEmpty);

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
            child: CollectoryBackBar(
              backLabel: publicView ? 'Public' : 'Gallery',
              centerTitle: publicView ? 'Public exhibit' : 'Exhibit detail',
              onBack: _handleBack,
              trailing: publicView
                  ? Material(
                      color: CollectoryColors.btnPrimaryBg,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(
                          Icons.ios_share,
                          color: CollectoryColors.btnPrimaryText,
                          size: 20,
                        ),
                        onPressed: _shareExhibit,
                      ),
                    )
                  : Material(
                      color: CollectoryColors.btnPrimaryBg,
                      shape: const CircleBorder(),
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: CollectoryColors.btnPrimaryText,
                        ),
                        color: CollectoryColors.bgCard,
                        onSelected: (v) {
                          if (v == 'edit') _openEdit();
                          if (v == 'delete') _confirmDelete();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: needsScroll
                ? const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  )
                : const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(pad, 20, pad, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  publicView
                      ? 'PUBLIC EXHIBIT · $exhibitId'
                      : 'EXHIBIT $exhibitId · ${roomLabel.toUpperCase()}',
                  style: CollectoryHandoffHeader.metaLabel(),
                ),
                if (publicView) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: CollectoryColors.catVinyl,
                        child: Text(
                          'T',
                          style: CollectoryHandoffHeader.sectionTitle()
                              .copyWith(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tong',
                              style: CollectoryHandoffHeader.sectionTitle()
                                  .copyWith(fontSize: 16),
                            ),
                            Text(
                              'Collectory museum',
                              style: CollectoryHandoffHeader.bodySecondary(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: CollectorySpacing.labelToTitleGap),
                Text(
                  item.title,
                  style: CollectoryHandoffHeader.pageTitle().copyWith(
                    fontSize: 34,
                    height: 1.12,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _archiveLabel(item.dateAcquired),
                  style: CollectoryHandoffHeader.bodySecondary(),
                ),
                if (categoryName != null && categoryName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    categoryName,
                    style: CollectoryHandoffHeader.metaLabel().copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: CollectorySpacing.sectionGap),
                _FeaturedExhibitCard(
                  item: item,
                  caption: caption,
                ),
                const CollectoryDivider(
                  margin: EdgeInsets.symmetric(
                    vertical: CollectorySpacing.sectionGap,
                  ),
                ),
                Text(
                  'Story',
                  style: CollectoryHandoffHeader.sectionTitle().copyWith(
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: CollectorySpacing.titleToBodyGap),
                Text(
                  storyText,
                  style: CollectoryHandoffHeader.body().copyWith(
                    color: CollectoryColors.textSecondary,
                  ),
                ),
                const SizedBox(height: CollectorySpacing.sectionGapLarge),
                if (!publicView)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _MetaBlock(label: 'ROOM', value: roomLabel),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _MetaBlock(
                          label: 'DATE',
                          value: _formatDate(item.dateAcquired),
                        ),
                      ),
                    ],
                  )
                else
                  _MetaBlock(
                    label: 'DATE',
                    value: _formatDate(item.dateAcquired),
                  ),
                const SizedBox(height: CollectorySpacing.sectionGap),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MetaBlock(label: 'TYPE', value: typeLabel),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _MetaBlock(label: 'MOOD', value: mood),
                    ),
                  ],
                ),
                if (item.location != null && item.location!.isNotEmpty) ...[
                  const SizedBox(height: CollectorySpacing.sectionGap),
                  _MetaBlock(label: 'LOCATION', value: item.location!),
                ],
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: CollectorySpacing.sectionGap),
                  _DetailTagsSection(tags: item.tags),
                ],
                if (customEntries.isNotEmpty) ...[
                  const SizedBox(height: CollectorySpacing.sectionGap),
                  ...customEntries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _MetaBlock(
                        label: e.key.toUpperCase(),
                        value: e.value,
                      ),
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

/// 主图卡片 — API 图片 + 灰色说明
class _FeaturedExhibitCard extends StatelessWidget {
  const _FeaturedExhibitCard({
    required this.item,
    required this.caption,
  });

  final CollectionItem item;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _CollectionDetailPageState._featuredCardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: CollectoryShadows.elevated,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: CollectionExhibitImage(
                item: item,
                fit: BoxFit.cover,
                iconSize: 96,
                borderRadius: BorderRadius.circular(10),
                overlayInitialOnly: false,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: CollectoryHandoffHeader.bodySecondary().copyWith(
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTagsSection extends StatelessWidget {
  const _DetailTagsSection({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TAGS',
          style: CollectoryHandoffHeader.metaLabel().copyWith(
            color: CollectoryColors.textSecondary,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map(_tagPill).toList(),
        ),
      ],
    );
  }

  static Widget _tagPill(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: CollectoryColors.borderLight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 11,
          color: CollectoryColors.textSecondary,
        ),
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CollectoryHandoffHeader.metaLabel().copyWith(
            color: CollectoryColors.textSecondary,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: CollectoryTypography.cardTitle.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
