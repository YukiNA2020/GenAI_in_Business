// Member E — maps AI / API category display names to slugs and Add-page tags.

/// English category display name (API / AI) → API slug
const Map<String, String> aiCategoryNameToSlug = {
  'Minerals': 'mineral',
  'Crystals': 'crystal',
  'Vinyl Records': 'vinyl',
  'Postcards': 'postcard',
  'Tickets': 'ticket',
  'Travel Souvenirs': 'souvenir',
  'Stamps': 'stamp',
  'Other Collections': 'other',
};

/// API slug → English display name (for AI requests)
const Map<String, String> apiSlugToCategoryName = {
  'mineral': 'Minerals',
  'crystal': 'Crystals',
  'vinyl': 'Vinyl Records',
  'postcard': 'Postcards',
  'ticket': 'Tickets',
  'souvenir': 'Travel Souvenirs',
  'stamp': 'Stamps',
  'other': 'Other Collections',
};

/// slug → Add page CollectoryFavoriteTags label
String tagLabelForCategorySlug(String? slug) {
  return switch (slug) {
    'vinyl' => 'Music',
    'ticket' => 'Ticket',
    'mineral' || 'crystal' => 'Mineral',
    'postcard' || 'souvenir' || 'stamp' => 'Memory',
    _ => 'Memory',
  };
}

/// AI category display name → Add page tag label
String? tagLabelForAiCategory(String categoryName) {
  final slug = aiCategoryNameToSlug[categoryName] ?? categoryName;
  if (!apiSlugToCategoryName.containsKey(slug) &&
      !aiCategoryNameToSlug.containsKey(categoryName)) {
    return null;
  }
  return tagLabelForCategorySlug(
    aiCategoryNameToSlug[categoryName] ?? slug,
  );
}
