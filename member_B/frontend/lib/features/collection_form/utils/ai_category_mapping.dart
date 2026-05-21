// 负责人：成员 E / 成员 5（供成员 B 创建表单使用）
// 将 AI 返回的中文 category 映射到 Add 页 Favorite tag / API slug。

/// AI / 后端 categories 使用的中文名称 → API slug
const Map<String, String> aiChineseCategoryToSlug = {
  '矿石': 'mineral',
  '水晶': 'crystal',
  '黑胶唱片': 'vinyl',
  '明信片': 'postcard',
  '票根': 'ticket',
  '旅行纪念品': 'souvenir',
  '邮票': 'stamp',
  '其他': 'other',
};

/// API slug → 中文（发给 AI 接口）
const Map<String, String> apiSlugToChineseCategory = {
  'mineral': '矿石',
  'crystal': '水晶',
  'vinyl': '黑胶唱片',
  'postcard': '明信片',
  'ticket': '票根',
  'souvenir': '旅行纪念品',
  'stamp': '邮票',
  'other': '其他',
};

/// slug → Add 页 CollectoryFavoriteTags 标签
String tagLabelForCategorySlug(String? slug) {
  return switch (slug) {
    'vinyl' => 'Music',
    'ticket' => 'Ticket',
    'mineral' || 'crystal' => 'Mineral',
    'postcard' || 'souvenir' || 'stamp' => 'Memory',
    _ => 'Memory',
  };
}

/// AI 中文 category → Add 页 tag label
String? tagLabelForAiCategory(String chineseCategory) {
  final slug = aiChineseCategoryToSlug[chineseCategory];
  if (slug == null) return null;
  return tagLabelForCategorySlug(slug);
}
