import 'package:flutter/material.dart';

import '../../../../core/theme/collectory_tokens.dart';
import '../../../../core/theme/collectory_theme.dart';
import 'home_exhibit_icons.dart';
import 'museum_hall_backdrop_painter.dart';
import 'museum_home_layout_spec.dart';

/// Mobile.png：背景铺满 + 展品与柱廊同一缩放坐标
class MuseumHallScene extends StatelessWidget {
  const MuseumHallScene({
    super.key,
    required this.onTickets,
    required this.onMemories,
    required this.onMinerals,
    required this.onVinyl,
  });

  final VoidCallback onTickets;
  final VoidCallback onMemories;
  final VoidCallback onMinerals;
  final VoidCallback onVinyl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MuseumHomeLayoutSpec.scaleForWidth(constraints.maxWidth);

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: MuseumHallBackdropPainter()),
            ),
            _spot(
              MuseumHomeLayoutSpec.memoriesCenter,
              scale,
              label: 'MEMORIES',
              onTap: onMemories,
              child: const HomeMemoryIcon(
                size: MuseumHomeLayoutSpec.memoryIconSize,
              ),
            ),
            _spot(
              MuseumHomeLayoutSpec.ticketsCenter,
              scale,
              label: 'TICKETS',
              onTap: onTickets,
              child: const HomeTicketIcon(
                width: MuseumHomeLayoutSpec.ticketWidth,
                height: MuseumHomeLayoutSpec.ticketHeight,
              ),
            ),
            _spot(
              MuseumHomeLayoutSpec.mineralsCenter,
              scale,
              label: 'MINERALS',
              onTap: onMinerals,
              child: const HomeMineralIcon(
                size: MuseumHomeLayoutSpec.mineralIconSize,
              ),
            ),
            _spot(
              MuseumHomeLayoutSpec.vinylCenter,
              scale,
              label: 'VINYL',
              onTap: onVinyl,
              child: const HomeVinylIcon(
                size: MuseumHomeLayoutSpec.vinylIconSize,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _spot(
    Offset designCenter,
    double scale, {
    required String label,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Positioned(
      left: designCenter.dx * scale,
      top: designCenter.dy * scale,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: _ObjectSpot(label: label, onTap: onTap, child: child),
      ),
    );
  }
}

class _ObjectSpot extends StatelessWidget {
  const _ObjectSpot({
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: CollectoryColors.borderLight.withValues(alpha: 0.2),
        borderRadius: CollectoryRadius.cardBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              const SizedBox(height: 4),
              Text(
                label,
                style: CollectoryTypography.metaLabel.copyWith(
                  fontSize: 10,
                  color: CollectoryColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
