import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'collectory_status_bar.dart';
import '../theme/collectory_theme.dart';

/// Figma `Mobile.png`（390×844）。Web/桌面预览套手机框；真机全屏。
class CollectoryMobileShell extends StatelessWidget {
  const CollectoryMobileShell({super.key, required this.child});

  final Widget child;

  static const double designWidth = 390;
  static const double designHeight = 844;

  static bool get usePhoneFrame {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  Widget build(BuildContext context) {
    if (!usePhoneFrame) {
      return child;
    }

    // 手机预览框固定 47px，避免与内容区高度不一致出现色缝/横线
    const statusH = CollectoryStatusBar.designHeight;
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        if (maxW <= 0 || maxH <= 0) {
          return child;
        }

        final scale = math.min(
          maxW / designWidth,
          maxH / designHeight,
        );
        final frameW = designWidth * scale;
        final frameH = designHeight * scale;

        return Center(
          child: SizedBox(
            width: frameW,
            height: frameH,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CollectoryColors.bgApp,
                borderRadius: BorderRadius.circular(36 * scale),
                border: Border.all(
                  color: const Color(0xFF3A3530),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 40,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35 * scale),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: Size(designWidth, designHeight - statusH),
                    padding: EdgeInsets.only(
                      bottom: viewPadding.bottom > 0 ? viewPadding.bottom : 34,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: statusH),
                        child: child,
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: statusH,
                        child: const ColoredBox(
                          color: CollectoryColors.bgApp,
                          child: CollectoryStatusBar(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
