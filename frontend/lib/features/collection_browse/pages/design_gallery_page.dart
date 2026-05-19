import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../utils/collectory_room_catalog.dart';
import '../utils/gallery_layers.dart';
import '../widgets/collectory_handoff_header.dart';
import '../widgets/collection_wall_slivers.dart';
import '../widgets/design/collectory_top_bar.dart';
import '../widgets/design/layered_exhibit_tile.dart';
import '../widgets/design/room_selector_row.dart';

/// Figma Gallery — 首屏对齐 Room archive + 2×2 Layered gallery；向下滚动为 Collection wall
class DesignGalleryPage extends ConsumerStatefulWidget {
  const DesignGalleryPage({super.key});

  @override
  ConsumerState<DesignGalleryPage> createState() => _DesignGalleryPageState();
}

class _DesignGalleryPageState extends ConsumerState<DesignGalleryPage> {
  final _scrollController = ScrollController();
  final _collectionWallKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openLayerCategory(GalleryLayerSpec spec) {
    openGalleryWithCategory(ref, spec.categorySlugs.first);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _collectionWallKey.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          alignment: 0.02,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(collectionListProvider);
    final items = list.items;
    final total = list.total;
    final pad = CollectoryColors.screenPadding;
    final roomIndex = ref.watch(collectionRoomIndexProvider);
    final room = CollectoryRoomCatalog.forIndex(roomIndex);

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () =>
              ref.read(collectionListProvider.notifier).refresh(),
        ),
        SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CollectoryTopBar(contextTitle: 'Room archive'),
                  const _HairlineDivider(),
                  const SizedBox(height: 12),
                  Text(room.roomCode, style: CollectoryHandoffHeader.metaLabel()),
                  const SizedBox(height: 6),
                  Text(
                    room.archiveTitle,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: CollectoryColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    room.galleryBlurb,
                    style: CollectoryHandoffHeader.bodySecondary()
                        .copyWith(fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  RoomSelectorRow(
                    selectedIndex: roomIndex,
                    onSelect: (i) => openCollectionRoom(ref, roomIndex: i),
                  ),
                  const _HairlineDivider(margin: EdgeInsets.symmetric(vertical: 12)),
                  Text(
                    'Layered gallery',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: CollectoryColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Four object types, four layered walls.',
                    style: CollectoryHandoffHeader.bodySecondary()
                        .copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  if (list.loading && items.isEmpty)
                    const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: CollectoryColors.textLabel,
                        ),
                      ),
                    )
                  else
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.88,
                      children: [
                        for (final spec in galleryLayerSpecs)
                          Builder(
                            builder: (context) {
                              final item = pickLayerItem(items, spec);
                              return LayeredExhibitTile(
                                spec: spec,
                                item: item,
                                onTap: () => _openLayerCategory(spec),
                              );
                            },
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  const _HairlineDivider(),
                  const SizedBox(height: 12),
                  Row(
                    key: _collectionWallKey,
                    children: [
                      Expanded(
                        child: Text(
                          'Collection wall',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '$total exhibits',
                        style: CollectoryHandoffHeader.bodySecondary(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Search, filter, and browse all exhibits.',
                    style: CollectoryHandoffHeader.bodySecondary()
                        .copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          CollectionWallSlivers(
            scrollController: _scrollController,
            showWallHeader: false,
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider({this.margin});

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: const Divider(
        height: 1,
        thickness: 1,
        color: CollectoryColors.borderLight,
      ),
    );
  }
}
