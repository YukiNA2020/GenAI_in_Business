import 'package:flutter/material.dart';

import '../../../core/theme/collectory_tokens.dart';
import '../../../core/theme/collectory_theme.dart';
import '../utils/collectory_room_catalog.dart';

/// Collection wall — 年度 / 月份下拉筛选
class WallDateFilterRow extends StatelessWidget {
  const WallDateFilterRow({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onYearChanged,
    required this.onMonthChanged,
  });

  final int? selectedYear;
  final int? selectedMonth;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<int?> onMonthChanged;

  static const _allYearsLabel = 'All years';
  static const _allMonthsLabel = 'All months';

  @override
  Widget build(BuildContext context) {
    final years = CollectoryRoomCatalog.wallFilterYears;

    return Row(
      children: [
        Expanded(
          child: _WallDropdown<int>(
            label: 'Year',
            value: selectedYear,
            hint: _allYearsLabel,
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text(_allYearsLabel),
              ),
              for (final y in years)
                DropdownMenuItem<int>(
                  value: y,
                  child: Text('$y'),
                ),
            ],
            onChanged: onYearChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _WallDropdown<int>(
            label: 'Month',
            value: selectedMonth,
            hint: _allMonthsLabel,
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text(_allMonthsLabel),
              ),
              for (var m = 1; m <= 12; m++)
                DropdownMenuItem<int>(
                  value: m,
                  child: Text(CollectoryRoomCatalog.monthLabel(m)),
                ),
            ],
            onChanged: onMonthChanged,
          ),
        ),
      ],
    );
  }
}

class _WallDropdown<T> extends StatelessWidget {
  const _WallDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CollectoryTypography.metaLabel.copyWith(
            fontSize: 9,
            letterSpacing: 0.4,
            color: CollectoryColors.textLabel,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: CollectoryColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: CollectoryColors.borderLight),
            ),
          ),
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
