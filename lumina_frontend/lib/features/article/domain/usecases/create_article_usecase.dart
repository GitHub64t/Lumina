import 'package:image_picker/image_picker.dart';

import '../repository/article_repository.dart';

class CreateArticleUsecase {
  const CreateArticleUsecase(this._repository);

  final ArticleRepository _repository;

  /// CreateArticleDto: userId, title, content, categoryId, image?
  Future<void> call({
    required String userId,
    required String title,
    required String content,
    required String categoryId,
    XFile? image,
  }) {
    return _repository.createArticle(
      userId: userId,
      title: title,
      content: content,
      categoryId: categoryId,
      image: image,
    );
  }
}
