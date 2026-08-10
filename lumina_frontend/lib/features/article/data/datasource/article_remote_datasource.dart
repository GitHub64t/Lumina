import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response_parser.dart';
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
        if (category != null && category.isNotEmpty) 'categoryId': category,
        if (query != null && query.isNotEmpty) 'q': query,
        'page': page,
      },
    );
    return ApiResponseParser.list(
      response.data,
    ).map(ArticleModel.fromJson).toList();
  }

  Future<List<ArticleModel>> getMyArticles({int page = 1}) async {
    final response = await _client.get<dynamic>(
      ApiConstants.myArticles,
      query: {'page': page},
    );
    return ApiResponseParser.list(
      response.data,
    ).map(ArticleModel.fromJson).toList();
  }

  Future<ArticleModel> getArticle(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.articles}/$id',
    );
    final payload = ApiResponseParser.map(response.data, nestedKey: 'article');
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
        'featuredImage': featuredImageUrl,
      },
      
    );
    final payload = ApiResponseParser.map(response.data, nestedKey: 'article');
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
    final payload = ApiResponseParser.map(response.data, nestedKey: 'article');
    return ArticleModel.fromJson(payload);
  }

  Future<void> deleteArticle(String id) {
    return _client.delete('${ApiConstants.articles}/$id');
  }

  /// Uploads image via presigned URL and returns the public CDN URL.
  ///
  /// Flow:
  ///   1. POST /uploads/presigned-url → get uploadUrl + fileUrl
  ///   2. PUT [uploadUrl] with raw bytes and Content-Type header (no auth)
  ///   3. Return fileUrl for use in CreateArticleDto / UpdateArticleDto
  Future<String> _uploadImage(XFile image) async {
    // Step 1 — get presigned URL from our API.
    final presignedResp = await _client.post<Map<String, dynamic>>(
      ApiConstants.presignedUploads,
      data: {
        'contentType': image.mimeType ?? 'image/jpeg',
        'fileName': image.name,
      },
    );

    // Unwrap: response is { message, data: { uploadUrl, fileUrl, key, ... } }
    final payload = ApiResponseParser.map(presignedResp.data);

    final uploadUrl = (payload['uploadUrl'] ?? payload['url'] ?? '').toString();
    final fileUrl =
        (payload['fileUrl'] ??
                payload['publicUrl'] ??
                uploadUrl.split('?').first)
            .toString();
    final contentType =
        (payload['contentType'] ?? image.mimeType ?? 'image/jpeg').toString();

    if (uploadUrl.isEmpty) {
      throw Exception('Presigned upload URL not returned by server');
    }

    // Step 2 — PUT file bytes directly to S3.
    // Use a bare Dio (no auth interceptor, no base URL).
    final s3 = Dio()
      ..options.validateStatus = (status) =>
          status != null && status >= 200 && status < 300;

    final bytes = await image.readAsBytes();
    await s3.put<void>(
      uploadUrl,
      data: Stream.fromIterable(bytes.map((b) => [b])),
      options: Options(
        headers: {'Content-Type': contentType, 'Content-Length': bytes.length},
        // S3 presigned PUT must not include Authorization header.
        extra: {'skipAuth': true},
      ),
    );

    return fileUrl;
  }
}
