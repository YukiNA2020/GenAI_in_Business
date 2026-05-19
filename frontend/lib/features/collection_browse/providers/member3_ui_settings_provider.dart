import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'share_room_preview_provider.dart';

/// Profile → Museum visibility preview toggle (survives tab / overlay switches).
final profilePublicPreviewProvider = StateProvider<bool>((ref) => false);

/// Add exhibit → Private museum toggle.
final addPrivateMuseumProvider = StateProvider<bool>((ref) => true);

/// Share settings reads/writes [shareRoomPreviewOptionsProvider] so Preview
/// round-trip does not reset toggles.

void updateShareRoomPreview(
  WidgetRef ref, {
  bool? linkSharing,
  bool? showStories,
  bool? showDates,
  bool? hideNotes,
}) {
  final current = ref.read(shareRoomPreviewOptionsProvider);
  ref.read(shareRoomPreviewOptionsProvider.notifier).state = current.copyWith(
    linkSharing: linkSharing,
    showStories: showStories,
    showDates: showDates,
    hideNotes: hideNotes,
  );
}
