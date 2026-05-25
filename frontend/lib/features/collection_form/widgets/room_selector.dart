// 负责人：成员 E / 成员 5 — 阶段四：Create 流 room 选择器

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/models/collection_room.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';

/// 正式 Create flow 的房间选择 dropdown。
class FormRoomSelector extends StatelessWidget {
  const FormRoomSelector({
    super.key,
    required this.rooms,
    required this.selectedRoomId,
    required this.onChanged,
    this.allowNull = false,
    this.decoration,
  });

  final List<CollectionRoomSummary> rooms;
  final int? selectedRoomId;
  final ValueChanged<int?> onChanged;
  final bool allowNull;
  final InputDecoration? decoration;

  InputDecoration _defaultDecoration() {
    return InputDecoration(
      hintText: 'Choose a room',
      hintStyle: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFFAF8F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CollectoryColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CollectoryColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CollectoryColors.borderDark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: rooms.any((r) => r.id == selectedRoomId) ? selectedRoomId : null,
      isExpanded: true,
      decoration: decoration ?? _defaultDecoration(),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
      items: [
        if (allowNull)
          const DropdownMenuItem<int>(
            value: null,
            child: Text('No room (unassigned)'),
          ),
        for (final room in rooms)
          DropdownMenuItem<int>(
            value: room.id,
            child: Text(
              _labelFor(room),
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: CollectoryColors.textPrimary,
              ),
            ),
          ),
      ],
      onChanged: rooms.isEmpty ? null : onChanged,
    );
  }

  String _labelFor(CollectionRoomSummary room) {
    final label = room.label ?? room.month;
    final count = room.collectionCount;
    if (count == null) return '$label · ${room.month}';
    return '$label · ${room.month} · $count exhibits';
  }
}
