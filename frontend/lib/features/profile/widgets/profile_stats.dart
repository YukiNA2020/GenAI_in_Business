// 负责人：成员 E / 成员 5 — GET /api/users/:id/stats（阶段三·任务五与成员 C 统计列对齐）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/providers/collection_list_provider.dart';
import '../../collection_browse/services/collection_query_service.dart';
import '../../collection_browse/utils/profile_exhibit_utils.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';

class ProfileStats extends ConsumerWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final list = ref.watch(collectionListProvider);

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
      data: (stats) {
        final lastAdded = resolveLastAdded(list.items, stats.recentCollections);
        final rooms = stats.categoryCount.toString().padLeft(2, '0');
        return _StatsCard(
          child: Row(
            children: [
              _StatCell(
                label: 'Exhibits',
                value: stats.totalCollections.toString(),
              ),
              _StatCell(label: 'Rooms', value: rooms),
              _StatCell(
                label: 'Public',
                value: stats.publicCollections.toString(),
              ),
              _LastAddedCell(display: lastAdded),
            ],
          ),
        );
      },
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

  static const double _valueBandHeight = 40;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
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
      ),
    );
  }
}

class _LastAddedCell extends StatelessWidget {
  const _LastAddedCell({required this.display});

  final ProfileLastAddedDisplay display;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: _StatCell._valueBandHeight,
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
                      ),
                    ),
                  Text(
                    display.monthDay,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: CollectoryColors.textPrimary,
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
      ),
    );
  }
}
