import '../models/collection_item.dart';

/// design_tokens.json galleryObjectTypes — 四层展品分组
class GalleryLayerSpec {
  const GalleryLayerSpec({
    required this.key,
    required this.layerLabel,
    required this.defaultTitle,
    required this.categorySlugs,
    required this.cardColor,
    required this.accentColor,
  });

  final String key;
  final String layerLabel;
  final String defaultTitle;
  final List<String> categorySlugs;
  final int cardColor;
  final int accentColor;
}

const galleryLayerSpecs = [
  GalleryLayerSpec(
    key: 'vinyl',
    layerLabel: 'VINYL LAYERS',
    defaultTitle: 'Signed Vinyl',
    categorySlugs: ['vinyl'],
    cardColor: 0xFFC7A679,
    accentColor: 0xFF17120F,
  ),
  GalleryLayerSpec(
    key: 'ticket',
    layerLabel: 'TICKET LAYERS',
    defaultTitle: 'Concert Ticket',
    categorySlugs: ['ticket'],
    cardColor: 0xFFE8D7BD,
    accentColor: 0xFFC98250,
  ),
  GalleryLayerSpec(
    key: 'memory',
    layerLabel: 'MEMORY LAYERS',
    defaultTitle: 'Memory Note',
    categorySlugs: ['postcard', 'souvenir', 'stamp'],
    cardColor: 0xFFF4EBDD,
    accentColor: 0xFFC9D9D5,
  ),
  GalleryLayerSpec(
    key: 'mineral',
    layerLabel: 'MINERAL LAYERS',
    defaultTitle: 'Green Fluorite',
    categorySlugs: ['mineral', 'crystal'],
    cardColor: 0xFFC9D9D5,
    accentColor: 0xFF55746A,
  ),
];

CollectionItem? pickLayerItem(
  List<CollectionItem> items,
  GalleryLayerSpec spec,
) {
  for (final item in items) {
    final cat = item.category;
    if (cat != null && spec.categorySlugs.contains(cat)) return item;
  }
  return null;
}

String layerDisplayTitle(CollectionItem? item, GalleryLayerSpec spec) {
  if (item == null || item.title.isEmpty) return spec.defaultTitle;
  return item.title;
}

GalleryLayerSpec? galleryLayerSpecForCategory(String? category) {
  if (category == null) return null;
  for (final spec in galleryLayerSpecs) {
    if (spec.categorySlugs.contains(category)) return spec;
  }
  return null;
}

String galleryIllustrationKeyForCategory(String? category) {
  return galleryLayerSpecForCategory(category)?.key ?? 'memory';
}
