import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/models/user_profile.dart';
import '../../profile/providers/profile_providers.dart';
import '../utils/collectory_room_catalog.dart';
import '../widgets/design/collectory_favorite_tags.dart';
import 'collection_list_provider.dart';

/// 叠层 — 对齐 collectory-ui-handoff.md 原型逻辑
enum Member3Overlay {
  none,
  itemDetail,
  editCollection,
  publicBrowse,
  collectionRoom,
  shareRoom,
  shareRoomPreview,
  layerMotion,
}

final member3OverlayProvider =
    StateProvider<Member3Overlay>((ref) => Member3Overlay.none);

final detailCollectionIdProvider = StateProvider<int?>((ref) => null);

/// True when detail was opened from [PublicCollectionsPage] (visitor view).
final detailIsPublicViewProvider = StateProvider<bool>((ref) => false);

/// True when detail was opened from [ShareRoomPreviewPage].
final detailFromSharePreviewProvider = StateProvider<bool>((ref) => false);

/// 0=Home 1=Gallery 2=Add 3=Profile
final member3TabIndexProvider = StateProvider<int>((ref) => 0);

/// Gallery / Profile 选中的月度 room：0=May 1=Jun 2=Jul
final collectionRoomIndexProvider = StateProvider<int>((ref) => 0);

/// 打开 Collection room 前的 Tab，用于返回
final collectionRoomOriginTabProvider = StateProvider<int>((ref) => 0);

/// Home/Profile room → Open wall：仅按 room 年月筛选，不用 Gallery 分类/标签筛选
final collectionRoomWallFilterProvider =
    StateProvider<CollectoryRoomSpec?>((ref) => null);

/// Home hall 四选一 → 仅在 Gallery Tab 应用，不写入 archive
final pendingGalleryWallCategoryProvider = StateProvider<String?>((ref) => null);

/// Room Open wall / Home 种类 / Profile tag → Gallery 后自动滚到 Collection wall
final pendingGalleryScrollToWallProvider = StateProvider<bool>((ref) => false);

void requestGalleryScrollToCollectionWall(WidgetRef ref) {
  ref.read(pendingGalleryScrollToWallProvider.notifier).state = true;
}

void openItemDetail(WidgetRef ref, int collectionId) {
  ref.read(detailIsPublicViewProvider.notifier).state = false;
  ref.read(detailCollectionIdProvider.notifier).state = collectionId;
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.itemDetail;
}

void openPublicItemDetail(WidgetRef ref, int collectionId) {
  ref.read(detailFromSharePreviewProvider.notifier).state = false;
  ref.read(detailIsPublicViewProvider.notifier).state = true;
  ref.read(detailCollectionIdProvider.notifier).state = collectionId;
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.itemDetail;
}

void openSharePreviewItemDetail(WidgetRef ref, int collectionId) {
  ref.read(detailFromSharePreviewProvider.notifier).state = true;
  ref.read(detailIsPublicViewProvider.notifier).state = true;
  ref.read(detailCollectionIdProvider.notifier).state = collectionId;
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.itemDetail;
}

void openEditCollection(WidgetRef ref, int collectionId) {
  ref.read(detailCollectionIdProvider.notifier).state = collectionId;
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.editCollection;
}

void openPublicBrowse(WidgetRef ref) {
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.publicBrowse;
}

/// Share settings → Preview（访客预览，非设置页内嵌 preview）
void openShareRoomPreview(WidgetRef ref) {
  ref.read(member3OverlayProvider.notifier).state =
      Member3Overlay.shareRoomPreview;
}

void closeSharePreviewToSettings(WidgetRef ref) {
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.shareRoom;
}

/// handoff: Open wall → Gallery View（成员 3 收藏墙在 Gallery Tab 内）
void openCollectionWall(WidgetRef ref) {
  goToGalleryTab(ref);
}

void goToGalleryTab(WidgetRef ref, {String? categorySlug}) {
  ref.read(collectionRoomWallFilterProvider.notifier).state = null;
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = 1;
  requestGalleryScrollToCollectionWall(ref);
  if (categorySlug != null) {
    ref.read(collectionListProvider.notifier).updateFilters(
          category: categorySlug,
          clearCategory: false,
        );
  } else {
    ref.read(collectionListProvider.notifier).refresh();
  }
}

/// Home / Profile room → Gallery Collection wall（预选该 room 年月）
void openCollectionWallForRoom(WidgetRef ref, {required int roomIndex}) {
  final room = CollectoryRoomCatalog.forIndex(roomIndex);
  ref.read(collectionRoomIndexProvider.notifier).state = room.index;
  ref.read(collectionRoomWallFilterProvider.notifier).state = null;
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = 1;
  requestGalleryScrollToCollectionWall(ref);
  ref
      .read(collectionListProvider.notifier)
      .applyWallDateFilter(year: room.year, month: room.month)
      .then((_) {
    requestGalleryScrollToCollectionWall(ref);
  });
}

void restoreMuseumCatalogForHomeProfile(WidgetRef ref) {
  ref.read(pendingGalleryWallCategoryProvider.notifier).state = null;
  ref.read(pendingGalleryScrollToWallProvider.notifier).state = false;
  ref.read(collectionRoomWallFilterProvider.notifier).state = null;
  ref.read(collectionListProvider.notifier).resetWallFilters();
  final demo = UserProfile.demo();
  ref.read(userProfileProvider.notifier).updateProfile(
        displayName: demo.displayName,
        bio: demo.bio,
      );
  ref.read(collectionArchiveProvider.notifier).refresh();
}

void goToHomeTab(WidgetRef ref) {
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = 0;
  restoreMuseumCatalogForHomeProfile(ref);
}

