import 'package:flutter/material.dart';

import '../../../../core/theme/collectory_tokens.dart';
import '../../../../core/theme/collectory_theme.dart';
import '../../models/collection_room.dart';

/// handoff Gallery — ROOM 切换条
class RoomSelectorRow extends StatelessWidget {
  const RoomSelectorRow({
    super.key,
    this.rooms = const [],
    this.selectedRoomId,
    this.onSelect,
  });

  final List<CollectionRoomSummary> rooms;
  final int? selectedRoomId;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = rooms.indexWhere((r) => r.id == selectedRoomId);
    final actualIndex = selectedIndex >= 0 ? selectedIndex : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(rooms.length, (i) {
            final active = i == actualIndex;
            final room = rooms[i];
            final label = room.label ?? room.month;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < rooms.length - 1
                      ? CollectorySpacing.unit
                      : 0,
                ),
                child: Material(
                  color: active
                      ? CollectoryColors.btnPrimaryBg
                      : CollectoryColors.bgApp,
                  borderRadius: CollectoryRadius.cardBorder,
                  child: InkWell(
                    onTap: onSelect != null ? () => onSelect!(room.id) : null,
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
                              room.month,
                              style: CollectoryTypography.metaLabel.copyWith(
                                fontSize: 9,
                                letterSpacing: 0.4,
                                color: CollectoryColors.textLabel,
                              ),
                            ),
                            const SizedBox(height: CollectorySpacing.unit / 2),
                            Text(
                              label,
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
