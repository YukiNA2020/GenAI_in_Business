// 负责人：成员 E / 成员 5 — GET /api/users/:id/stats

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/providers/collection_list_provider.dart';
import '../../collection_browse/services/collection_query_service.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';

class ProfileStats extends ConsumerWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return statsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(color: CollectoryColors.textLabel),
        ),
      ),
      error: (error, _) {
        final message = error is ApiException
            ? error.message
            : 'Could not load collection stats.';
        return _StatsCard(
          child: Text(
            message,
            style: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 12),
          ),
        );
      },
      data: (stats) => _StatsCard(
        child: Row(
          children: [
            _StatCell(
              label: 'Exhibits',
              value: stats.totalCollections.toString(),
            ),
            _StatCell(
              label: 'Categories',
              value: stats.categoryCount.toString(),
            ),
            _StatCell(
              label: 'Public',
              value: stats.publicCollections.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: CollectoryColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CollectoryColors.borderLight),
      ),
      child: child,
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CollectoryColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: CollectoryHandoffHeader.metaLabel()),
        ],
      ),
    );
  }
}
