import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/collection_item.dart';
import 'collection_card.dart';

class CollectionGrid extends StatelessWidget {
  const CollectionGrid({
    super.key,
    required this.items,
    required this.categoryNames,
    required this.onItemTap,
  });

  final List<CollectionItem> items;
  final Map<String, String> categoryNames;
  final void Function(CollectionItem item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CollectionCard(
          item: item,
          categoryLabel: item.category != null
              ? categoryNames[item.category!]
              : null,
          onTap: () => onItemTap(item),
        );
      },
    );
  }
}
