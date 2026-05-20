import '../repository/reactions_repository.dart';

class BlockArticleUsecase {
  const BlockArticleUsecase(this._repository);

  final ReactionsRepository _repository;

  /// BlockArticleDto: userId + articleId.
  Future<void> call({
    required String userId,
    required String articleId,
  }) => _repository.block(userId: userId, articleId: articleId);
}
