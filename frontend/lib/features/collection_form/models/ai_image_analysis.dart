// 负责人：成员 E / 成员 5 — POST /api/ai/analyze-image 响应

class AiImageAnalysis {
  const AiImageAnalysis({
    required this.suggestedTitle,
    required this.suggestedCategory,
    required this.suggestedTags,
    required this.description,
  });

  final String suggestedTitle;
  final String suggestedCategory;
  final List<String> suggestedTags;
  final String description;

  factory AiImageAnalysis.fromJson(Map<String, dynamic> json) {
    final tags = json['suggestedTags'];
    return AiImageAnalysis(
      suggestedTitle: json['suggestedTitle']?.toString() ?? '',
      suggestedCategory: json['suggestedCategory']?.toString() ?? '',
      suggestedTags: tags is List ? tags.map((e) => e.toString()).toList() : const [],
      description: json['description']?.toString() ?? '',
    );
  }
}

/// 多风格故事：与 member_E/docs/prompts/prompt_story_styles.md 对齐
enum AiStoryStyle {
  concise('concise', 'Concise'),
  scrapbook('scrapbook', 'Scrapbook'),
  travel('travel', 'Travel'),
  vintage('vintage', 'Vintage');

  const AiStoryStyle(this.apiValue, this.label);

  final String apiValue;
  final String label;
}
