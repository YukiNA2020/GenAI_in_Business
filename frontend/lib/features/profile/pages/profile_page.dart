// 负责人：成员 E / 成员 5 — ProfilePage（阶段三·任务 1–5，与成员 C 单页联调）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/providers/app_navigation_provider.dart';
import '../../collection_browse/providers/collection_list_provider.dart';
import '../../collection_browse/services/collection_query_service.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';
import '../../collection_browse/widgets/design/collectory_top_bar.dart';
import '../../collection_browse/widgets/profile_collection_preview.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = CollectoryColors.screenPadding;
    final statsAsync = ref.watch(userStatsProvider);

    if (statsAsync.hasError && statsAsync.value == null) {
      final error = statsAsync.error;
      final message = error is ApiException
          ? error.message
          : 'Could not load profile data.';
      return Center(
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: CollectoryHandoffHeader.bodySecondary(),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _ProfileScrollContent(pad: pad)),
      ],
    );
  }
}

class _ProfileScrollContent extends ConsumerWidget {
  const _ProfileScrollContent({required this.pad});

  final double pad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const Divider(
            height: 1,
            thickness: 1,
            color: CollectoryColors.borderLight,
          ),
          const SizedBox(height: 12),
          const ProfileHeader(),
          const SizedBox(height: 16),
          const ProfileStats(),
          const SizedBox(height: 20),
          const ProfileCollectionPreview(embeddedInMemberEProfile: true),
        ],
      ),
    );
  }
}
