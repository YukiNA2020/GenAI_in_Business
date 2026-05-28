import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_tokens.dart';
import '../../../core/theme/collectory_theme.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../utils/collectory_room_catalog.dart';
import '../widgets/design/collectory_top_bar.dart';
import '../widgets/design/museum_hall_scene.dart';
import '../widgets/design/museum_home_layout_spec.dart';

/// 严格对齐 Figma Mobile.png
class MuseumHomePage extends ConsumerWidget {
  const MuseumHomePage({super.key});

  static TextStyle get _personalMuseumLabel => GoogleFonts.inter(
        fontSize: MuseumHomeLayoutSpec.personalLabelSize,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.65,
        color: CollectoryColors.textLabel,
        decoration: TextDecoration.none,
      );

  static TextStyle get _homeHeadline => GoogleFonts.inter(
        fontSize: MuseumHomeLayoutSpec.heroTitleSize,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.2,
        color: CollectoryColors.textPrimary,
        decoration: TextDecoration.none,
      );

  static TextStyle get _homeSubcopy => GoogleFonts.inter(
        fontSize: MuseumHomeLayoutSpec.heroSubtitleSize,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: CollectoryColors.textSecondary,
        decoration: TextDecoration.none,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItems = ref.watch(allCollectionsProvider).valueOrNull;
    final exhibitCount = allItems != null
        ? CollectoryRoomCatalog.mayRoomExhibitCount(allItems)
        : ref.watch(roomsProvider).maybeWhen(
            data: (rooms) {
              final may = rooms
                  .where((r) => r.month.startsWith('2026-05'))
                  .firstOrNull;
              return may?.collectionCount ?? rooms.firstOrNull?.collectionCount;
            },
            orElse: () => null,
          );
    final firstRoomId = ref.watch(roomsProvider).maybeWhen(
          data: (rooms) =>
              rooms.where((r) => r.month.startsWith('2026-05')).firstOrNull?.id ??
              rooms.firstOrNull?.id,
          orElse: () => CollectoryRoomCatalog.fallbackRoomIdForIndex(0),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: MuseumHallScene(
                  onTickets: () => openGalleryWithCategory(ref, 'ticket'),
                  onMemories: () => openGalleryWithCategory(ref, 'postcard'),
                  onMinerals: () => openGalleryWithCategory(ref, 'mineral'),
                  onVinyl: () => openGalleryWithCategory(ref, 'vinyl'),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      CollectorySpacing.screenHorizontal,
                      4,
                      CollectorySpacing.screenHorizontal,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: MuseumHomeLayoutSpec.topBarHeight,
                          child: CollectoryTopBar(contextTitle: 'Museum hall'),
                        ),
                        const SizedBox(
                            height: MuseumHomeLayoutSpec.afterTopBarGap),
                        Text('PERSONAL MUSEUM', style: _personalMuseumLabel),
                        const SizedBox(
                            height: MuseumHomeLayoutSpec.labelToTitleGap),
                        Text('Enter your collection hall.',
                            style: _homeHeadline),
                        const SizedBox(
                            height: MuseumHomeLayoutSpec.titleLineGap),
                        Text('Start with one object.', style: _homeHeadline),
                        const SizedBox(
                            height: MuseumHomeLayoutSpec.titleToSubtitleGap),
                        Text('Tap a collection type.', style: _homeSubcopy),
                        const SizedBox(
                            height: MuseumHomeLayoutSpec.subtitleLineGap),
                        Text(
                          'View that filter in your gallery.',
                          style: _homeSubcopy,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ColoredBox(
          color: MuseumHomeLayoutSpec.roomBandColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              CollectorySpacing.screenHorizontal,
              MuseumHomeLayoutSpec.roomBandPaddingV,
              CollectorySpacing.screenHorizontal,
              MuseumHomeLayoutSpec.roomBandPaddingV,
            ),
            child: _HomeRoomCard(
              exhibitCount: exhibitCount,
              onOpenRoom: () {
                if (firstRoomId != null) {
                  openCollectionRoom(ref, roomId: firstRoomId);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Mobile.png：ROOM 01 左上 + meta 右上；标题左下；Open room 右下
class _HomeRoomCard extends StatelessWidget {
  const _HomeRoomCard({
    required this.exhibitCount,
    required this.onOpenRoom,
  });

  final int? exhibitCount;
  final VoidCallback onOpenRoom;

  @override
  Widget build(BuildContext context) {
    final meta = exhibitCount != null
        ? '$exhibitCount exhibits · AI reflection ready'
        : 'Loading exhibits…';

    return Material(
      color: MuseumHomeLayoutSpec.roomCardColor,
      borderRadius: BorderRadius.circular(CollectoryRadius.card),
      elevation: 0,
      child: InkWell(
        onTap: onOpenRoom,
        splashColor: Colors.transparent,
        borderRadius: BorderRadius.circular(CollectoryRadius.card),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: MuseumHomeLayoutSpec.roomCardMinHeight,
          ),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CollectoryRadius.card),
            border: Border.all(color: CollectoryColors.borderLight),
            boxShadow: CollectoryShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROOM 01',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.55,
                      color: CollectoryColors.textLabel,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      meta,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                        color: CollectoryColors.textSecondary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'May 2026 Archive',
                      style: GoogleFonts.inter(
                        fontSize: MuseumHomeLayoutSpec.roomTitleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: CollectoryColors.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: onOpenRoom,
                    style: FilledButton.styleFrom(
                      backgroundColor: CollectoryColors.btnPrimaryBg,
                      foregroundColor: CollectoryColors.btnPrimaryText,
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    child: const Text('Open room'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
