import '../../../../shared/models/article.dart';
import '../repository/article_repository.dart';

class GetArticlesUsecase {
  const GetArticlesUsecase(this._repository);

  final ArticleRepository _repository;

  Future<List<Article>> call({String? category, String? query, int page = 1}) {
    return _repository.fetchFeed(category: category, query: query, page: page);
  }
}
