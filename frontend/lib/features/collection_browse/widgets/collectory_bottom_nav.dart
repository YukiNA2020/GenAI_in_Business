import 'package:flutter/material.dart';

import '../../../core/theme/collectory_tokens.dart';
import '../../../core/theme/collectory_theme.dart';

/// collectory-ui-handoff.md §10
class CollectoryBottomNav extends StatelessWidget {
  const CollectoryBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: CollectoryColors.bgApp,
        border: Border(top: BorderSide(color: CollectoryColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: SizedBox(
          height: CollectorySpacing.bottomNavHeight,
          child: Row(
            children: List.generate(CollectoryNavTokens.labels.length, (i) {
              final active = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (active)
                        Container(
                          width: CollectoryNavTokens.activeIndicatorWidth,
                          height: CollectoryNavTokens.activeIndicatorHeight,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: CollectoryNavTokens.activeIndicatorColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      else
                        const SizedBox(height: 8),
                      Text(
                        CollectoryNavTokens.labels[i],
                        style: CollectoryTypography.bottomNav(active: active)
                            .copyWith(decoration: TextDecoration.none),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
