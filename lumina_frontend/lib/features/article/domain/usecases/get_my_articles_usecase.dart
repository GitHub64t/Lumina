import '../../../../shared/models/article.dart';
import '../repository/article_repository.dart';

class GetMyArticlesUsecase {
  const GetMyArticlesUsecase(this._repository);

  final ArticleRepository _repository;

  Future<List<Article>> call({int page = 1}) {
    return _repository.fetchMyArticles(page: page);
  }
}
