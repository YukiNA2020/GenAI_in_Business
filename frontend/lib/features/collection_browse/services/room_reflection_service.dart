import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/collection_item.dart';

// ---------------------------------------------------------------------------
// Room Reflection Service
// Wraps POST /api/ai/generate-room-reflection
// ---------------------------------------------------------------------------

String get _reflectionApiBaseUrl {
  const fromEnv = String.fromEnvironment('API_BASE_URL');
  if (fromEnv.isNotEmpty) return fromEnv.replaceAll(RegExp(r'/$'), '');
  if (kIsWeb) return 'http://localhost:3000';
  if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000';
  return 'http://localhost:3000';
}

class RoomReflectionService {
  RoomReflectionService()
      : _dio = Dio(BaseOptions(baseUrl: _reflectionApiBaseUrl));

  final Dio _dio;

  Future<String> generateRoomReflection({
    required int? roomId,
    required String? roomLabel,
    required String? month,
    required List<CollectionItem> items,
  }) async {
    final payload = {
      if (roomId != null) 'roomId': roomId,
      if (roomLabel != null) 'roomLabel': roomLabel,
      if (month != null) 'month': month,
      'items': items
          .map((item) => {
                'title': item.title,
                'category': item.category,
                'tags': item.tags,
                'story': item.story,
                'location': item.location,
                'dateAcquired': item.dateAcquired,
              })
          .toList(),
    };

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/ai/generate-room-reflection',
        data: payload,
      );
      final data = response.data;
      if (data != null && data['success'] == true) {
        final reflection = data['data']?['reflection'];
        if (reflection is String && reflection.isNotEmpty) {
          return reflection;
        }
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw RoomReflectionException(
        'Failed to generate room reflection: ${e.message}',
        cause: e,
      );
    }
  }
}

class RoomReflectionException implements Exception {
  RoomReflectionException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => 'RoomReflectionException: $message';
}
