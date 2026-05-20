part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedRequested extends FeedEvent {
  const FeedRequested();
}

class FeedRefreshed extends FeedEvent {
  const FeedRefreshed();
}

class FeedCategoryChanged extends FeedEvent {
  const FeedCategoryChanged(this.category);
  final String category;

  @override
  List<Object?> get props => [category];
}

class FeedSearchChanged extends FeedEvent {
  const FeedSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class FeedNextPageRequested extends FeedEvent {
  const FeedNextPageRequested();
}

class FeedArticleLiked extends FeedEvent {
  const FeedArticleLiked({required this.userId, required this.articleId});

  final String userId;
  final String articleId;

  @override
  List<Object?> get props => [userId, articleId];
}

class FeedArticleDisliked extends FeedEvent {
  const FeedArticleDisliked({required this.userId, required this.articleId});

  final String userId;
  final String articleId;

  @override
  List<Object?> get props => [userId, articleId];
}

class FeedArticleBlocked extends FeedEvent {
  const FeedArticleBlocked({required this.userId, required this.articleId});

  final String userId;
  final String articleId;

  @override
  List<Object?> get props => [userId, articleId];
}
