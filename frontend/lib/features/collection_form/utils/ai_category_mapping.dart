// AI category English display name → API slug
const Map<String, String> aiCategoryToSlug = {
  'Minerals': 'mineral',
  'Crystals': 'crystal',
  'Vinyl Records': 'vinyl',
  'Postcards': 'postcard',
  'Tickets': 'ticket',
  'Travel Souvenirs': 'souvenir',
  'Stamps': 'stamp',
  'Other Collections': 'other',
};

// API slug → AI category English display name (sent to AI as category hint)
const Map<String, String> apiSlugToAiCategory = {
  'mineral': 'Minerals',
  'crystal': 'Crystals',
  'vinyl': 'Vinyl Records',
  'postcard': 'Postcards',
  'ticket': 'Tickets',
  'souvenir': 'Travel Souvenirs',
  'stamp': 'Stamps',
  'other': 'Other Collections',
};

// slug → Add page CollectoryFavoriteTags label
String tagLabelForCategorySlug(String? slug) {
  return switch (slug) {
    'vinyl' => 'Music',
    'ticket' => 'Ticket',
    'mineral' || 'crystal' => 'Mineral',
    'postcard' || 'souvenir' || 'stamp' => 'Memory',
    _ => 'Memory',
  };
}

// AI English category display name → Add page tag label
String? tagLabelForAiCategory(String category) {
  final slug = aiCategoryToSlug[category];
  if (slug == null) return null;
  return tagLabelForCategorySlug(slug);
}