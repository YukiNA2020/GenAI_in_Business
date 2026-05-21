// 负责人：成员 E / 成员 5 — 复用成员 C 的 CollectionCard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collection_browse/providers/app_navigation_provider.dart';
import '../../collection_browse/providers/collection_list_provider.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';
import '../../collection_browse/widgets/collection_card.dart';

class RecentCollectionsSection extends ConsumerWidget {
  const RecentCollectionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final recent = stats.recentCollections;
        if (recent.isEmpty) {
          return Text(
            'No recent exhibits yet. Add one from the Add tab.',
            style: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 12),
          );
        }

        final categoryNames = categoriesAsync.maybeWhen(
          data: (cats) => {for (final c in cats) c.id: c.name},
          orElse: () => <String, String>{},
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('RECENT EXHIBITS', style: CollectoryHandoffHeader.metaLabel()),
            const SizedBox(height: 8),
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recent.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = recent[index];
                  return SizedBox(
                    width: 140,
                    child: CollectionCard(
                      item: item,
                      categoryLabel: categoryNames[item.category],
                      onTap: () => openItemDetail(ref, item.id),
                      compact: true,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
