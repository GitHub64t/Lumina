import '../repository/article_repository.dart';

class DeleteArticleUsecase {
  const DeleteArticleUsecase(this._repository);

  final ArticleRepository _repository;

  Future<void> call(String id) => _repository.deleteArticle(id);
}
