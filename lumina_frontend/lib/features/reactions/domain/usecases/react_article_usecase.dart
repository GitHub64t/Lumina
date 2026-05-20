import '../repository/reactions_repository.dart';

class ReactArticleUsecase {
  const ReactArticleUsecase(this._repository);

  final ReactionsRepository _repository;

  /// [reactionType] must be `'like'` or `'dislike'`.
  Future<void> call({
    required String userId,
    required String articleId,
    required String reactionType,
  }) => _repository.react(
    userId: userId,
    articleId: articleId,
    reactionType: reactionType,
  );
}
