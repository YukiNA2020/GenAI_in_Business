import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_item.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../providers/share_room_preview_provider.dart';
import '../widgets/collectory_handoff_header.dart';
import '../widgets/collection_exhibit_image.dart';
import '../widgets/design/collectory_top_bar.dart';

/// Share settings → **Preview**：访客看到的房间内容（随三项开关变化）。
class ShareRoomPreviewPage extends ConsumerWidget {
  const ShareRoomPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = CollectoryColors.screenPadding;
    final options = ref.watch(shareRoomPreviewOptionsProvider);
    final publicAsync = ref.watch(_sharePreviewPublicProvider);

    return ColoredBox(
      color: CollectoryColors.bgApp,
      child: SafeArea(
        child: publicAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: EdgeInsets.all(pad),
            child: Text('$e'),
          ),
          data: (items) {
            final visible = options.linkSharing
                ? items
                : <CollectionItem>[];

            return ListView(
              padding: EdgeInsets.fromLTRB(pad, 10, pad, 28),
              children: [
                CollectoryBackBar(
                  backLabel: 'Share',
                  centerTitle: 'Visitor preview',
                  onBack: () => closeSharePreviewToSettings(ref),
                ),
                const SizedBox(height: 14),
                Text(
                  'ROOM LINK PREVIEW',
                  style: CollectoryHandoffHeader.metaLabel(),
                ),
                const SizedBox(height: 6),
                Text(
                  'May 2026 Archive',
                  style: CollectoryHandoffHeader.pageTitle().copyWith(
                    fontSize: 26,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  options.linkSharing
                      ? 'This is what visitors see with your current share settings.'
                      : 'Room is private — visitors cannot open the link.',
                  style: CollectoryHandoffHeader.bodySecondary().copyWith(
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                if (!options.linkSharing)
                  _PrivateRoomNotice()
                else if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No public exhibits in this room yet.',
                      style: CollectoryHandoffHeader.bodySecondary(),
                    ),
                  )
                else
                  ...visible.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _VisitorExhibitCard(
                        item: item,
                        options: options,
                        onTap: () => openSharePreviewItemDetail(ref, item.id),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PrivateRoomNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE5D8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CollectoryColors.borderLight),
      ),
      child: Text(
        'Switch visibility to “Anyone with link” to preview the shared room.',
        style: CollectoryHandoffHeader.bodySecondary().copyWith(height: 1.4),
      ),
    );
  }
}

class _VisitorExhibitCard extends StatelessWidget {
  const _VisitorExhibitCard({
    required this.item,
    required this.options,
    required this.onTap,
  });

  final CollectionItem item;
  final ShareRoomPreviewOptions options;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tagsLine = item.tags.take(3).join(' · ');
    final dateLine = item.dateAcquired?.trim();

    return Material(
      color: CollectoryColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CollectoryColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: CollectionExhibitImage(
                      item: item,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: CollectoryColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      if (options.showDates &&
                          dateLine != null &&
                          dateLine.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          options.showDates && tagsLine.isNotEmpty
                              ? '$dateLine · $tagsLine'
                              : dateLine,
                          style: CollectoryHandoffHeader.bodySecondary()
                              .copyWith(fontSize: 11),
                        ),
                      ] else if (options.showDates &&
                          tagsLine.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tagsLine,
                          style: CollectoryHandoffHeader.bodySecondary()
                              .copyWith(fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 6),
                      if (options.showStories &&
                          item.story != null &&
                          item.story!.trim().isNotEmpty)
                        Text(
                          item.story!.trim(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: CollectoryHandoffHeader.bodySecondary()
                              .copyWith(fontSize: 12, height: 1.35),
                        )
                      else if (!options.showStories)
                        Text(
                          'Story hidden from visitors',
                          style: CollectoryHandoffHeader.bodySecondary()
                              .copyWith(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: CollectoryColors.textLabel,
                          ),
                        ),
                      if (!options.hideNotes) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Private note visible in preview',
                          style: CollectoryHandoffHeader.bodySecondary()
                              .copyWith(
                            fontSize: 10,
                            color: const Color(0xFF8B3A2A),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final _sharePreviewPublicProvider =
    FutureProvider<List<CollectionItem>>((ref) {
  return ref.read(collectionQueryServiceProvider).fetchPublicCollections();
});
