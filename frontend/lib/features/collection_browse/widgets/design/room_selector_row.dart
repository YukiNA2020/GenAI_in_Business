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
    final currentMonth = DateTime.now().month;
    final actualIndex = rooms.indexWhere((room) => _monthFromRoom(room.month) == currentMonth);
    final activeIndex = actualIndex >= 0 ? actualIndex : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(rooms.length, (i) {
            final active = i == activeIndex;
            final room = rooms[i];
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
                              'ROOM ${(i + 1).toString().padLeft(2, '0')}',
                              style: CollectoryTypography.metaLabel.copyWith(
                                fontSize: 9,
                                letterSpacing: 0.4,
                                color: CollectoryColors.textLabel,
                              ),
                            ),
                            const SizedBox(height: CollectorySpacing.unit / 2),
                            Text(
                              _monthYearLabel(room.month),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

  int? _monthFromRoom(String raw) {
    final numeric = RegExp(r'^\d{4}-(\d{2})').firstMatch(raw);
    if (numeric != null) return int.tryParse(numeric.group(1)!);
    final text = RegExp(r'^([A-Za-z]{3,9})\s+\d{4}').firstMatch(raw);
    if (text == null) return null;
    final month = text.group(1)!.toLowerCase();
    const map = {
      'jan': 1,
      'january': 1,
      'feb': 2,
      'february': 2,
      'mar': 3,
      'march': 3,
      'apr': 4,
      'april': 4,
      'may': 5,
      'jun': 6,
      'june': 6,
      'jul': 7,
      'july': 7,
      'aug': 8,
      'august': 8,
      'sep': 9,
      'sept': 9,
      'september': 9,
      'oct': 10,
      'october': 10,
      'nov': 11,
      'november': 11,
      'dec': 12,
      'december': 12,
    };
    return map[month];
  }

  String _monthYearLabel(String raw) {
    final numeric = RegExp(r'^\d{4}-(\d{2})').firstMatch(raw);
    if (numeric != null) {
      final month = int.tryParse(numeric.group(1)!);
      final year = raw.substring(0, 4);
      const names = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      if (month != null && month >= 1 && month <= 12) {
        return '${names[month - 1]} $year';
      }
    }
    final parts = raw.split(' ');
    if (parts.length >= 2) return '${parts.first} ${parts[1]}';
    return raw;
  }
}
