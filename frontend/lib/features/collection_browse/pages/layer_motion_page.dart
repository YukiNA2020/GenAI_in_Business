import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/collectory_tokens.dart';
import '../../../core/theme/collectory_theme.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../utils/gallery_layers.dart';
import '../widgets/collectory_handoff_header.dart';
import '../widgets/design/collectory_divider.dart';
import '../widgets/design/collectory_top_bar.dart';
import '../widgets/design/layered_exhibit_tile.dart';
import '../widgets/design/room_selector_row.dart';

/// Figma Layer Motion — Gallery 拖拽动效
class LayerMotionPage extends ConsumerWidget {
  const LayerMotionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(collectionMuseumCatalogProvider).items;
    final pad = CollectoryColors.screenPadding;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => closeDetailToGallery(ref),
                ),
                const Expanded(
                  child: CollectoryTopBar(contextTitle: 'Room archive'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(pad, 8, pad, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ROOM 01', style: CollectoryHandoffHeader.metaLabel()),
                  const SizedBox(height: 6),
                  Text(
                    'May 2026 Archive',
                    style: CollectoryHandoffHeader.pageTitle().copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A monthly room for objects, tickets, minerals, and memories collected in May.',
                    style: CollectoryHandoffHeader.bodySecondary(),
                  ),
                  const SizedBox(height: 14),
                  const RoomSelectorRow(),
                  const CollectoryDivider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'Layered gallery',
                          style: CollectoryHandoffHeader.sectionTitle(),
                        ),
                      ),
                      Text(
                        'May collection',
                        style: CollectoryHandoffHeader.bodySecondary(),
                      ),
                    ],
                  ),
                  const SizedBox(height: CollectorySpacing.unit / 2),
                  Text(
                    'Drag a layered set to watch the panels shift.',
                    style: CollectoryHandoffHeader.bodySecondary(),
                  ),
                  const SizedBox(height: CollectorySpacing.cardPadding),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                    children: [
                      for (final spec in galleryLayerSpecs)
                        LayeredExhibitTile(
                          spec: spec,
                          item: pickLayerItem(items, spec),
                          onTap: () {
                            closeMember3Overlay(ref);
                            openGalleryWithCategory(
                              ref,
                              spec.categorySlugs.first,
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
