import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/models/article.dart';
import '../../../article/domain/usecases/get_articles_usecase.dart';
import '../../../reactions/domain/usecases/block_article_usecase.dart';
import '../../../reactions/domain/usecases/react_article_usecase.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc(
    this._getArticlesUsecase, {
    required ReactArticleUsecase reactArticleUsecase,
    required BlockArticleUsecase blockArticleUsecase,
  }) : _reactArticleUsecase = reactArticleUsecase,
       _blockArticleUsecase = blockArticleUsecase,
       super(const FeedState()) {
    on<FeedRequested>(_onRequested);
    on<FeedRefreshed>(_onRefreshed);
    on<FeedCategoryChanged>(_onCategoryChanged);
    on<FeedSearchChanged>(_onSearchChanged);
    on<FeedNextPageRequested>(_onNextPage);
    on<FeedArticleLiked>(_onLiked);
    on<FeedArticleDisliked>(_onDisliked);
    on<FeedArticleBlocked>(_onBlocked);
  }

  final GetArticlesUsecase _getArticlesUsecase;
  final ReactArticleUsecase _reactArticleUsecase;
  final BlockArticleUsecase _blockArticleUsecase;

  Future<void> _onRequested(
    FeedRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading, page: 1, clearError: true));
    await _load(emit, reset: true);
  }

  Future<void> _onRefreshed(
    FeedRefreshed event,
    Emitter<FeedState> emit,
  ) async {
    emit(
      state.copyWith(status: FeedStatus.refreshing, page: 1, clearError: true),
    );
    await _load(emit, reset: true);
  }

  Future<void> _onCategoryChanged(
    FeedCategoryChanged event,
    Emitter<FeedState> emit,
  ) async {
    emit(
      state.copyWith(
        category: event.category,
        status: FeedStatus.loading,
        page: 1,
        clearError: true,
      ),
    );
    await _load(emit, reset: true);
  }

  Future<void> _onSearchChanged(
    FeedSearchChanged event,
    Emitter<FeedState> emit,
  ) async {
    emit(
      state.copyWith(
        query: event.query,
        status: FeedStatus.loading,
        page: 1,
        clearError: true,
      ),
    );
    await _load(emit, reset: true);
  }

  Future<void> _onNextPage(
    FeedNextPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (state.status == FeedStatus.paginating || !state.hasMore) return;
    emit(
      state.copyWith(
        status: FeedStatus.paginating,
        page: state.page + 1,
        clearError: true,
      ),
    );
    await _load(emit);
  }

  Future<void> _load(Emitter<FeedState> emit, {bool reset = false}) async {
    try {
      final articles = await _getArticlesUsecase(
        category: state.category == 'All' ? null : state.category,
        query: state.query,
        page: state.page,
      );
      final next = reset ? articles : [...state.articles, ...articles];
      final visible = next
          .where((article) => !state.blockedArticleIds.contains(article.id))
          .toList();
      emit(
        state.copyWith(
          status: visible.isEmpty ? FeedStatus.empty : FeedStatus.success,
          articles: visible,
          hasMore: articles.length >= 10,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: FeedStatus.failure, error: error.toString()));
    }
  }

  void _onLiked(FeedArticleLiked event, Emitter<FeedState> emit) {
    final liked = {...state.likedArticleIds};
    final disliked = {...state.dislikedArticleIds}..remove(event.articleId);
    final isNowLiked = !liked.contains(event.articleId);
    isNowLiked ? liked.add(event.articleId) : liked.remove(event.articleId);

    // Update UI immediately, then persist to backend (fire-and-forget).
    emit(state.copyWith(likedArticleIds: liked, dislikedArticleIds: disliked));
    if (isNowLiked) {
      _reactArticleUsecase(
        userId: event.userId,
        articleId: event.articleId,
        reactionType: 'like',
      ).catchError((_) {});
    }
  }

  void _onDisliked(FeedArticleDisliked event, Emitter<FeedState> emit) {
    final disliked = {...state.dislikedArticleIds};
    final liked = {...state.likedArticleIds}..remove(event.articleId);
    final isNowDisliked = !disliked.contains(event.articleId);
    isNowDisliked
        ? disliked.add(event.articleId)
        : disliked.remove(event.articleId);

    // Update UI immediately, then persist to backend (fire-and-forget).
    emit(state.copyWith(likedArticleIds: liked, dislikedArticleIds: disliked));
    if (isNowDisliked) {
      _reactArticleUsecase(
        userId: event.userId,
        articleId: event.articleId,
        reactionType: 'dislike',
      ).catchError((_) {});
    }
  }

  void _onBlocked(FeedArticleBlocked event, Emitter<FeedState> emit) {
    final blocked = {...state.blockedArticleIds, event.articleId};
    final articles = state.articles
        .where((article) => article.id != event.articleId)
        .toList();
    emit(
      state.copyWith(
        articles: articles,
        blockedArticleIds: blocked,
        status: articles.isEmpty ? FeedStatus.empty : FeedStatus.success,
      ),
    );
    // Persist to backend (fire-and-forget).
    _blockArticleUsecase(
      userId: event.userId,
      articleId: event.articleId,
    ).catchError((_) {});
  }
}

