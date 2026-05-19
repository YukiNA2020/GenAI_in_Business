import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/collectory_theme.dart';

/// Figma Profile / Add — Favorite tags 固定四项
abstract final class CollectoryFavoriteTags {
  static const List<String> labels = [
    'Music',
    'Ticket',
    'Mineral',
    'Memory',
  ];

  /// UI tag label → API category slug (API_Contract.md / seed data)
  static String? categorySlugForTag(String tag) {
    return switch (tag) {
      'Music' => 'vinyl',
      'Ticket' => 'ticket',
      'Mineral' => 'mineral',
      'Memory' => 'postcard',
      _ => null,
    };
  }

  /// API category slug → Profile/Add tag chip label
  static String tagForCategorySlug(String? slug) {
    return switch (slug) {
      'vinyl' => 'Music',
      'ticket' => 'Ticket',
      'mineral' || 'crystal' => 'Mineral',
      'postcard' || 'souvenir' || 'stamp' => 'Memory',
      _ => labels.first,
    };
  }
}

class CollectoryFavoriteTagRow extends StatelessWidget {
  const CollectoryFavoriteTagRow({
    super.key,
    required this.activeTag,
    required this.onTagTap,
  });

  final String activeTag;
  final ValueChanged<String> onTagTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: CollectoryFavoriteTags.labels.map((tag) {
        final active = tag == activeTag;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: tag == CollectoryFavoriteTags.labels.last ? 0 : 6,
            ),
            child: CollectoryFavoriteTagChip(
              label: tag,
              active: active,
              onTap: () => onTagTap(tag),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class CollectoryFavoriteTagChip extends StatelessWidget {
  const CollectoryFavoriteTagChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? CollectoryColors.btnPrimaryBg : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active
                  ? CollectoryColors.btnPrimaryBg
                  : CollectoryColors.borderLight,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active
                  ? CollectoryColors.btnPrimaryText
                  : CollectoryColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
