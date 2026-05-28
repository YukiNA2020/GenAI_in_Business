import 'package:flutter/material.dart';

import '../../../core/theme/collectory_tokens.dart';

/// collectory-ui-handoff.md — 排版入口（委托 CollectoryTypography）
class CollectoryHandoffHeader extends StatelessWidget {
  const CollectoryHandoffHeader({
    super.key,
    required this.contextTitle,
    this.trailing,
  });

  final String contextTitle;
  final Widget? trailing;

  static TextStyle metaLabel() => CollectoryTypography.metaLabel;

  static TextStyle pageTitle() => CollectoryTypography.pageTitle;

  static TextStyle sectionTitle() => CollectoryTypography.sectionTitle;

  static TextStyle cardTitle() => CollectoryTypography.cardTitle;

  static TextStyle bodySecondary() => CollectoryTypography.bodySecondary;

  static TextStyle body() => CollectoryTypography.body;

  /// Home 主标题 — Figma 双行标题（略小于全页 pageTitle）
  static TextStyle homeHero() => CollectoryTypography.pageTitle.copyWith(
        fontSize: 36,
        height: 1.18,
        letterSpacing: -0.2,
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('COLLECTORY', style: CollectoryTypography.brandMark),
              const SizedBox(height: CollectorySpacing.unit / 4),
              Text(contextTitle, style: CollectoryTypography.navContext),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
