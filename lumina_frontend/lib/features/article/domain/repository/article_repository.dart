import 'package:image_picker/image_picker.dart';

import '../../../../shared/models/article.dart';

abstract class ArticleRepository {
  Future<List<Article>> fetchFeed({
    String? category,
    String? query,
    int page = 1,
  });

  Future<List<Article>> fetchMyArticles({int page = 1});

  Future<Article> getArticle(String id);

  /// CreateArticleDto fields: userId, title, content, categoryId, image?
  Future<Article> createArticle({
    required String userId,
    required String title,
    required String content,
    required String categoryId,
    XFile? image,
  });

  /// UpdateArticleDto fields: userId, articleId, title, content, categoryId?, image?
  Future<Article> editArticle({
    required String userId,
    required String id,
    required String title,
    required String content,
    String? categoryId,
    XFile? image,
  });

  Future<void> deleteArticle(String id);
}
