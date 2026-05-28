import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/collectory_theme.dart';
import 'museum_home_layout_spec.dart';

/// 三道棕色下半椭圆拱 — 只连中间柱列，不接最高(0,9)与最矮(4,5)
class MuseumHallBackdropPainter extends CustomPainter {
  const MuseumHallBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = MuseumHomeLayoutSpec.scaleForWidth(size.width);
    final designH = size.height / scale;

    canvas.drawRect(Offset.zero & size, Paint()..color = CollectoryColors.bgApp);

    canvas.save();
    canvas.scale(scale);
    _paintHall(canvas, Size(MuseumHomeLayoutSpec.designWidth, designH));
    canvas.restore();
  }

  void _paintHall(Canvas canvas, Size size) {
    final baseY = size.height - MuseumHomeLayoutSpec.pillarBaseInset;
    final scales = MuseumHomeLayoutSpec.pillarHeightScale;
    final xs = MuseumHomeLayoutSpec.pillarCenterX;
    final maxH = MuseumHomeLayoutSpec.pillarMaxHeight;

    final pillarTops = List<double>.generate(
      scales.length,
      (i) => baseY - maxH * scales[i],
    );

    const innerIndices = [3, 4, 5, 6];
    var innerTopSum = 0.0;
    for (final i in innerIndices) {
      innerTopSum += pillarTops[i];
    }
    final innerTopY = innerTopSum / innerIndices.length;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(195, innerTopY + 20),
        width: MuseumHomeLayoutSpec.blueInnerOval.width,
        height: MuseumHomeLayoutSpec.blueInnerOval.height,
      ),
      Paint()
        ..color =
            MuseumHomeLayoutSpec.blueInnerOval.color.withValues(alpha: 0.9),
    );

    for (var i = 0; i < scales.length; i++) {
      final s = scales[i];
      final pillarH = maxH * s;
      final top = pillarTops[i];
      final cx = xs[i];
      final pw = 9 + s * 8;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - pw / 2, top, pw, pillarH),
          Radius.circular(pw * 0.5),
        ),
        Paint()
          ..color = Color.lerp(
            const Color(0xFFDDD0BC),
            const Color(0xFFE8DCCB),
            (s - 0.34) / 0.66,
          )!,
      );
    }

    // 仅中间柱对：(1,8)(2,7)(3,6)；不含最高 0/9、最矮 4/5
    const archPairs = [
      (1, 8),
      (2, 7),
      (3, 6),
    ];
    const ryFactors = [0.11, 0.105, 0.10];
    const connectRatio = 0.22;

    final archSpecs = <ArchSpec>[];
    for (var a = 0; a < archPairs.length; a++) {
      final left = archPairs[a].$1;
      final right = archPairs[a].$2;
      final lx = xs[left];
      final rx = xs[right];
      final lt = pillarTops[left];
      final rt = pillarTops[right];
      final lh = maxH * scales[left];
      final rh = maxH * scales[right];

      final cy =
          (lt + lh * connectRatio + rt + rh * connectRatio) / 2;
      final cx = (lx + rx) / 2;
      final arx = (rx - lx) / 2;
      final ary = arx * ryFactors[a];

      archSpecs.add(ArchSpec(center: Offset(cx, cy), rx: arx, ry: ary));
    }

    // 整体上移：避开图标顶与 MEMORIES 标签（中间拱最易重叠）
    const topArchAboveIcon = 24.0;
    const labelClearance = 10.0;
    final shiftForTop = (MuseumHomeLayoutSpec.memoryIconTopY - topArchAboveIcon) -
        archSpecs.first.center.dy;
    final middleArch = archSpecs[1];
    final shiftForMiddle =
        (MuseumHomeLayoutSpec.memoryLabelTopY -
                labelClearance -
                middleArch.ry) -
        middleArch.center.dy;
    final shiftY = math.min(shiftForTop, shiftForMiddle);
    for (final arch in archSpecs) {
      _drawArchLowerHalf(
        canvas,
        ArchSpec(
          center: Offset(arch.center.dx, arch.center.dy + shiftY),
          rx: arch.rx,
          ry: arch.ry,
        ),
      );
    }
  }

  void _drawArchLowerHalf(Canvas canvas, ArchSpec arch) {
    final rect = Rect.fromCenter(
      center: arch.center,
      width: arch.rx * 2,
      height: arch.ry * 2,
    );

    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(rect.left, arch.center.dy - 1, rect.width, arch.ry + 2),
    );

    final path = Path();
    const steps = 64;
    for (var i = 0; i <= steps; i++) {
      final angle = math.pi * (i / steps);
      final x = arch.center.dx + arch.rx * math.cos(angle);
      final y = arch.center.dy + arch.ry * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB8A996)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MuseumHallBackdropPainter oldDelegate) => false;
}
