import 'package:flutter/material.dart';

import '../../../../core/theme/collectory_theme.dart';

/// Figma pill switch — tap or horizontal drag; drag commits on release.
class CollectoryPillToggle extends StatefulWidget {
  const CollectoryPillToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final VoidCallback onChanged;

  @override
  State<CollectoryPillToggle> createState() => _CollectoryPillToggleState();
}

class _CollectoryPillToggleState extends State<CollectoryPillToggle> {
  static const _trackOff = Color(0xFFE8E0D6);
  static const _knobTravel = 20.0;

  double _dragDelta = 0;

  double get _knobT {
    final base = widget.value ? 1.0 : 0.0;
    if (_dragDelta == 0) return base;
    return (base + _dragDelta / _knobTravel).clamp(0.0, 1.0);
  }

  bool get _previewOn => _knobT >= 0.5;

  void _commit(bool target) {
    setState(() => _dragDelta = 0);
    if (target != widget.value) widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final on = _previewOn;
    final animating = _dragDelta == 0;

    return GestureDetector(
      onTap: () => _commit(!widget.value),
      onHorizontalDragStart: (_) => setState(() => _dragDelta = 0),
      onHorizontalDragUpdate: (details) {
        setState(() => _dragDelta += details.delta.dx);
      },
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v > 120) {
          _commit(true);
        } else if (v < -120) {
          _commit(false);
        } else if (_knobT >= 0.5) {
          _commit(true);
        } else {
          _commit(false);
        }
      },
      onHorizontalDragCancel: () => setState(() => _dragDelta = 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 46,
        height: 26,
        decoration: BoxDecoration(
          color: on ? CollectoryColors.btnPrimaryBg : _trackOff,
          borderRadius: BorderRadius.circular(13),
          border: on ? null : Border.all(color: CollectoryColors.borderLight),
        ),
        child: AnimatedAlign(
          duration: animating
              ? const Duration(milliseconds: 180)
              : Duration.zero,
          curve: Curves.easeOut,
          alignment: Alignment(_knobT * 2 - 1, 0),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: CollectoryColors.btnPrimaryText,
                shape: BoxShape.circle,
                boxShadow: on
                    ? null
                    : const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
