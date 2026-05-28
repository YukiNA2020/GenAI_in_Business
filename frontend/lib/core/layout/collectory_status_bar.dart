import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/collectory_theme.dart';

/// Figma Mobile.png 顶部 — 实时时间 + 听筒/镜头黑框 + 电量
class CollectoryStatusBar extends StatefulWidget {
  const CollectoryStatusBar({super.key});

  static const double designHeight = 47;

  @override
  State<CollectoryStatusBar> createState() => _CollectoryStatusBarState();
}

class _CollectoryStatusBarState extends State<CollectoryStatusBar> {
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _scheduleClockTick();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _scheduleClockTick() {
    _clockTimer?.cancel();
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    var delay = nextMinute.difference(now);
    if (delay.inMilliseconds <= 0) {
      delay = const Duration(seconds: 1);
    }
    _clockTimer = Timer(delay, () {
      if (!mounted) return;
      setState(() {});
      _scheduleClockTick();
    });
  }

  static String _formatTime(DateTime time) {
    final h = time.hour;
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _formatTime(DateTime.now());

    return SizedBox(
      height: CollectoryStatusBar.designHeight,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 52,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  timeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: CollectoryColors.textPrimary,
                    letterSpacing: -0.3,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Center(child: _PhoneSensorIsland()),
            ),
            const SizedBox(
              width: 52,
              child: Align(
                alignment: Alignment.centerRight,
                child: _BatteryGlyph(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 时间与电量之间的听筒 + 前置镜头黑框（Dynamic Island 风格）
class _PhoneSensorIsland extends StatelessWidget {
  const _PhoneSensorIsland();

  static const _island = Color(0xFF1A1816);
  static const _lensOuter = Color(0xFF2A2624);
  static const _lensInner = Color(0xFF0D0B0A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 26,
      decoration: BoxDecoration(
        color: _island,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _lensOuter,
              border: Border.all(color: const Color(0xFF3D3835), width: 0.8),
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _lensInner,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SpeakerSlot(width: 36),
              const SizedBox(height: 2),
              _SpeakerSlot(width: 28),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeakerSlot extends StatelessWidget {
  const _SpeakerSlot({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0908),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _BatteryGlyph extends StatelessWidget {
  const _BatteryGlyph();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(25, 12),
      painter: _BatteryPainter(),
    );
  }
}

class _BatteryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 1, size.width - 3, size.height - 2),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = CollectoryColors.textPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1.6, 2.6, size.width - 7, size.height - 5.2),
        const Radius.circular(1.5),
      ),
      Paint()..color = CollectoryColors.textPrimary,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 2.2, 3.8, 1.8, size.height - 7.6),
        const Radius.circular(0.8),
      ),
      Paint()..color = CollectoryColors.textPrimary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
