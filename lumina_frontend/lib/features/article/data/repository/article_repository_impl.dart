import 'package:image_picker/image_picker.dart';

import '../../../../shared/models/article.dart';
import '../../domain/repository/article_repository.dart';
import '../datasource/article_remote_datasource.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  ArticleRepositoryImpl({required ArticleRemoteDatasource remote})
    : _remote = remote;

  final ArticleRemoteDatasource _remote;

  @override
  Future<List<Article>> fetchFeed({
    String? category,
    String? query,
    int page = 1,
  }) async {
    return _remote.getArticles(category: category, query: query, page: page);
  }

  @override
  Future<Article> getArticle(String id) => _remote.getArticle(id);

  @override
  Future<void> createArticle({
    required String userId,
    required String title,
    required String content,
    required String categoryId,
    XFile? image,
  }) => _remote.createArticle(
    userId: userId,
    title: title,
    content: content,
    categoryId: categoryId,
    image: image,
  );

  @override
  Future<void> editArticle({
    required String userId,
    required String id,
    required String title,
    required String content,
    String? categoryId,
    XFile? image,
  }) => _remote.editArticle(
    userId: userId,
    id: id,
    title: title,
    content: content,
    categoryId: categoryId,
    image: image,
  );

  @override
  Future<void> deleteArticle(String id) => _remote.deleteArticle(id);
}
