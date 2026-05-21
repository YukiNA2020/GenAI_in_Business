// 负责人：成员 E / 成员 5

/// 与 member_E/docs/AI_API_Contract.md 对齐的请求体。
class AiFormPayload {
  const AiFormPayload({
    required this.description,
    this.title,
    this.category,
    this.location,
    this.dateAcquired,
    this.imageDescription,
  });

  final String description;
  final String? title;
  final String? category;
  final String? location;
  final String? dateAcquired;
  final String? imageDescription;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'description': description.trim(),
    };
    void put(String key, String? value) {
      final v = value?.trim();
      if (v != null && v.isNotEmpty) map[key] = v;
    }

    put('title', title);
    put('category', category);
    put('location', location);
    put('dateAcquired', dateAcquired);
    put('imageDescription', imageDescription);
    return map;
  }
}
