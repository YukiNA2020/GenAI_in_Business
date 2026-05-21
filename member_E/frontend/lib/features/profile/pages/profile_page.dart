// 负责人：成员 E / 成员 5 — ProfilePage（阶段三·任务 1–2）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/providers/app_navigation_provider.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';
import '../../collection_browse/widgets/design/collectory_top_bar.dart';
import '../../collection_browse/widgets/profile_collection_preview.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/recent_collections_section.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = CollectoryColors.screenPadding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, 10, pad, 12),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        child: Icon(
                          Icons.settings,
                          size: 17,
                          color: CollectoryColors.btnPrimaryText,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: CollectoryColors.borderLight,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('MY ARCHIVE', style: CollectoryHandoffHeader.metaLabel()),
                    const SizedBox(width: 8),
                    Text(
                      '(Member E)',
                      style: CollectoryHandoffHeader.bodySecondary()
                          .copyWith(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const ProfileHeader(),
                const SizedBox(height: 16),
                const ProfileStats(),
                const SizedBox(height: 16),
                const RecentCollectionsSection(),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        fullscreenDialog: true,
                        builder: (_) => const Scaffold(
                          backgroundColor: CollectoryColors.bgApp,
                          body: SafeArea(
                            child: ProfileCollectionPreview(),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.museum_outlined, size: 18),
                  label: const Text('Open museum rooms (Member 3)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CollectoryColors.textPrimary,
                    side: const BorderSide(color: CollectoryColors.borderDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
