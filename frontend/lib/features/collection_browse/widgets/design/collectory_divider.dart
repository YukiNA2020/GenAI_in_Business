import 'package:flutter/material.dart';

import '../../../../core/theme/collectory_tokens.dart';
import '../../../../core/theme/collectory_theme.dart';

/// handoff 分隔线 — 默认 section 间距
class CollectoryDivider extends StatelessWidget {
  const CollectoryDivider({super.key, this.margin});

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ??
          const EdgeInsets.symmetric(vertical: CollectorySpacing.sectionGap),
      child: const Divider(
        height: 1,
        thickness: 1,
        color: CollectoryColors.borderLight,
      ),
    );
  }
}
