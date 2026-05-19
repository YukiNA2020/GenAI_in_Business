import 'package:flutter/material.dart';

import '../../../../core/theme/collectory_tokens.dart';
import '../../../../core/theme/collectory_theme.dart';
import '../../utils/collectory_room_catalog.dart';

/// handoff Gallery — ROOM 切换条
class RoomSelectorRow extends StatelessWidget {
  const RoomSelectorRow({
    super.key,
    this.selectedIndex = 0,
    this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(CollectoryRoomCatalog.rooms.length, (i) {
            final active = i == selectedIndex;
            final spec = CollectoryRoomCatalog.rooms[i];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < CollectoryRoomCatalog.rooms.length - 1
                      ? CollectorySpacing.unit
                      : 0,
                ),
                child: Material(
                  color: active
                      ? CollectoryColors.btnPrimaryBg
                      : CollectoryColors.bgApp,
                  borderRadius: CollectoryRadius.cardBorder,
                  child: InkWell(
                    onTap: onSelect != null ? () => onSelect!(i) : null,
                    borderRadius: CollectoryRadius.cardBorder,
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: CollectoryRadius.cardBorder,
                        border: Border.all(
                          color: active
                              ? CollectoryColors.btnPrimaryBg
                              : CollectoryColors.borderLight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: CollectorySpacing.titleToBodyGap,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spec.roomCode,
                              style: CollectoryTypography.metaLabel.copyWith(
                                fontSize: 9,
                                letterSpacing: 0.4,
                                color: CollectoryColors.textLabel,
                              ),
                            ),
                            const SizedBox(height: CollectorySpacing.unit / 2),
                            Text(
                              spec.monthYear,
                              style: CollectoryTypography.cardTitle.copyWith(
                                fontSize: 14,
                                color: active
                                    ? CollectoryColors.btnPrimaryText
                                    : CollectoryColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          'Swipe room by room through your monthly collection.',
          style: CollectoryTypography.bodySecondary.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
