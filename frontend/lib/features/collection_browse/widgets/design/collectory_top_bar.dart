import 'package:flutter/material.dart';

import '../../../../core/theme/collectory_tokens.dart';

/// handoff 顶栏：COLLECTORY + 上下文标题
class CollectoryTopBar extends StatelessWidget {
  const CollectoryTopBar({
    super.key,
    required this.contextTitle,
    this.trailing,
    this.leading,
  });

  final String contextTitle;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    // Figma Mobile.png — COLLECTORY 左，上下文标题绝对居中，操作按钮右
    return SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (leading != null)
            Align(
              alignment: Alignment.centerLeft,
              child: leading!,
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('COLLECTORY', style: CollectoryTypography.brandMark),
          ),
          Text(
            contextTitle,
            textAlign: TextAlign.center,
            style: CollectoryTypography.navContext,
          ),
          if (trailing != null)
            Align(
              alignment: Alignment.centerRight,
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

class CollectoryBackBar extends StatelessWidget {
  const CollectoryBackBar({
    super.key,
    required this.backLabel,
    required this.centerTitle,
    required this.onBack,
    this.trailing,
  });

  final String backLabel;
  final String centerTitle;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: CollectoryRadius.cardBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back, size: 20),
                const SizedBox(width: 4),
                Text(backLabel, style: CollectoryTypography.backLabel),
              ],
            ),
          ),
        ),
        Expanded(
          child: Text(
            centerTitle,
            textAlign: TextAlign.center,
            style: CollectoryTypography.navContext,
          ),
        ),
        trailing ?? const SizedBox(width: 48),
      ],
    );
  }
}
