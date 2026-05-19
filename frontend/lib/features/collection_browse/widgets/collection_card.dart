import 'package:flutter/material.dart';

import '../../../core/theme/collectory_theme.dart';
import '../models/collection_item.dart';
import 'collection_exhibit_image.dart';

class CollectionCard extends StatelessWidget {
  const CollectionCard({
    super.key,
    required this.item,
    this.categoryLabel,
    this.onTap,
  });

  final CollectionItem item;
  final String? categoryLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = categoryLabel ?? item.category ?? 'Exhibit';
    return Material(
      color: CollectoryColors.bgCard,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CollectoryColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A17120F),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CollectionExhibitImage(
                      item: item,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: CollectoryColors.textLabel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                if (item.location != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.location!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CollectoryColors.textSecondary,
                    ),
                  ),
                ],
                if (item.dateAcquired != null)
                  Text(
                    item.dateAcquired!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CollectoryColors.textSecondary,
                    ),
                  ),
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.tags.take(3).map(_tagPill).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _tagPill(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: CollectoryColors.borderLight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 11,
          color: CollectoryColors.textSecondary,
        ),
      ),
    );
  }
}
