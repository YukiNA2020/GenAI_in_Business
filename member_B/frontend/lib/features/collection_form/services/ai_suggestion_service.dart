// 负责人：成员 E / 成员 5
// 调用成员 E 实现的 POST /api/ai/* 端点（见 member_E/docs/AI_API_Contract.md）

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collection_browse/services/collection_query_service.dart';
import '../models/ai_form_payload.dart';

final aiSuggestionServiceProvider = Provider<AiSuggestionService>(
  (ref) => AiSuggestionService(),
);

class AiSuggestionException implements Exception {
  AiSuggestionException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  final String code;
  final String message;
  final int? statusCode;

  bool get isUnavailable => code == 'AI_PROVIDER_UNAVAILABLE';

  @override
  String toString() => message;
}

class AiSuggestionService {
  AiSuggestionService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: apiBaseUrl,
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

  final Dio _dio;

  Future<List<String>> suggestTitle(AiFormPayload payload) async {
    final data = await _post('/api/ai/suggest-title', payload);
    final list = data['suggestions'];
    if (list is! List) {
      throw AiSuggestionException(
        code: 'AI_INVALID_RESPONSE',
        message: 'Invalid title suggestions',
      );
    }
    return list.map((e) => e.toString()).toList();
  }

  Future<({String category, double confidence})> suggestCategory(
    AiFormPayload payload,
  ) async {
    final data = await _post('/api/ai/suggest-category', payload);
    final category = data['category']?.toString();
    final confidence = data['confidence'];
    if (category == null || category.isEmpty) {
      throw AiSuggestionException(
        code: 'AI_INVALID_RESPONSE',
        message: 'Invalid category suggestion',
      );
    }
    return (
      category: category,
      confidence: confidence is num ? confidence.toDouble() : 0.0,
    );
  }

  Future<List<String>> suggestTags(AiFormPayload payload) async {
    final data = await _post('/api/ai/suggest-tags', payload);
    final list = data['tags'];
    if (list is! List) {
      throw AiSuggestionException(
        code: 'AI_INVALID_RESPONSE',
        message: 'Invalid tag suggestions',
      );
    }
    return list.map((e) => e.toString()).toList();
  }

  Future<String> generateStory(AiFormPayload payload) async {
    final data = await _post('/api/ai/generate-story', payload);
    final story = data['story']?.toString();
    if (story == null || story.trim().isEmpty) {
      throw AiSuggestionException(
        code: 'AI_INVALID_RESPONSE',
        message: 'Invalid story response',
      );
    }
    return story;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    AiFormPayload payload,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: payload.toJson(),
    );
    final body = response.data;
    if (body == null || body['success'] != true) {
      final error = body?['error'] as Map<String, dynamic>?;
      throw AiSuggestionException(
        code: error?['code'] as String? ?? 'UNKNOWN',
        message: error?['message'] as String? ??
            'AI suggestion is temporarily unavailable. You can still save manually.',
        statusCode: response.statusCode,
      );
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw AiSuggestionException(
        code: 'AI_INVALID_RESPONSE',
        message: 'AI returned an invalid response format.',
      );
    }
    return data;
  }
}
