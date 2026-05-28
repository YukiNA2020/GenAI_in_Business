import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/collection_query_state.dart';
import 'collection_list_provider.dart';
import '../widgets/design/collectory_favorite_tags.dart';

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

/// Gallery / Profile 选中的 room ID（来自 /api/rooms）
final selectedRoomIdProvider = StateProvider<int?>((ref) => null);

/// 打开 Collection room 前的 Tab，用于返回
final collectionRoomOriginTabProvider = StateProvider<int>((ref) => 0);
final pendingCollectionWallScrollProvider = StateProvider<bool>((ref) => false);

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
  ref.read(member3OverlayProvider.notifier).state =
      Member3Overlay.editCollection;
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
  goToGalleryTab(ref, scrollToCollectionWall: true);
}

void goToGalleryTab(
  WidgetRef ref, {
  String? categorySlug,
  int? year,
  int? month,
  String? tag,
  bool scrollToCollectionWall = false,
}) {
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = 1;
  if (scrollToCollectionWall) {
    ref.read(pendingCollectionWallScrollProvider.notifier).state = true;
  }
  if (categorySlug != null || year != null || month != null || tag != null) {
    ref.read(collectionListProvider.notifier).updateFilters(
      keyword: '',
      category: categorySlug,
      clearCategory: categorySlug == null,
      tag: tag,
      clearTag: tag == null,
      year: year,
      clearYear: year == null,
      month: month,
      clearMonth: month == null,
      sortBy: SortOption.newest,
    );
  } else {
    ref.read(collectionListProvider.notifier).refresh();
  }
}

void goToHomeTab(WidgetRef ref) {
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = 0;
}

void goToProfileTab(WidgetRef ref) {
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = 3;
}

/// Gallery / Profile 同月 room（同 [roomId]）进入同一 Collection room 页
void openCollectionRoom(WidgetRef ref, {required int roomId}) {
  ref.read(selectedRoomIdProvider.notifier).state = roomId;
  ref.read(collectionRoomOriginTabProvider.notifier).state =
      ref.read(member3TabIndexProvider);
  ref.read(member3OverlayProvider.notifier).state =
      Member3Overlay.collectionRoom;
}

/// 仅切换 Gallery 顶部 room 选中态（不打开叠层）
void selectCollectionRoomMonth(WidgetRef ref, int roomId) {
  ref.read(selectedRoomIdProvider.notifier).state = roomId;
}

void openShareRoom(WidgetRef ref) {
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.shareRoom;
}

void openLayerMotion(WidgetRef ref) {
  ref.read(member3OverlayProvider.notifier).state = Member3Overlay.layerMotion;
}

/// Home: Tickets/Memories/Minerals/Vinyl → Gallery + category filter
void openGalleryWithCategory(WidgetRef ref, String categorySlug) {
  goToGalleryTab(
    ref,
    categorySlug: categorySlug,
    scrollToCollectionWall: true,
  );
}

void openGalleryWithFavoriteTag(WidgetRef ref, String favoriteTagLabel) {
  final categorySlug = CollectoryFavoriteTags.categorySlugForTag(favoriteTagLabel);
  goToGalleryTab(
    ref,
    categorySlug: categorySlug,
    scrollToCollectionWall: true,
  );
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
  ref.read(member3OverlayProvider.notifier).state =
      Member3Overlay.shareRoomPreview;
}

/// Collection Room: Back → 进入 room 前的 Tab（Home / Gallery / Profile）
void closeCollectionRoom(WidgetRef ref) {
  final origin = ref.read(collectionRoomOriginTabProvider);
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = origin;
}

@Deprecated('Use closeCollectionRoom')
void closeRoomToHome(WidgetRef ref) => closeCollectionRoom(ref);

/// Share Room: Back → Profile
void closeShareToProfile(WidgetRef ref) {
  closeMember3Overlay(ref);
  ref.read(member3TabIndexProvider.notifier).state = 3;
}

/// Add: Draft/Cancel → Collection Room
void cancelAddToRoom(WidgetRef ref) {
  ref.read(member3TabIndexProvider.notifier).state = 2;
  ref.read(member3OverlayProvider.notifier).state =
      Member3Overlay.collectionRoom;
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
    ref.read(collectionListProvider.notifier).refresh();
  }
}
