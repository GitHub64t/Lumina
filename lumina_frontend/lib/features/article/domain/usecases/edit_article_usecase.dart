import 'package:image_picker/image_picker.dart';

import '../repository/article_repository.dart';

class EditArticleUsecase {
  const EditArticleUsecase(this._repository);

  final ArticleRepository _repository;

  /// UpdateArticleDto: userId, articleId, title, content, categoryId?, image?
  Future<void> call({
    required String userId,
    required String id,
    required String title,
    required String content,
    String? categoryId,
    XFile? image,
  }) {
    return _repository.editArticle(
      userId: userId,
      id: id,
      title: title,
      content: content,
      categoryId: categoryId,
      image: image,
    );
  }
}
