import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/article_model.dart';

class ArticleRemoteDatasource {
  ArticleRemoteDatasource(this._client);

  final DioClient _client;

  Future<List<ArticleModel>> getArticles({
    String? category,
    String? query,
    int page = 1,
  }) async {
    final response = await _client.get<dynamic>(
      ApiConstants.articlesPreferences,
      query: {
        if (category != null && category.isNotEmpty) 'category': category,
        if (query != null && query.isNotEmpty) 'q': query,
        'page': page,
      },
    );
    return _parseArticleList(response.data);
  }

  Future<List<ArticleModel>> getMyArticles({int page = 1}) async {
    final response = await _client.get<dynamic>(
      ApiConstants.myArticles,
      query: {'page': page},
    );
    return _parseArticleList(response.data);
  }

  Future<ArticleModel> getArticle(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.articles}/$id',
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final envelope = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
    final payload = envelope['article'] is Map
        ? Map<String, dynamic>.from(envelope['article'] as Map)
        : envelope;
    return ArticleModel.fromJson(payload);
  }

  /// CreateArticleDto: { userId, title, content, featuredImage?, categoryId }
  Future<ArticleModel> createArticle({
    required String userId,
    required String title,
    required String content,
    required String categoryId,
    XFile? image,
  }) async {
    String? featuredImageUrl;
    if (image != null) {
      featuredImageUrl = await _uploadImage(image);
    }

    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.articles,
      data: {
        'userId': userId,
        'title': title,
        'content': content,
        'categoryId': categoryId,
        'featuredImage': ?featuredImageUrl,
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final envelope = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
    final payload = envelope['article'] is Map
        ? Map<String, dynamic>.from(envelope['article'] as Map)
        : envelope;
    return ArticleModel.fromJson(payload);
  }

  /// UpdateArticleDto: { userId, articleId, title?, content?, featuredImage?, categoryId? }
  Future<ArticleModel> editArticle({
    required String userId,
    required String id,
    required String title,
    required String content,
    String? categoryId,
    XFile? image,
  }) async {
    String? featuredImageUrl;
    if (image != null) {
      featuredImageUrl = await _uploadImage(image);
    }

    final response = await _client.patch<Map<String, dynamic>>(
      '${ApiConstants.articles}/$id',
      data: {
        'userId': userId,
        'articleId': id,
        'title': title,
        'content': content,
        'categoryId': ?categoryId,
        'featuredImage': ?featuredImageUrl,
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final envelope = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
    final payload = envelope['article'] is Map
        ? Map<String, dynamic>.from(envelope['article'] as Map)
        : envelope;
    return ArticleModel.fromJson(payload);
  }

  Future<void> deleteArticle(String id) {
    return _client.delete('${ApiConstants.articles}/$id');
  }

  /// CreatePresignedUploadUrlDto: { contentType, fileName? }
  /// Uploads image via presigned URL and returns the public URL.
  Future<String> _uploadImage(XFile image) async {
    final presignedResponse = await _client.post<Map<String, dynamic>>(
      ApiConstants.presignedUploads,
      data: {
        'contentType': image.mimeType ?? 'image/jpeg',
        'fileName': image.name,
      },
    );
    final presignedData = Map<String, dynamic>.from(
      presignedResponse.data as Map,
    );
    final uploadUrl = (presignedData['url'] ?? presignedData['uploadUrl'])
        .toString();
    final publicUrl = (presignedData['publicUrl'] ??
            presignedData['fileUrl'] ??
            uploadUrl.split('?').first)
        .toString();
    await Dio().put(
      uploadUrl,
      data: await image.readAsBytes(),
      options: Options(
        headers: {'Content-Type': image.mimeType ?? 'image/jpeg'},
      ),
    );
    return publicUrl;
  }

  List<ArticleModel> _parseArticleList(Object? data) {
    final payload = data is Map && data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
    final list = payload is Map
        ? payload['articles'] ?? payload['items'] ?? payload['data']
        : payload;
    return ((list ?? const []) as List)
        .map(
          (item) =>
              ArticleModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
