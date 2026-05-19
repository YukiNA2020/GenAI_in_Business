import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/collection_item.dart';
import '../models/collection_query_state.dart';

// ---------------------------------------------------------------------------
// 数据流（成员 3 必须通过 backend 访问 SQLite，禁止前端直连数据库）：
//   Flutter → HTTP → backend (Express) → repository → sql.js → data/collectory.db
// 端点见 backend/src/app.js 与 API_Contract.md
// ---------------------------------------------------------------------------

/// `dart-define=API_BASE_URL=http://host:3000`
String get apiBaseUrl {
  const fromEnv = String.fromEnvironment('API_BASE_URL');
  if (fromEnv.isNotEmpty) return fromEnv.replaceAll(RegExp(r'/$'), '');
  if (kIsWeb) return 'http://localhost:3000';
  if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000';
  return 'http://localhost:3000';
}

const demoUserId = int.fromEnvironment('DEMO_USER_ID', defaultValue: 1);

class ApiClient {
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: apiBaseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  final Dio _dio;

  /// GET /api/health — backend/src/app.js
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/health');
      return response.data?['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    final body = response.data;
    if (body == null || body['success'] != true) {
      throw _apiException(body, response.statusCode);
    }
    return body['data'] as T;
  }

  Future<void> delete(String path) async {
    final response = await _dio.delete<Map<String, dynamic>>(path);
    final body = response.data;
    if (body == null || body['success'] != true) {
      throw _apiException(body, response.statusCode);
    }
  }

  /// POST /api/collections — API_Contract.md §3.2
  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: body);
    final data = response.data;
    if (data == null || data['success'] != true) {
      throw _apiException(data, response.statusCode);
    }
    return data['data'] as Map<String, dynamic>;
  }

  /// PUT /api/collections/:id
  Future<Map<String, dynamic>> put(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(path, data: body);
    final data = response.data;
    if (data == null || data['success'] != true) {
      throw _apiException(data, response.statusCode);
    }
    return data['data'] as Map<String, dynamic>;
  }

  /// POST /api/collections/:id/image — multipart field `image`
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData formData,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: formData,
    );
    final data = response.data;
    if (data == null || data['success'] != true) {
      throw _apiException(data, response.statusCode);
    }
    return data['data'] as Map<String, dynamic>;
  }

  ApiException _apiException(Map<String, dynamic>? body, int? statusCode) {
    final error = body?['error'] as Map<String, dynamic>?;
    return ApiException(
      code: error?['code'] as String? ?? 'UNKNOWN',
      message: error?['message'] as String? ?? 'Request failed',
      statusCode: statusCode,
      fields: (error?['fields'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      ),
    );
  }
}

class ApiException implements Exception {
  ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.fields,
  });

  final String code;
  final String message;
  final int? statusCode;
  final Map<String, String>? fields;

  @override
  String toString() => '$code: $message';
}

/// 规范化 DB/API 的 `image_url` / `imageUrl` 字符串。
String? normalizeImageUrlField(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  return trimmed.replaceAll('\\', '/');
}

/// 将 `imageUrl` 转为可请求的绝对地址（API_Contract §3 + §4 静态 `/uploads`）。
String resolveCollectionImageUrl({
  required int collectionId,
  String? imageUrl,
}) {
  final normalized = normalizeImageUrlField(imageUrl);
  if (normalized == null) return '';

  if (normalized.startsWith('http://') ||
      normalized.startsWith('https://') ||
      normalized.startsWith('data:')) {
    return normalized;
  }

  var path = normalized.startsWith('/') ? normalized : '/$normalized';
  // 仅 seed 占位：旧库可能是 .jpg，磁盘上为 .png
  if (path.contains('/uploads/collections/seed-') && path.endsWith('.jpg')) {
    path = '${path.substring(0, path.length - 4)}.png';
  }
  return '$apiBaseUrl$path';
}

/// 加载顺序：① 合同静态路径 ② `GET /api/collections/:id/image`（读 DB `image_url` 文件）
List<String> collectionImageLoadUrls({
  required int collectionId,
  String? imageUrl,
}) {
  final urls = <String>[];
  final staticUrl = resolveCollectionImageUrl(
    collectionId: collectionId,
    imageUrl: imageUrl,
  );
  if (staticUrl.isNotEmpty) {
    urls.add(staticUrl);
  }
  final apiImage = '$apiBaseUrl/api/collections/$collectionId/image';
  if (!urls.contains(apiImage)) {
    urls.add(apiImage);
  }
  return urls;
}

@Deprecated('Use resolveCollectionImageUrl(collectionId:, imageUrl:)')
String resolveImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return '';
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }
  final base = apiBaseUrl;
  return '$base${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
}

// ---------------------------------------------------------------------------
// 业务模型与 service — 端点与 backend 路由一致
// ---------------------------------------------------------------------------

class CategoryOption {
  const CategoryOption({
    required this.id,
    required this.name,
    this.icon,
    this.displayPriority,
    this.fields = const [],
  });

  final String id;
  final String name;
  final String? icon;
  final int? displayPriority;
  /// GET /api/categories — customFields 字段 label（成员 1 冻结）
  final List<String> fields;

