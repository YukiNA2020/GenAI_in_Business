import 'package:flutter/material.dart';

import '../../../../core/theme/collectory_theme.dart';

/// Figma 展品示意图标（Home / Gallery / Room 卡片）
enum ExhibitIconKind { vinyl, ticket, memory, mineral }

class ExhibitIcon extends StatelessWidget {
  const ExhibitIcon({
    super.key,
    required this.kind,
    this.size = 56,
  });

  final ExhibitIconKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: switch (kind) {
        ExhibitIconKind.vinyl => const _VinylIcon(),
        ExhibitIconKind.ticket => const _TicketIcon(),
        ExhibitIconKind.memory => const _MemoryIcon(),
        ExhibitIconKind.mineral => const _MineralIcon(),
      },
    );
  }

  static ExhibitIconKind? fromCategory(String? category) {
    switch (category) {
      case 'vinyl':
        return ExhibitIconKind.vinyl;
      case 'ticket':
        return ExhibitIconKind.ticket;
      case 'postcard':
      case 'souvenir':
      case 'stamp':
        return ExhibitIconKind.memory;
      case 'mineral':
      case 'crystal':
        return ExhibitIconKind.mineral;
      default:
        return null;
    }
  }
}

class _VinylIcon extends StatelessWidget {
  const _VinylIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFC7A679),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFF17120F),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFC98250),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketIcon extends StatelessWidget {
  const _TicketIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8D7BD),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFF4EBDD),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: CollectoryColors.borderLight),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 10,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFC98250),
                borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryIcon extends StatelessWidget {
  const _MemoryIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBDD),
        border: Border.all(color: CollectoryColors.borderLight),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(painter: _MemoryPainter()),
    );
  }
}

class _MemoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mountain = Path()
      ..moveTo(size.width * 0.2, size.height * 0.72)
      ..lineTo(size.width * 0.5, size.height * 0.35)
      ..lineTo(size.width * 0.8, size.height * 0.72)
      ..close();
    canvas.drawPath(
      mountain,
      Paint()..color = const Color(0xFF7C7469),
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.32),
      size.width * 0.08,
      Paint()..color = const Color(0xFFC98250),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MineralIcon extends StatelessWidget {
  const _MineralIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 4,
          child: Container(
            width: 44,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFD8D1E8),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(40, 44),
          painter: _CrystalPainter(),
        ),
      ],
    );
  }
}

class _CrystalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.05)
      ..lineTo(size.width * 0.88, size.height * 0.42)
      ..lineTo(size.width * 0.72, size.height * 0.92)
      ..lineTo(size.width * 0.28, size.height * 0.92)
      ..lineTo(size.width * 0.12, size.height * 0.42)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF55746A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
