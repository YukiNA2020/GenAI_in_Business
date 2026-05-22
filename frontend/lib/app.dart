import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/layout/collectory_mobile_shell.dart';
import 'core/motion/collectory_motion.dart';
import 'core/theme/collectory_theme.dart';
import 'features/collection_browse/pages/add_exhibit_design_page.dart';
import 'features/collection_browse/pages/collection_detail_page.dart';
import 'features/collection_browse/pages/collection_room_page.dart';
import 'features/collection_browse/pages/design_gallery_page.dart';
import 'features/collection_browse/pages/edit_collection_page.dart';
import 'features/collection_browse/pages/layer_motion_page.dart';
import 'features/collection_browse/pages/museum_home_page.dart';
import 'features/collection_browse/pages/profile_design_page.dart';
import 'features/collection_browse/pages/public_collections_page.dart';
import 'features/collection_browse/pages/share_room_preview_page.dart';
import 'features/collection_browse/pages/share_room_settings_page.dart';
import 'features/collection_browse/providers/app_navigation_provider.dart';
import 'features/collection_browse/providers/collection_list_provider.dart';
import 'features/collection_browse/utils/collectory_room_catalog.dart';
import 'features/collection_browse/widgets/collectory_bottom_nav.dart';
import 'features/profile/models/user_profile.dart';
import 'features/profile/providers/profile_providers.dart';

/// handoff 四 Tab + 原型叠层 + Member 3 API 功能
class CollectoryApp extends ConsumerWidget {
  const CollectoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Collectory',
      theme: buildCollectoryTheme(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ColoredBox(
        color: const Color(0xFF1C1917),
        child: child ?? const SizedBox.shrink(),
      ),
      home: const Scaffold(
        backgroundColor: Color(0xFF1C1917),
        body: CollectoryMobileShell(child: _Member3Shell()),
      ),
    );
  }
}

class _Member3Shell extends ConsumerStatefulWidget {
  const _Member3Shell();

  @override
  ConsumerState<_Member3Shell> createState() => _Member3ShellState();
}

class _Member3ShellState extends ConsumerState<_Member3Shell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapApi(ref));
  }

  Future<void> _bootstrapApi(WidgetRef ref) async {
    final service = ref.read(collectionQueryServiceProvider);
    await Future.wait([
      ref.read(collectionArchiveProvider.notifier).refresh(),
      ref.read(collectionListProvider.notifier).refresh(),
    ]);
    if (!await service.checkHealth()) return;
    final demo = UserProfile.demo();
    ref.read(userProfileProvider.notifier).updateProfile(
          displayName: demo.displayName,
          bio: demo.bio,
        );
    ref.invalidate(userStatsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(allTagsProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(member3TabIndexProvider, (previous, next) {
      if (previous != null && previous != next && (next == 0 || next == 3)) {
        restoreMuseumCatalogForHomeProfile(ref);
      } else if (next == 1 && previous != 1) {
        ref.read(collectionRoomIndexProvider.notifier).state =
            CollectoryRoomCatalog.currentMonthRoomIndex();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          applyPendingGalleryWallCategory(ref);
        });
      }
    });

    final overlay = ref.watch(member3OverlayProvider);
    final detailId = ref.watch(detailCollectionIdProvider);
    final detailPublic = ref.watch(detailIsPublicViewProvider);
    final detailFromSharePreview = ref.watch(detailFromSharePreviewProvider);
    final tab = ref.watch(member3TabIndexProvider);
    final roomIndex = ref.watch(collectionRoomIndexProvider);

    final hideNav = overlay == Member3Overlay.layerMotion ||
        overlay == Member3Overlay.collectionRoom ||
        overlay == Member3Overlay.shareRoom ||
        overlay == Member3Overlay.editCollection ||
        overlay == Member3Overlay.publicBrowse ||
        (overlay == Member3Overlay.itemDetail && detailPublic);
    final navIndex = _navIndex(overlay, tab);

    return Scaffold(
      backgroundColor: CollectoryColors.bgApp,
      body: SizedBox.expand(
        child: AnimatedSwitcher(
          duration: CollectoryMotion.medium,
          reverseDuration: CollectoryMotion.fast,
          switchInCurve: CollectoryMotion.ease,
          switchOutCurve: CollectoryMotion.ease,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            fit: StackFit.expand,
            alignment: Alignment.topCenter,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          child: KeyedSubtree(
            key: ValueKey<String>(
              overlay == Member3Overlay.collectionRoom
                  ? 'collectionRoom_$roomIndex'
                  : '${overlay.name}_${detailId ?? 0}_$tab',
            ),
            child: _body(
              overlay,
              detailId,
              detailPublic,
              detailFromSharePreview,
              tab,
              roomIndex,
            ),
          ),
        ),
      ),
      bottomNavigationBar: hideNav
          ? null
          : CollectoryBottomNav(
              currentIndex: navIndex,
              onTap: (i) => onShellNavTap(ref, i),
            ),
      extendBody: false,
    );
  }

  int _navIndex(Member3Overlay overlay, int tab) {
    if (overlay == Member3Overlay.itemDetail ||
        overlay == Member3Overlay.editCollection) {
      return 1;
    }
    return tab.clamp(0, 3);
  }

  Widget _body(
    Member3Overlay overlay,
    int? detailId,
    bool detailPublic,
    bool detailFromSharePreview,
    int tab,
    int roomIndex,
  ) {
    switch (overlay) {
      case Member3Overlay.itemDetail:
        if (detailId == null) return const DesignGalleryPage();
        return CollectionDetailPage(
          collectionId: detailId,
          isPublicView: detailPublic,
          onBack: detailFromSharePreview
              ? () => closeDetailToSharePreview(ref)
              : detailPublic
                  ? () => closeDetailToPublicBrowse(ref)
                  : () => closeDetailToGallery(ref),
        );
      case Member3Overlay.editCollection:
        if (detailId == null) return const DesignGalleryPage();
        return EditCollectionPage(collectionId: detailId);
      case Member3Overlay.publicBrowse:
        return PublicCollectionsPage(onClose: () => closeMember3Overlay(ref));
      case Member3Overlay.collectionRoom:
        return CollectionRoomPage(
          key: ValueKey('collection-room-$roomIndex'),
          roomIndex: roomIndex,
        );
      case Member3Overlay.shareRoom:
        return const ShareRoomSettingsPage();
      case Member3Overlay.shareRoomPreview:
        return const ShareRoomPreviewPage();
      case Member3Overlay.layerMotion:
        return const LayerMotionPage();
      case Member3Overlay.none:
        switch (tab) {
          case 0:
            return const MuseumHomePage();
          case 1:
            return const DesignGalleryPage();
          case 2:
            return const AddExhibitDesignPage();
          default:
            return const ProfileDesignPage();
        }
    }
  }
}
