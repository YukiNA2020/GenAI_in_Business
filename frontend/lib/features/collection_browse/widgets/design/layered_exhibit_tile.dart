import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/motion/collectory_motion.dart';
import '../../../../core/theme/collectory_theme.dart';
import '../../../../core/theme/collectory_tokens.dart';
import '../../models/collection_item.dart';
import '../../utils/gallery_layers.dart';
import 'home_exhibit_icons.dart';

/// Figma Gallery 2×2 — 固定分层插画 + 默认标题（不用 API 缩略图）
class LayeredExhibitTile extends StatefulWidget {
  const LayeredExhibitTile({
    super.key,
    required this.spec,
    required this.item,
    required this.onTap,
    this.onDragEnd,
  });

  final GalleryLayerSpec spec;
  final CollectionItem? item;
  final VoidCallback onTap;
  final VoidCallback? onDragEnd;

  @override
  State<LayeredExhibitTile> createState() => _LayeredExhibitTileState();
}

class _LayeredExhibitTileState extends State<LayeredExhibitTile> {
  /// Normalized drag vector in [-1, 1]; drives Figma layer offsets at t=1.
  Offset _dragNorm = Offset.zero;

  /// 静止叠放：后层在右上方，前层在左下方（Figma）
  static const _restOffsets = [
    Offset(11, 0),
    Offset(7, 5),
    Offset(0, 10),
  ];

  Offset _parallaxOffset(int layerIndex) {
    final dx = _dragNorm.dx;
    final dy = _dragNorm.dy;
    if (layerIndex == 2) {
      return Offset(
        dx * CollectoryMotion.layerFrontDx,
        dy * CollectoryMotion.layerFrontDy,
      );
    }
    final scale = layerIndex == 0 ? 1.0 : 0.72;
    return Offset(
      dx * CollectoryMotion.layerBackDx * scale,
      dy * CollectoryMotion.layerBackDy * scale,
    );
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _dragNorm += Offset(d.delta.dx / 90, d.delta.dy / 90);
      _dragNorm = Offset(
        _dragNorm.dx.clamp(-1.0, 1.0),
        _dragNorm.dy.clamp(-1.0, 1.0),
      );
    });
  }

  List<Offset> _restOffsetsFor(double side) {
    final scale = side / 112.0;
    return _restOffsets
        .map((o) => Offset(o.dx * scale, o.dy * scale))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Color(widget.spec.cardColor);

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth;
        final offsets = _restOffsetsFor(side);

        return GestureDetector(
          onTap: widget.onTap,
          onPanUpdate: _onPanUpdate,
          onPanEnd: (_) {
            setState(() => _dragNorm = Offset.zero);
            widget.onDragEnd?.call();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.spec.layerLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CollectoryTypography.metaLabel,
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: side,
                height: side,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Positioned(
                        left: offsets[i].dx,
                        top: offsets[i].dy,
                        right: (6 - i * 2.0) * (side / 112.0),
                        bottom: (4 + i * 2.0) * (side / 112.0),
                        child: TweenAnimationBuilder<Offset>(
                          duration: CollectoryMotion.medium,
                          curve: CollectoryMotion.ease,
                          tween: Tween<Offset>(end: _parallaxOffset(i)),
                          builder: (context, offset, child) {
                            return Transform.translate(
                              offset: offset,
                              child: child,
                            );
                          },
                          child: _LayerCard(
                            color: i == 2
                                ? cardColor
                                : cardColor.withValues(alpha: 0.32 + i * 0.14),
                            child: i == 2
                                ? Center(
                                    child: GalleryCategoryIllustration(
                                      specKey: widget.spec.key,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.spec.defaultTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CollectoryColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Figma 分类插画（Gallery 2×2 与 Exhibit detail 主图共用）
class GalleryCategoryIllustration extends StatelessWidget {
  const GalleryCategoryIllustration({
    required this.specKey,
    this.large = false,
  });

  final String specKey;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final icon = switch (specKey) {
      'vinyl' => HomeVinylIcon(size: large ? 80 : 40),
      'ticket' => HomeTicketIcon(
          width: large ? 90 : 54, height: large ? 52 : 31),
      'memory' => HomeMemoryIcon(size: large ? 72 : 42),
      'mineral' => GalleryMineralIllustration(large: large),
      _ => HomeVinylIcon(size: large ? 80 : 40),
    };

    return Center(child: icon);
  }
}

/// 矿物 — 六边形与紫底白框同轴居中
class GalleryMineralIllustration extends StatelessWidget {
  const GalleryMineralIllustration({this.large = false});

  final bool large;

  @override
  Widget build(BuildContext context) {
    final scale = large ? 1.35 : 1.0;
    return SizedBox(
      width: 46 * scale,
      height: 50 * scale,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 11,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CollectoryColors.catLavender,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Container(
              width: 18,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFFAF8F4),
                borderRadius: BorderRadius.circular(1),
                border: Border.all(
                  color: CollectoryColors.borderLight.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 9,
            child: CustomPaint(
              size: Size(30, 34),
              painter: _GalleryCrystalPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryCrystalPainter extends CustomPainter {
  const _GalleryCrystalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width * 0.44;
    final ry = size.height * 0.48;

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

    canvas.drawPath(path, Paint()..color = CollectoryColors.catMineral);
    final facet = Path()
      ..moveTo(cx, cy - ry * 0.88)
      ..lineTo(cx + rx * 0.82, cy + ry * 0.12)
      ..lineTo(cx, cy + ry * 0.92)
      ..close();
    canvas.drawPath(
      facet,
      Paint()..color = const Color(0xFF6A8F84).withValues(alpha: 0.28),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LayerCard extends StatelessWidget {
  const _LayerCard({required this.color, this.child});

  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CollectoryColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A17120F),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
