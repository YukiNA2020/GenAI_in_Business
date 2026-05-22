import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_item.dart';
import '../providers/app_navigation_provider.dart';
import '../utils/collectory_room_catalog.dart';
import '../providers/collection_list_provider.dart';
import '../providers/member3_ui_settings_provider.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/providers/profile_providers.dart';
import '../services/collection_query_service.dart';
import '../utils/profile_exhibit_utils.dart';
import 'collectory_handoff_header.dart';
import 'collection_card.dart';
import 'collection_grid.dart';
import 'design/collectory_favorite_tags.dart';
import 'design/collectory_pill_toggle.dart';
import 'design/collectory_top_bar.dart';

/// Profile tab: stats API + recent [CollectionCard] + category preview (Member 3 phase 4).
/// [embeddedInMemberEProfile]：成员 E 阶段三·任务五 — 嵌入 ProfilePage，省略顶栏/头像/统计重复块。
class ProfileCollectionPreview extends ConsumerStatefulWidget {
  const ProfileCollectionPreview({
    super.key,
    this.embeddedInMemberEProfile = false,
  });

  final bool embeddedInMemberEProfile;

  @override
  ConsumerState<ProfileCollectionPreview> createState() =>
      _ProfileCollectionPreviewState();
}

class _ProfileCollectionPreviewState
    extends ConsumerState<ProfileCollectionPreview> {
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(userStatsProvider);
    final list = ref.watch(collectionMuseumCatalogProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final publicPreview = ref.watch(profilePublicPreviewProvider);
    final profile = ref.watch(userProfileProvider);
    final pad = CollectoryColors.screenPadding;

    final categoryNames = categoriesAsync.when(
      data: (cats) => {for (final c in cats) c.id: c.name},
      loading: () => <String, String>{},
      error: (_, __) => <String, String>{},
    );

    if (widget.embeddedInMemberEProfile) {
      final stats = statsAsync.valueOrNull ?? demoUserStatsFallback;
      return _buildMuseumSections(
        ref: ref,
        stats: stats,
        allItems: list.items,
        categoryNames: categoryNames,
        publicPreview: publicPreview,
      );
    }

    return statsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CollectoryColors.textLabel),
      ),
      error: (_, __) => _buildScrollBody(
        ref: ref,
        pad: pad,
        profile: profile,
        stats: demoUserStatsFallback,
        allItems: list.items,
        categoryNames: categoryNames,
        publicPreview: publicPreview,
      ),
      data: (stats) => _buildScrollBody(
        ref: ref,
        pad: pad,
        profile: profile,
        stats: stats,
        allItems: list.items,
        categoryNames: categoryNames,
        publicPreview: publicPreview,
      ),
    );
  }

  Widget _buildScrollBody({
    required WidgetRef ref,
    required double pad,
    required UserProfile profile,
    required UserStats stats,
    required List<CollectionItem> allItems,
    required Map<String, String> categoryNames,
    required bool publicPreview,
  }) {
    final display = resolveProfileStatsDisplay(
      museumCatalogItems: allItems,
      stats: stats,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 10, pad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CollectoryTopBar(
            contextTitle: 'Profile',
            trailing: Material(
              color: CollectoryColors.btnPrimaryBg,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => openShareRoom(ref),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Icon(
                    Icons.settings,
                    size: 17,
                    color: CollectoryColors.btnPrimaryText,
                  ),
                ),
              ),
            ),
          ),
          const _HairlineDivider(),
          const SizedBox(height: 14),
          Text('PRIVATE MUSEUM', style: CollectoryHandoffHeader.metaLabel()),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProfileAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: CollectoryColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    if (profile.bio.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        profile.bio,
                        style: CollectoryHandoffHeader.bodySecondary()
                            .copyWith(fontSize: 13, height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const _HairlineDivider(margin: EdgeInsets.symmetric(vertical: 14)),
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  value: display.exhibitsLabel,
                  label: 'Exhibits',
                ),
              ),
              Expanded(
                child: _StatColumn(value: display.roomsLabel, label: 'Rooms'),
              ),
              Expanded(
                child: _StatColumn(
                  value: display.publicLabel,
                  label: 'Public',
                ),
              ),
              Expanded(
                child: _LastAddedStatColumn(display: display.lastAdded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._museumSectionWidgets(
            ref: ref,
            stats: stats,
            allItems: allItems,
            categoryNames: categoryNames,
            publicPreview: publicPreview,
          ),
        ],
      ),
    );
  }

  Widget _buildMuseumSections({
    required WidgetRef ref,
    required UserStats stats,
    required List<CollectionItem> allItems,
    required Map<String, String> categoryNames,
    required bool publicPreview,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _museumSectionWidgets(
        ref: ref,
        stats: stats,
        allItems: allItems,
        categoryNames: categoryNames,
        publicPreview: publicPreview,
      ),
    );
  }

  List<Widget> _museumSectionWidgets({
    required WidgetRef ref,
    required UserStats stats,
    required List<CollectionItem> allItems,
    required Map<String, String> categoryNames,
    required bool publicPreview,
  }) {
    // Full archive catalog — never Gallery wall category/tag filters.
    final recent = resolveRecentExhibits(
      stats,
      allItems,
      publicOnly: publicPreview,
    );
    return [
          _VisibilityCard(
            publicPreview: publicPreview,
            onToggle: () {
              ref.read(profilePublicPreviewProvider.notifier).state =
                  !publicPreview;
            },
            onOpenSettings: () => openShareRoom(ref),
          ),
          const SizedBox(height: 20),
          Text(
            'Recent exhibits',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CollectoryColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No recent exhibits yet.',
                style: CollectoryHandoffHeader.bodySecondary(),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < recent.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      SizedBox(
                        width: 168,
                        child: CollectionCard(
                          item: recent[i],
                          categoryLabel: recent[i].category != null
                              ? categoryNames[recent[i].category!]
                              : null,
                          onTap: () => openItemDetail(ref, recent[i].id),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Favorite tags',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CollectoryColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          CollectoryFavoriteTagRow(
            activeTag: '',
            highlightActive: false,
            onTagTap: (tag) => openProfileFavoriteTagInGalleryWall(ref, tag),
          ),
          const SizedBox(height: 20),
          Text(
            'Collection rooms',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CollectoryColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < CollectoryRoomCatalog.rooms.length; i++) ...[
                  if (i > 0) const SizedBox(width: 7),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final spec = CollectoryRoomCatalog.rooms[i];
                        final count =
                            CollectoryRoomCatalog.itemsInRoom(allItems, spec)
                                .length;
                        return _RoomPreviewCard(
                          room: spec.roomCode,
                          title: spec.monthYear,
                          subtitle: '$count exhibits',
                          color: spec.cardColor,
                          preview: spec.isPreview,
                          onTap: () => openCollectionRoom(ref, roomIndex: i),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Settings',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CollectoryColors.textPrimary,
            ),
          ),
          const _HairlineDivider(),
          InkWell(
            onTap: () => openShareRoom(ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Account and privacy',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: CollectoryColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '→',
                    style: CollectoryHandoffHeader.metaLabel().copyWith(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _HairlineDivider(),
        ];
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: CollectoryColors.catVinyl,
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: CollectoryColors.btnPrimaryBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: CollectoryColors.catTicket,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Matches numeric stat columns: fixed value band + grey label baseline.
class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  static const double _valueBandHeight = 40;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _valueBandHeight,
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: CollectoryColors.textPrimary,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Text(
          label,
          style: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LastAddedStatColumn extends StatelessWidget {
  const _LastAddedStatColumn({required this.display});

  final ProfileLastAddedDisplay display;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _StatColumn._valueBandHeight,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (display.year != null)
                  Text(
                    display.year!,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: CollectoryColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                Text(
                  display.monthDay,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: CollectoryColors.textPrimary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        Text(
          'Last added',
          style: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _VisibilityCard extends StatelessWidget {
  const _VisibilityCard({
    required this.publicPreview,
    required this.onToggle,
    required this.onOpenSettings,
  });

  final bool publicPreview;
  final VoidCallback onToggle;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEDE4D9),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenSettings,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MUSEUM VISIBILITY',
                      style: CollectoryHandoffHeader.metaLabel(),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      publicPreview ? 'Public preview' : 'Private by default',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CollectoryColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      publicPreview
                          ? 'Showing public exhibits only (visitor view).'
                          : 'Toggle on to preview what visitors see.',
                      style: CollectoryHandoffHeader.bodySecondary()
                          .copyWith(fontSize: 11, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CollectoryPillToggle(
                value: publicPreview,
                onChanged: onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomPreviewCard extends StatelessWidget {
  const _RoomPreviewCard({
    required this.room,
    required this.title,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.preview = false,
  });

  final String room;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CollectoryColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (preview)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CollectoryColors.bgApp,
                          border: Border.all(color: CollectoryColors.textLabel),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Preview',
                          style: CollectoryHandoffHeader.metaLabel().copyWith(
                            fontSize: 8,
                            height: 1,
                          ),
                        ),
                      )
                    else
                      Text(
                        room,
                        style: CollectoryHandoffHeader.metaLabel().copyWith(
                          fontSize: 9,
                          height: 1.1,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: CollectoryColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: CollectoryHandoffHeader.bodySecondary()
                            .copyWith(fontSize: 9, height: 1.1),
                      ),
                    ],
                  ],
                ),
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: CollectoryColors.btnPrimaryBg,
                    borderRadius: BorderRadius.circular(3),
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
