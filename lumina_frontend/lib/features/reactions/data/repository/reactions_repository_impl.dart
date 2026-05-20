import '../../domain/repository/reactions_repository.dart';
import '../datasource/reactions_remote_datasource.dart';

class ReactionsRepositoryImpl implements ReactionsRepository {
  const ReactionsRepositoryImpl(this._remote);

  final ReactionsRemoteDatasource _remote;

  @override
  Future<void> react({
    required String userId,
    required String articleId,
    required String reactionType,
  }) => _remote.react(
    userId: userId,
    articleId: articleId,
    reactionType: reactionType,
  );

  @override
  Future<void> block({
    required String userId,
    required String articleId,
  }) => _remote.block(userId: userId, articleId: articleId);
}
