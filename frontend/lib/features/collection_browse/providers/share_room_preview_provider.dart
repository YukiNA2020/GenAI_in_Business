import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Share settings → **Preview** 按钮传入访客预览页的选项。
class ShareRoomPreviewOptions {
  const ShareRoomPreviewOptions({
    this.linkSharing = true,
    this.showStories = true,
    this.showDates = true,
    this.hideNotes = true,
  });

  final bool linkSharing;
  final bool showStories;
  final bool showDates;
  final bool hideNotes;

  ShareRoomPreviewOptions copyWith({
    bool? linkSharing,
    bool? showStories,
    bool? showDates,
    bool? hideNotes,
  }) {
    return ShareRoomPreviewOptions(
      linkSharing: linkSharing ?? this.linkSharing,
      showStories: showStories ?? this.showStories,
      showDates: showDates ?? this.showDates,
      hideNotes: hideNotes ?? this.hideNotes,
    );
  }
}

final shareRoomPreviewOptionsProvider =
    StateProvider<ShareRoomPreviewOptions>((ref) {
  return const ShareRoomPreviewOptions();
});
