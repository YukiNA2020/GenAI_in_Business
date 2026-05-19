import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/collectory_tokens.dart';
import '../../../../core/theme/collectory_theme.dart';

/// Figma Home 四类展品 — 对齐 Mobile.png 造型
class HomeMemoryIcon extends StatelessWidget {
  const HomeMemoryIcon({super.key, this.size = 58});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 6,
      height: size * 1.05 + 5,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 5,
            top: 5,
            child: Container(
              width: size,
              height: size * 1.02,
              decoration: BoxDecoration(
                color: const Color(0xFFE5D9C8),
                borderRadius: BorderRadius.circular(5),
                boxShadow: CollectoryShadows.card,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: size,
              height: size * 1.05,
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EF),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: CollectoryColors.borderLight),
                boxShadow: CollectoryShadows.elevated,
              ),
              child: CustomPaint(painter: _HomeMemoryPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeMemoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final artH = h * 0.58;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, artH),
      Paint()..color = CollectoryColors.catMemory,
    );

    final mountain = Path()
      ..moveTo(w * 0.18, artH * 0.88)
      ..lineTo(w * 0.48, artH * 0.42)
      ..lineTo(w * 0.78, artH * 0.88)
      ..close();
    canvas.drawPath(mountain, Paint()..color = CollectoryColors.catMineral);

    canvas.drawCircle(
      Offset(w * 0.7, artH * 0.38),
      w * 0.07,
      Paint()..color = CollectoryColors.catTicket,
    );

    for (var i = 0; i < 3; i++) {
      final y = artH + (h - artH) * (0.28 + i * 0.24);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.14, y, w * 0.72, 2.2),
          const Radius.circular(1),
        ),
        Paint()..color = CollectoryColors.borderLight.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeTicketIcon extends StatelessWidget {
  const HomeTicketIcon({
    super.key,
    this.width = 88,
    this.height = 50,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _TicketStubPainter(),
    );
  }
}

class _TicketStubPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const r = 6.0;

    final body = Path()
      ..moveTo(r, 0)
      ..lineTo(w - 14, 0)
      ..arcToPoint(Offset(w - 14, h), radius: const Radius.circular(3))
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h / 2, r, 0)
      ..close();

    canvas.drawShadow(
      body,
      const Color(0x3317120F),
      6,
      false,
    );
    canvas.drawPath(body, Paint()..color = CollectoryColors.bgCard);

    for (var i = 0; i < 3; i++) {
      final cy = h * (0.28 + i * 0.22);
      canvas.drawCircle(
        Offset(w - 6, cy),
        3,
        Paint()..color = CollectoryColors.bgApp,
      );
    }

    canvas.drawPath(
      body,
      Paint()
        ..color = CollectoryColors.borderLight.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    final labelSize = h * 0.18;
    _paintLabel(
      canvas,
      'LIVE',
      Offset(w * 0.36, h * 0.36),
      fontSize: labelSize,
      weight: FontWeight.w700,
      color: CollectoryColors.textPrimary,
    );
    _paintLabel(
      canvas,
      '05.11',
      Offset(w * 0.36, h * 0.64),
      fontSize: labelSize,
      weight: FontWeight.w700,
      color: CollectoryColors.textPrimary,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.62, h * 0.22, w * 0.14, h * 0.56),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFC98250),
    );
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset center, {
    required double fontSize,
    required FontWeight weight,
    required Color color,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          decoration: TextDecoration.none,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeMineralIcon extends StatelessWidget {
  const HomeMineralIcon({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    final crystalW = size * 0.50;
    final crystalH = size * 0.72;

    return SizedBox(
      width: size,
      height: size * 1.08,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.76,
              height: size * 0.18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CollectoryColors.catLavender,
                borderRadius: BorderRadius.circular(5),
                boxShadow: CollectoryShadows.elevated,
              ),
              child: Container(
                width: size * 0.34,
                height: size * 0.10,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F4),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: CollectoryColors.borderLight.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.16,
            child: CustomPaint(
              size: Size(crystalW, crystalH),
              painter: _HomeCrystalPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCrystalPainter extends CustomPainter {
  /// Figma — 竖向正六边形（尖顶/尖底，偏高）
  static Path _hexagonVertical(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width * 0.46;
    final ry = size.height * 0.50;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = cx + rx * math.cos(angle);
      final y = cy + ry * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _hexagonVertical(size);
    canvas.drawPath(path, Paint()..color = CollectoryColors.catMineral);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF3D5C52).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final facet = Path()
      ..moveTo(size.width * 0.5, size.height * 0.04)
      ..lineTo(size.width * 0.9, size.height * 0.42)
      ..lineTo(size.width * 0.5, size.height * 0.96)
      ..close();
    canvas.drawPath(
      facet,
      Paint()..color = const Color(0xFF6A8F84).withValues(alpha: 0.32),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeVinylIcon extends StatelessWidget {
  const HomeVinylIcon({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final outer = size * 1.08;
    final inner = size * 0.88;

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: outer,
            height: outer,
            decoration: BoxDecoration(
              color: const Color(0xFFE5D9C8),
              borderRadius: BorderRadius.circular(8),
              boxShadow: CollectoryShadows.card,
            ),
          ),
          Container(
            width: inner,
            height: inner,
            decoration: BoxDecoration(
              color: CollectoryColors.catVinyl,
              borderRadius: BorderRadius.circular(7),
              boxShadow: CollectoryShadows.elevated,
            ),
            child: Center(
              child: Container(
                width: inner * 0.62,
                height: inner * 0.62,
                decoration: const BoxDecoration(
                  color: CollectoryColors.catVinylBlack,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: inner * 0.14,
                    height: inner * 0.14,
                    decoration: const BoxDecoration(
                      color: CollectoryColors.catTicket,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
