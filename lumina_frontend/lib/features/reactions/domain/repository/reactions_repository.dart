abstract class ReactionsRepository {
  /// ReactToArticleDto: userId, articleId, reactionType ('like' or 'dislike').
  Future<void> react({
    required String userId,
    required String articleId,
    required String reactionType,
  });

  /// BlockArticleDto: userId, articleId.
  Future<void> block({required String userId, required String articleId});
}
