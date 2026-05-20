import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/models/article.dart';
import '../../domain/repository/article_repository.dart';

enum ArticleDetailStatus {
  initial,
  loading,
  success,
  deleting,
  deleted,
  failure,
}

class ArticleDetailState extends Equatable {
  const ArticleDetailState({
    this.status = ArticleDetailStatus.initial,
    this.article,
    this.error,
    this.isLiked = false,
    this.isDisliked = false,
  });

  final ArticleDetailStatus status;
  final Article? article;
  final String? error;
  final bool isLiked;
  final bool isDisliked;

  ArticleDetailState copyWith({
    ArticleDetailStatus? status,
    Article? article,
    String? error,
    bool clearError = false,
    bool? isLiked,
    bool? isDisliked,
  }) {
    return ArticleDetailState(
      status: status ?? this.status,
      article: article ?? this.article,
      error: clearError ? null : error ?? this.error,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
    );
  }

  @override
  List<Object?> get props => [status, article, error, isLiked, isDisliked];
}

class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  ArticleDetailCubit(this._repository) : super(const ArticleDetailState());

  final ArticleRepository _repository;

  Future<void> load(String id) async {
    emit(state.copyWith(status: ArticleDetailStatus.loading, clearError: true));
    try {
      final article = await _repository.getArticle(id);
      emit(
        state.copyWith(status: ArticleDetailStatus.success, article: article),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ArticleDetailStatus.failure,
          error: error.toString(),
        ),
      );
    }
  }

  Future<void> delete(String id) async {
    emit(
      state.copyWith(status: ArticleDetailStatus.deleting, clearError: true),
    );
    try {
      await _repository.deleteArticle(id);
      emit(state.copyWith(status: ArticleDetailStatus.deleted));
    } catch (error) {
      emit(
        state.copyWith(
          status: ArticleDetailStatus.failure,
          error: error.toString(),
        ),
      );
    }
  }

  void like() =>
      emit(state.copyWith(isLiked: !state.isLiked, isDisliked: false));

  void dislike() =>
      emit(state.copyWith(isDisliked: !state.isDisliked, isLiked: false));
}
