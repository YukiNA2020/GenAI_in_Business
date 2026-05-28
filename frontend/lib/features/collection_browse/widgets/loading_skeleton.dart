import 'package:flutter/material.dart';

import '../../../core/theme/collectory_theme.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

/// 详情页加载 — Member_3 阶段二
class DetailLoadingSkeleton extends StatelessWidget {
  const DetailLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(CollectoryColors.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: 160,
            decoration: BoxDecoration(
              color: CollectoryColors.bgSecondary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 36,
            width: double.infinity,
            decoration: BoxDecoration(
              color: CollectoryColors.bgSecondary,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: CollectoryColors.bgSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            height: 22,
            width: 72,
            decoration: BoxDecoration(
              color: CollectoryColors.bgSecondary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: CollectoryColors.bgSecondary,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CollectoryColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CollectoryColors.borderLight),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CollectoryColors.bgSecondary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 10,
            width: 60,
            color: CollectoryColors.bgSecondary,
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: double.infinity,
            color: CollectoryColors.bgSecondary,
          ),
        ],
      ),
    );
  }
}
