import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_query_state.dart';

/// Collection wall sort — outlined dropdown (Figma: label Sort + Newest/Oldest).
class CollectionSortToggle extends StatelessWidget {
  const CollectionSortToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SortOption value;
  final ValueChanged<SortOption> onChanged;

  static final _valueStyle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: CollectoryColors.textPrimary,
  );

  static final _labelStyle = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: CollectoryColors.textSecondary,
  );

  static final _menuStyle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: CollectoryColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SortOption>(
      value: value,
      isExpanded: true,
      style: _valueStyle,
      icon: const Icon(
        Icons.arrow_drop_down,
        color: CollectoryColors.textPrimary,
        size: 22,
      ),
      dropdownColor: CollectoryColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      decoration: InputDecoration(
        labelText: 'Sort',
        labelStyle: _labelStyle,
        floatingLabelStyle: _labelStyle,
        filled: true,
        fillColor: CollectoryColors.bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: CollectoryColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: CollectoryColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: CollectoryColors.borderDark, width: 1.5),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: SortOption.newest,
          child: Text('Newest', style: _menuStyle),
        ),
        DropdownMenuItem(
          value: SortOption.oldest,
          child: Text('Oldest', style: _menuStyle),
        ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
