import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/collection_list_provider.dart';
import '../providers/member3_ui_settings_provider.dart';
import '../providers/share_room_preview_provider.dart';
import '../widgets/collectory_handoff_header.dart';
import '../widgets/design/collectory_pill_toggle.dart';
import '../widgets/design/collectory_top_bar.dart';
import '../widgets/design/exhibit_illustrations.dart';

/// Figma Collectory - Share Room Settings / Mobile.png
/// 单屏无滚动、无翻页。
class ShareRoomSettingsPage extends ConsumerWidget {
  const ShareRoomSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(shareRoomPreviewOptionsProvider);
    final pad = CollectoryColors.screenPadding;
    final statsAsync = ref.watch(userStatsProvider);

    if (statsAsync.isLoading && !statsAsync.hasValue) {
      return const ColoredBox(
        color: CollectoryColors.bgApp,
        child: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final stats = statsAsync.asData?.value ?? demoUserStatsFallback;
    final storyCount = stats.recentCollections
        .where((e) => e.story?.isNotEmpty == true)
        .length;
    final exhibits =
        stats.totalCollections > 0 ? stats.totalCollections : 24;
    final stories = storyCount > 0 ? storyCount : 3;

    return ColoredBox(
      color: CollectoryColors.bgApp,
      child: SafeArea(
        child: SizedBox.expand(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 10, pad, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CollectoryBackBar(
                      backLabel: 'Room',
                      centerTitle: 'Share settings',
                      onBack: () => closeShareToProfile(ref),
                      trailing: FilledButton(
                        onPressed: () => closeShareToProfile(ref),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'ROOM SHARING',
                      style: CollectoryHandoffHeader.metaLabel(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Share May 2026 Archive',
                      style: CollectoryHandoffHeader.pageTitle().copyWith(
                        fontSize: 28,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose what visitors can see before creating a room link.',
                      style: CollectoryHandoffHeader.bodySecondary().copyWith(
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _RoomPreviewCard(
                      exhibitCount: exhibits,
                      storyCount: stories,
                      showStories: options.showStories,
                    ),
                    const Spacer(flex: 2),
                    Text(
                      'Visibility',
                      style: CollectoryHandoffHeader.sectionTitle().copyWith(
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _VisibilityOption(
                      title: 'Private',
                      subtitle: 'Only you can view this room',
                      selected: !options.linkSharing,
                      onTap: () =>
                          updateShareRoomPreview(ref, linkSharing: false),
                    ),
                    const SizedBox(height: 8),
                    _VisibilityOption(
                      title: 'Anyone with link',
                      subtitle: 'Visitors can open the room link',
                      selected: options.linkSharing,
                      dark: true,
                      onTap: () =>
                          updateShareRoomPreview(ref, linkSharing: true),
                    ),
                    const Spacer(flex: 2),
                    Text(
                      'Include in shared room',
                      style: CollectoryHandoffHeader.sectionTitle().copyWith(
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _ShareToggleRow(
                      label: 'Show item stories',
                      value: options.showStories,
                      onChanged: () => updateShareRoomPreview(
                        ref,
                        showStories: !options.showStories,
                      ),
                    ),
                    _ShareToggleRow(
                      label: 'Show dates + tags',
                      value: options.showDates,
                      onChanged: () => updateShareRoomPreview(
                        ref,
                        showDates: !options.showDates,
                      ),
                    ),
                    _ShareToggleRow(
                      label: 'Hide private notes',
                      value: options.hideNotes,
                      onChanged: () => updateShareRoomPreview(
                        ref,
                        hideNotes: !options.hideNotes,
                      ),
                    ),
                    const Spacer(flex: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: CollectoryColors.room01,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CollectoryColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'collectory.app/room/may-2026',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: CollectoryColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            'Link ready',
                            style: CollectoryHandoffHeader.metaLabel().copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              Clipboard.setData(
                                const ClipboardData(
                                  text: 'https://collectory.app/room/may-2026',
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Link copied')),
                              );
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text('Copy link'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => openShareRoomPreview(ref),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 46),
                              foregroundColor: CollectoryColors.textPrimary,
                              side: const BorderSide(
                                color: CollectoryColors.borderLight,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text('Preview'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

class _RoomPreviewCard extends StatelessWidget {
  const _RoomPreviewCard({
    required this.exhibitCount,
    required this.storyCount,
    required this.showStories,
  });

  final int exhibitCount;
  final int storyCount;
  final bool showStories;

  String get _summaryLine {
    final buf = StringBuffer('$exhibitCount exhibits');
    if (showStories) {
      buf.write(' · $storyCount stories selected');
    } else {
      buf.write(' · stories hidden');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE5D8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CollectoryColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ROOM 01', style: CollectoryHandoffHeader.metaLabel()),
                const SizedBox(height: 3),
                Text(
                  'May 2026 Archive',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CollectoryColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _summaryLine,
                  style: CollectoryHandoffHeader.bodySecondary().copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const _RoomPreviewArt(),
        ],
      ),
    );
  }
}

/// PNG 右侧小拼贴
class _RoomPreviewArt extends StatelessWidget {
  const _RoomPreviewArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 10,
            child: ExhibitIcon(kind: ExhibitIconKind.vinyl, size: 30),
          ),
          Positioned(
            left: 24,
            top: 0,
            child: ExhibitIcon(kind: ExhibitIconKind.ticket, size: 28),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: ExhibitIcon(kind: ExhibitIconKind.mineral, size: 30),
          ),
        ],
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  const _VisibilityOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.dark = false,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final isDarkSelected = dark && selected;
    final bg = isDarkSelected
        ? CollectoryColors.btnPrimaryBg
        : CollectoryColors.bgApp;
    final titleColor = isDarkSelected
        ? CollectoryColors.btnPrimaryText
        : CollectoryColors.textPrimary;
    final subtitleColor = isDarkSelected
        ? const Color(0xFFB8B0A8)
        : CollectoryColors.textSecondary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDarkSelected
                  ? CollectoryColors.btnPrimaryBg
                  : (selected
                      ? CollectoryColors.borderDark
                      : CollectoryColors.borderLight),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: CollectoryHandoffHeader.bodySecondary().copyWith(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _ShareRadio(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareRadio extends StatelessWidget {
  const _ShareRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? CollectoryColors.textLabel
              : CollectoryColors.borderLight,
          width: selected ? 0 : 1.5,
        ),
        color: selected ? CollectoryColors.textLabel : Colors.transparent,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: CollectoryColors.btnPrimaryText,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _ShareToggleRow extends StatelessWidget {
  const _ShareToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CollectoryColors.textPrimary,
              ),
            ),
          ),
          CollectoryPillToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
