import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';

class CategoryTab {
  const CategoryTab({this.id, required this.name});
  final String? id;
  final String name;
}

class CategoryFilterTabs extends StatelessWidget {
  const CategoryFilterTabs({
    super.key,
    required this.tabs,
    required this.activeId,
    required this.onSelect,
  });

  final List<CategoryTab> tabs;
  final String? activeId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final active = tab.id == activeId;
          return Material(
            color: active ? CollectoryColors.btnPrimaryBg : CollectoryColors.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: active
                    ? CollectoryColors.btnPrimaryBg
                    : CollectoryColors.borderLight,
              ),
            ),
            child: InkWell(
              onTap: () => onSelect(tab.id),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  tab.name,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: active
                        ? CollectoryColors.btnPrimaryText
                        : CollectoryColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
