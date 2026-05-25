// 负责人：成员 E / 成员 5 — 阶段四：正式 category 选择器

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';

/// API category slug → 展示用中文名称。
const Map<String, String> _categoryDisplayNames = {
  'mineral': 'Mineral',
  'crystal': 'Crystal',
  'vinyl': 'Vinyl',
  'ticket': 'Ticket',
  'postcard': 'Postcard',
  'souvenir': 'Souvenir',
  'stamp': 'Stamp',
  'other': 'Other',
};

final List<String> _allCategorySlugs = _categoryDisplayNames.keys.toList()
  ..sort((a, b) => _categoryDisplayNames[a]!.compareTo(
        _categoryDisplayNames[b]!,
      ));

/// 正式 Create flow 的 category 下拉选择器。
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selectedSlug,
    required this.onChanged,
    this.decoration,
  });

  final String? selectedSlug;
  final ValueChanged<String?> onChanged;
  final InputDecoration? decoration;

  InputDecoration _defaultDecoration() {
    return InputDecoration(
      hintText: 'Select a category',
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
    return DropdownButtonFormField<String>(
      value: _allCategorySlugs.contains(selectedSlug) ? selectedSlug : null,
      isExpanded: true,
      decoration: decoration ?? _defaultDecoration(),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('No category'),
        ),
        for (final slug in _allCategorySlugs)
          DropdownMenuItem<String>(
            value: slug,
            child: Text(
              _categoryDisplayNames[slug]!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: CollectoryColors.textPrimary,
              ),
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
