import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/models/article.dart';
import '../../domain/repository/article_repository.dart';

enum ArticleEditorStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

class ArticleEditorState extends Equatable {
  const ArticleEditorState({
    this.status = ArticleEditorStatus.initial,
    this.article,
    this.error,
    this.image,
  });

  final ArticleEditorStatus status;
  final Article? article;
  final String? error;
  final XFile? image;

  bool get isLoading => status == ArticleEditorStatus.loading;
  bool get isSubmitting => status == ArticleEditorStatus.submitting;

  ArticleEditorState copyWith({
    ArticleEditorStatus? status,
    Article? article,
    String? error,
    bool clearError = false,
    XFile? image,
  }) {
    return ArticleEditorState(
      status: status ?? this.status,
      article: article ?? this.article,
      error: clearError ? null : error ?? this.error,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [status, article, error, image];
}

class ArticleEditorCubit extends Cubit<ArticleEditorState> {
  ArticleEditorCubit(this._repository) : super(const ArticleEditorState());

  final ArticleRepository _repository;
  final ImagePicker _picker = ImagePicker();

  Future<void> load(String? articleId) async {
    if (articleId == null) {
      emit(state.copyWith(status: ArticleEditorStatus.ready, clearError: true));
      return;
    }
    emit(state.copyWith(status: ArticleEditorStatus.loading, clearError: true));
    try {
      final article = await _repository.getArticle(articleId);
      emit(state.copyWith(status: ArticleEditorStatus.ready, article: article));
    } catch (error) {
      emit(
        state.copyWith(
          status: ArticleEditorStatus.failure,
          error: error.toString(),
        ),
      );
    }
  }

  Future<void> pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    emit(state.copyWith(image: image));
  }

  /// CreateArticleDto / UpdateArticleDto fields.
  Future<void> submit({
    required String userId,
    String? articleId,
    required String title,
    required String content,
    required String categoryId,
  }) async {
    emit(
      state.copyWith(status: ArticleEditorStatus.submitting, clearError: true),
    );
    try {
      if (articleId == null) {
        await _repository.createArticle(
          userId: userId,
          title: title,
          content: content,
          categoryId: categoryId,
          image: state.image,
        );
      } else {
        await _repository.editArticle(
          userId: userId,
          id: articleId,
          title: title,
          content: content,
          categoryId: categoryId,
          image: state.image,
        );
      }
      emit(state.copyWith(status: ArticleEditorStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          status: ArticleEditorStatus.failure,
          error: error.toString(),
        ),
      );
    }
  }
}
