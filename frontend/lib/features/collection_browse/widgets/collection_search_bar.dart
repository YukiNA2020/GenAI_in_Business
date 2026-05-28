import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';

class CollectionSearchBar extends StatelessWidget {
  const CollectionSearchBar({
    super.key,
    required this.controller,
    this.searching = false,
    this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final bool searching;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  static final _fieldStyle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: CollectoryColors.textPrimary,
  );

  static final _hintStyle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: CollectoryColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: _fieldStyle,
      decoration: InputDecoration(
        hintText: 'Search title, story, tags…',
        hintStyle: _hintStyle,
        filled: true,
        fillColor: CollectoryColors.bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: CollectoryColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: CollectoryColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: CollectoryColors.textLabel, width: 1.5),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (searching)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  controller.clear();
                  onClear?.call();
                  onChanged?.call('');
                },
              ),
          ],
        ),
      ),
    );
  }
}
