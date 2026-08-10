part of 'my_articles_cubit.dart';

enum MyArticlesStatus {
  initial,
  loading,
  refreshing,
  success,
  empty,
  paginating,
  pageFailure,
  failure,
}

class MyArticlesState extends Equatable {
  const MyArticlesState({
    this.status = MyArticlesStatus.initial,
    this.articles = const [],
    this.page = 1,
    this.hasMore = true,
    this.error,
    this.likedArticleIds = const {},
    this.dislikedArticleIds = const {},
    this.blockedArticleIds = const {},
  });

  final MyArticlesStatus status;
  final List<Article> articles;
  final int page;
  final bool hasMore;
  final String? error;
  final Set<String> likedArticleIds;
  final Set<String> dislikedArticleIds;
  final Set<String> blockedArticleIds;

  MyArticlesState copyWith({
    MyArticlesStatus? status,
    List<Article>? articles,
    int? page,
    bool? hasMore,
    String? error,
    bool clearError = false,
    Set<String>? likedArticleIds,
    Set<String>? dislikedArticleIds,
    Set<String>? blockedArticleIds,
  }) {
    return MyArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
      likedArticleIds: likedArticleIds ?? this.likedArticleIds,
      dislikedArticleIds: dislikedArticleIds ?? this.dislikedArticleIds,
      blockedArticleIds: blockedArticleIds ?? this.blockedArticleIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    articles,
    page,
    hasMore,
    error,
    likedArticleIds,
    dislikedArticleIds,
    blockedArticleIds,
  ];
}
