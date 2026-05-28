import 'package:flutter/material.dart';

import '../../../../core/theme/collectory_theme.dart';

/// 对齐用户参考图 / Mobile.png（390 宽）
abstract final class MuseumHomeLayoutSpec {
  static const double designWidth = 390;

  static const Color roomBandColor = CollectoryColors.bgSecondary;
  static const Color roomCardColor = Color(0xFFFEFDFA);
  static const double roomBandPaddingV = 11;
  static const double roomCardMinHeight = 92;

  static const double heroTitleSize = 22;
  static const double heroSubtitleSize = 14;
  static const double personalLabelSize = 11;
  static const double roomTitleSize = 20;

  static const double topBarHeight = 36;
  static const double afterTopBarGap = 14;
  static const double labelToTitleGap = 10;
  static const double titleLineGap = 2;
  static const double titleToSubtitleGap = 12;
  static const double subtitleLineGap = 4;

  static double scaleForWidth(double width) => width / designWidth;

  /// 中间四根内柱之间的浅蓝椭圆
  static const blueInnerOval = OvalSpec(
    center: Offset(195, 352),
    width: 112,
    height: 48,
    color: CollectoryColors.catMemory,
  );

  static const double pillarBaseInset = 28;
  static const double pillarMaxHeight = 468;

  /// 参考图：左右各 5 根，中间留空；由外向内渐短
  static const List<double> pillarCenterX = [
    26, 62, 98, 134, 170, 220, 256, 292, 328, 364,
  ];
  static const List<double> pillarHeightScale = [
    1.00, 0.84, 0.68, 0.52, 0.36, 0.36, 0.52, 0.68, 0.84, 1.00,
  ];

  /// 展品中心（390 设计坐标）
  static const Offset memoriesCenter = Offset(195, 268);
  static const Offset ticketsCenter = Offset(58, 342);
  static const Offset mineralsCenter = Offset(332, 342);
  static const Offset vinylCenter = Offset(195, 418);

  static const double memoryIconSize = 52;

  /// 与 [HomeMemoryIcon] 可视高度一致（设计坐标）
  static double get memoryIconVisualHeight => memoryIconSize * 1.05 + 5;

  static double get memoryIconTopY =>
      memoriesCenter.dy - memoryIconVisualHeight / 2;

  /// 与 [_ObjectSpot] 中图标下缘 + 4px 间距对齐
  static double get memoryLabelTopY =>
      memoriesCenter.dy + memoryIconVisualHeight / 2 + 4;
  static const double ticketWidth = 84;
  static const double ticketHeight = 46;
  static const double mineralIconSize = 72;
  static const double vinylIconSize = 54;
}

class OvalSpec {
  const OvalSpec({
    required this.center,
    required this.width,
    required this.height,
    required this.color,
  });

  final Offset center;
  final double width;
  final double height;
  final Color color;
}

class ArchSpec {
  const ArchSpec({
    required this.center,
    required this.rx,
    required this.ry,
  });

  final Offset center;
  final double rx;
  final double ry;
}