void goToProfileTab(WidgetRef ref) {
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = 3;
  restoreMuseumCatalogForHomeProfile(ref);
}

/// Gallery / Profile 同月 room（同 [roomIndex]）进入同一 Collection room 页
void openCollectionRoom(WidgetRef ref, {required int roomIndex}) {
  final i = roomIndex.clamp(0, CollectoryRoomCatalog.rooms.length - 1);
  ref.read(collectionRoomIndexProvider.notifier).state = i;
  ref.read(collectionRoomOriginTabProvider.notifier).state =
      ref.read(member3TabIndexProvider);
  ref.read(collectionArchiveProvider.notifier).refresh();
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.collectionRoom;
}

/// 仅切换 Gallery 顶部 room 选中态（不打开叠层）
void selectCollectionRoomMonth(WidgetRef ref, int roomIndex) {
  ref.read(collectionRoomIndexProvider.notifier).state =
      roomIndex.clamp(0, CollectoryRoomCatalog.rooms.length - 1);
}

void openShareRoom(WidgetRef ref) {
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.shareRoom;
}

void openLayerMotion(WidgetRef ref) {
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.layerMotion;
}

/// Home hall: Tickets / Memories / Minerals / Vinyl → Gallery + wall category chip.
void openHomeHallCategoryInGalleryWall(
  WidgetRef ref,
  String categorySlug,
) {
  ref.read(collectionRoomWallFilterProvider.notifier).state = null;
  ref.read(pendingGalleryWallCategoryProvider.notifier).state = null;
  requestGalleryScrollToCollectionWall(ref);
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = 1;
  applyGalleryWallCategoryFilter(ref, categorySlug);
}

/// Profile Favorite tags → Gallery Collection wall（不在 Profile 内筛选）
void openProfileFavoriteTagInGalleryWall(WidgetRef ref, String tagLabel) {
  final slug = CollectoryFavoriteTags.categorySlugForTag(tagLabel);
  if (slug == null) return;
  openHomeHallCategoryInGalleryWall(ref, slug);
}

/// Collection wall only — select category chip and reload (not archive).
void applyGalleryWallCategoryFilter(WidgetRef ref, String categorySlug) {
  ref.read(collectionRoomWallFilterProvider.notifier).state = null;
  ref.read(collectionListProvider.notifier).updateFilters(
        category: categorySlug,
        clearCategory: false,
        clearTag: true,
        keyword: '',
      );
}

/// Apply [pendingGalleryWallCategoryProvider] on Gallery tab (wall only).
void applyPendingGalleryWallCategory(WidgetRef ref) {
  final slug = ref.read(pendingGalleryWallCategoryProvider);
  if (slug == null) return;
  ref.read(pendingGalleryWallCategoryProvider.notifier).state = null;
  applyGalleryWallCategoryFilter(ref, slug);
}

/// Gallery layered tiles / layer motion → same wall-only category filter.
void openGalleryWithCategory(WidgetRef ref, String categorySlug) {
  final onGalleryTab = ref.read(member3TabIndexProvider) == 1 &&
      ref.read(member3OverlayProvider) == Member3Overlay.none;
  if (onGalleryTab) {
    ref.read(pendingGalleryWallCategoryProvider.notifier).state = null;
    applyGalleryWallCategoryFilter(ref, categorySlug);
    requestGalleryScrollToCollectionWall(ref);
    return;
  }
  openHomeHallCategoryInGalleryWall(ref, categorySlug);
}

/// Item Detail: Back → Gallery View
void closeDetailToGallery(WidgetRef ref) {
  ref.read(detailIsPublicViewProvider.notifier).state = false;
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = 1;
}

/// Public detail: Back → Public browse overlay
void closeDetailToPublicBrowse(WidgetRef ref) {
  ref.read(detailIsPublicViewProvider.notifier).state = false;
  ref.read(detailFromSharePreviewProvider.notifier).state = false;
  ref.read(detailCollectionIdProvider.notifier).state = null;
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.publicBrowse;
}

/// Share preview detail: Back → Visitor preview
void closeDetailToSharePreview(WidgetRef ref) {
  ref.read(detailIsPublicViewProvider.notifier).state = false;
  ref.read(detailFromSharePreviewProvider.notifier).state = false;
  ref.read(detailCollectionIdProvider.notifier).state = null;
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.shareRoomPreview;
}

/// Collection Room: Back → 进入 room 前的 Tab（Home / Gallery / Profile）
void closeCollectionRoom(WidgetRef ref) {
  final origin = ref.read(collectionRoomOriginTabProvider);
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = origin;
  if (origin == 0 || origin == 3) {
    restoreMuseumCatalogForHomeProfile(ref);
  }
}

@Deprecated('Use closeCollectionRoom')
void closeRoomToHome(WidgetRef ref) => closeCollectionRoom(ref);

/// Share Room: Back → Profile
void closeShareToProfile(WidgetRef ref) {
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = 3;
  restoreMuseumCatalogForHomeProfile(ref);
}

/// Add: Draft/Cancel → Collection Room
void cancelAddToRoom(WidgetRef ref) {
  ref.read(member3TabIndexProvider.notifier).state = 2;
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.collectionRoom;
}

void closeMember3Overlay(WidgetRef ref) {
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.none;
  ref.read(detailCollectionIdProvider.notifier).state = null;
  ref.read(detailIsPublicViewProvider.notifier).state = false;
  ref.read(detailFromSharePreviewProvider.notifier).state = false;
}

/// 底部导航切换（handoff：叠层页也可切 Tab）
void onShellNavTap(WidgetRef ref, int index) {
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = index;
  if (index == 1) {
    applyPendingGalleryWallCategory(ref);
  }
}