  factory CategoryOption.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'];
    List<String> fields = [];
    if (rawFields is List) {
      fields = rawFields.map((e) {
        if (e is String) return e;
        if (e is Map) {
          return (e['name'] ?? e['id'] ?? e['key'] ?? e).toString();
        }
        return e.toString();
      }).toList();
    }
    return CategoryOption(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      displayPriority: (json['displayPriority'] as num?)?.toInt(),
      fields: fields,
    );
  }
}

class CollectionListResult {
  const CollectionListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<CollectionItem> items;
  final int total;
  final int page;
  final int pageSize;
}

class UserStats {
  const UserStats({
    required this.totalCollections,
    required this.categoryCount,
    required this.publicCollections,
    required this.recentCollections,
  });

  final int totalCollections;
  final int categoryCount;
  final int publicCollections;
  final List<CollectionItem> recentCollections;
}

class CollectionQueryService {
  CollectionQueryService([ApiClient? client]) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<bool> checkHealth() => _api.checkHealth();

  /// GET /api/collections
  Future<CollectionListResult> fetchCollections(
    CollectionQueryState state,
  ) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/api/collections',
      queryParameters: state.toQueryParams(),
    );
    final items = (data['items'] as List)
        .map((e) => CollectionItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return CollectionListResult(
      items: items,
      total: (data['total'] as num).toInt(),
      page: (data['page'] as num).toInt(),
      pageSize: (data['pageSize'] as num).toInt(),
    );
  }

  /// GET /api/collections/:id
  Future<CollectionItem> fetchById(int id) async {
    final data = await _api.get<Map<String, dynamic>>('/api/collections/$id');
    return CollectionItem.fromJson(data);
  }

  /// DELETE /api/collections/:id
  Future<void> deleteById(int id) => _api.delete('/api/collections/$id');

  /// GET /api/categories/:id
  Future<CategoryOption> fetchCategoryById(String id) async {
    final data = await _api.get<Map<String, dynamic>>('/api/categories/$id');
    return CategoryOption.fromJson(data);
  }

  /// GET /api/categories
  Future<List<CategoryOption>> fetchCategories() async {
    final data = await _api.get<List<dynamic>>('/api/categories');
    final list = data
        .map((e) => CategoryOption.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort(
      (a, b) => (a.displayPriority ?? 99).compareTo(b.displayPriority ?? 99),
    );
    return list;
  }

  /// GET /api/users/:id/stats
  Future<UserStats> fetchUserStats(int userId) async {
    final data =
        await _api.get<Map<String, dynamic>>('/api/users/$userId/stats');
    final recent = (data['recentCollections'] as List)
        .map((e) => CollectionItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return UserStats(
      totalCollections: (data['totalCollections'] as num).toInt(),
      categoryCount: (data['categoryCount'] as num).toInt(),
      publicCollections: (data['publicCollections'] as num).toInt(),
      recentCollections: recent,
    );
  }

  /// 公开列表：GET /api/collections?visibility=public（SQLite WHERE）
  Future<List<CollectionItem>> fetchPublicCollections() async {
    final result = await fetchCollections(
      const CollectionQueryState(
        page: 1,
        pageSize: 100,
        visibility: 'public',
      ),
    );
    return result.items;
  }

  /// GET /api/collections/tags — 从 SQLite collections.tags 聚合
  Future<List<String>> fetchAllTags() async {
    final data = await _api.get<List<dynamic>>('/api/collections/tags');
    return data.map((e) => e.toString()).toList();
  }

  /// POST /api/collections — create exhibit (Member 2 contract; wired for Add draft)
  Future<CollectionItem> createCollection({
    required String title,
    String? category,
    String? story,
    String? visibility,
    List<String>? tags,
    int? userId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      if (category != null && category.isNotEmpty) 'category': category,
      if (story != null && story.trim().isNotEmpty) 'story': story.trim(),
      if (visibility != null) 'visibility': visibility,
      if (tags != null && tags.isNotEmpty) 'tags': tags,
      if (userId != null) 'userId': userId,
    };
    final data = await _api.post(
      '/api/collections',
      body: body,
    );
    return CollectionItem.fromJson(data);
  }

  /// PUT /api/collections/:id
  Future<CollectionItem> updateCollection(
    int id, {
    String? title,
    String? category,
    String? story,
    String? location,
    String? dateAcquired,
    String? visibility,
    List<String>? tags,
  }) async {
    final body = <String, dynamic>{
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (story != null) 'story': story,
      if (location != null) 'location': location,
      if (dateAcquired != null) 'dateAcquired': dateAcquired,
      if (visibility != null) 'visibility': visibility,
      if (tags != null) 'tags': tags,
    };
    final data = await _api.put('/api/collections/$id', body: body);
    return CollectionItem.fromJson(data);
  }

  /// POST /api/collections/:id/image
  Future<CollectionItem> uploadCollectionImage(
    int id, {
    required List<int> bytes,
    required String filename,
  }) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final data = await _api.postMultipart(
      '/api/collections/$id/image',
      formData: formData,
    );
    return CollectionItem.fromJson(data);
  }
}
