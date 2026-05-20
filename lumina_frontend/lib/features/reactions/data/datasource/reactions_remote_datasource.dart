import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class ReactionsRemoteDatasource {
  const ReactionsRemoteDatasource(this._client);

  final DioClient _client;

  /// ReactToArticleDto: { userId, articleId, reactionType }
  /// [reactionType] must be `'like'` or `'dislike'`.
  Future<void> react({
    required String userId,
    required String articleId,
    required String reactionType,
  }) => _client.post(
    ApiConstants.reactArticle,
    data: {
      'userId': userId,
      'articleId': articleId,
      'reactionType': reactionType,
    },
  );

  /// BlockArticleDto: { userId, articleId }
  Future<void> block({
    required String userId,
    required String articleId,
  }) => _client.post(
    ApiConstants.blockArticle,
    data: {'userId': userId, 'articleId': articleId},
  );
}
