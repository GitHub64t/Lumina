import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/models/article.dart';
import '../../../reactions/domain/usecases/block_article_usecase.dart';
import '../../../reactions/domain/usecases/react_article_usecase.dart';
import '../../domain/usecases/get_my_articles_usecase.dart';

part 'my_articles_state.dart';

class MyArticlesCubit extends Cubit<MyArticlesState> {
  MyArticlesCubit(
    this._getMyArticlesUsecase, {
    required ReactArticleUsecase reactArticleUsecase,
    required BlockArticleUsecase blockArticleUsecase,
  }) : _reactArticleUsecase = reactArticleUsecase,
       _blockArticleUsecase = blockArticleUsecase,
       super(const MyArticlesState());

  final GetMyArticlesUsecase _getMyArticlesUsecase;
  final ReactArticleUsecase _reactArticleUsecase;
  final BlockArticleUsecase _blockArticleUsecase;

  Future<void> load() async {
    emit(state.copyWith(status: MyArticlesStatus.loading, page: 1));
    await _load(reset: true);
  }

  Future<void> refresh() async {
    emit(
      state.copyWith(
        status: MyArticlesStatus.refreshing,
        page: 1,
        clearError: true,
      ),
    );
    await _load(reset: true);
  }

  Future<void> loadNextPage() async {
    if (state.status == MyArticlesStatus.loading ||
        state.status == MyArticlesStatus.refreshing ||
        state.status == MyArticlesStatus.paginating ||
        !state.hasMore) {
      return;
    }

    emit(
      state.copyWith(
        status: MyArticlesStatus.paginating,
        page: state.page + 1,
        clearError: true,
      ),
    );
    await _load();
  }

  Future<void> _load({bool reset = false}) async {
    try {
      final articles = await _getMyArticlesUsecase(page: state.page);
      final next = reset ? articles : [...state.articles, ...articles];
      final visible = next
          .where((article) => !state.blockedArticleIds.contains(article.id))
          .toList();

      emit(
        state.copyWith(
          status: visible.isEmpty
              ? MyArticlesStatus.empty
              : MyArticlesStatus.success,
          articles: visible,
          hasMore: articles.length >= 10,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: reset
              ? MyArticlesStatus.failure
              : MyArticlesStatus.pageFailure,
          page: reset ? 1 : state.page - 1,
          error: error.toString(),
        ),
      );
    }
  }

  void likeArticle({required String userId, required String articleId}) {
    if (userId.isEmpty) {
      emit(
        state.copyWith(
          status: MyArticlesStatus.failure,
          error: 'User session is missing. Please log in again.',
        ),
      );
      return;
    }

    final liked = {...state.likedArticleIds};
    final disliked = {...state.dislikedArticleIds}..remove(articleId);
    final isNowLiked = !liked.contains(articleId);
    isNowLiked ? liked.add(articleId) : liked.remove(articleId);

    emit(state.copyWith(likedArticleIds: liked, dislikedArticleIds: disliked));
    if (isNowLiked) {
      _reactArticleUsecase(
        userId: userId,
        articleId: articleId,
        reactionType: 'like',
      ).catchError((_) {});
    }
  }

  void dislikeArticle({required String userId, required String articleId}) {
    if (userId.isEmpty) {
      emit(
        state.copyWith(
          status: MyArticlesStatus.failure,
          error: 'User session is missing. Please log in again.',
        ),
      );
      return;
    }

    final disliked = {...state.dislikedArticleIds};
    final liked = {...state.likedArticleIds}..remove(articleId);
    final isNowDisliked = !disliked.contains(articleId);
    isNowDisliked ? disliked.add(articleId) : disliked.remove(articleId);

    emit(state.copyWith(likedArticleIds: liked, dislikedArticleIds: disliked));
    if (isNowDisliked) {
      _reactArticleUsecase(
        userId: userId,
        articleId: articleId,
        reactionType: 'dislike',
      ).catchError((_) {});
    }
  }

  void blockArticle({required String userId, required String articleId}) {
    if (userId.isEmpty) {
      emit(
        state.copyWith(
          status: MyArticlesStatus.failure,
          error: 'User session is missing. Please log in again.',
        ),
      );
      return;
    }

    final blocked = {...state.blockedArticleIds, articleId};
    final articles = state.articles
        .where((article) => article.id != articleId)
        .toList();
    emit(
      state.copyWith(
        articles: articles,
        blockedArticleIds: blocked,
        status: articles.isEmpty
            ? MyArticlesStatus.empty
            : MyArticlesStatus.success,
      ),
    );

    _blockArticleUsecase(
      userId: userId,
      articleId: articleId,
    ).catchError((_) {});
  }
}
