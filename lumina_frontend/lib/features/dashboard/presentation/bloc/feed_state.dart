part of 'feed_bloc.dart';

enum FeedStatus {
  initial,
  loading,
  refreshing,
  success,
  empty,
  paginating,
  pageFailure,
  failure,
}

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.articles = const [],
    this.category = 'All',
    this.query = '',
    this.page = 1,
    this.hasMore = true,
    this.error,
    this.likedArticleIds = const {},
    this.dislikedArticleIds = const {},
    this.blockedArticleIds = const {},
  });

  final FeedStatus status;
  final List<Article> articles;
  final String category;
  final String query;
  final int page;
  final bool hasMore;
  final String? error;
  final Set<String> likedArticleIds;
  final Set<String> dislikedArticleIds;
  final Set<String> blockedArticleIds;

  FeedState copyWith({
    FeedStatus? status,
    List<Article>? articles,
    String? category,
    String? query,
    int? page,
    bool? hasMore,
    String? error,
    bool clearError = false,
    Set<String>? likedArticleIds,
    Set<String>? dislikedArticleIds,
    Set<String>? blockedArticleIds,
  }) {
    return FeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      category: category ?? this.category,
      query: query ?? this.query,
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
    category,
    query,
    page,
    hasMore,
    error,
    likedArticleIds,
    dislikedArticleIds,
    blockedArticleIds,
  ];
}
