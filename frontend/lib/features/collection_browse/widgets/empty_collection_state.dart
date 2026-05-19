import 'package:flutter/material.dart';

import '../../../core/theme/collectory_theme.dart';

class EmptyCollectionState extends StatelessWidget {
  const EmptyCollectionState({
    super.key,
    this.title = 'No matching exhibits',
    this.description = 'Try adjusting your search or filters.',
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      decoration: BoxDecoration(
        color: CollectoryColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CollectoryColors.borderLight,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Text(
            '◇',
            style: TextStyle(
              fontSize: 40,
              color: CollectoryColors.textLabel.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: CollectoryColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
