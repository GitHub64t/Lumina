import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_states/app_empty_state.dart';
import '../../../../core/widgets/error_widgets/app_error_state.dart';
import '../../../../core/widgets/loaders/skeleton_loader.dart';
import '../../../../shared/models/article.dart';
import '../../../../shared/widgets/responsive_page.dart';
import 'article_feed_card.dart';

class ArticleFeedView extends StatefulWidget {
  const ArticleFeedView({
    required this.title,
    required this.subtitle,
    required this.articles,
    required this.isLoading,
    required this.isFailure,
    required this.isEmpty,
    required this.isPaginating,
    required this.errorMessage,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRefresh,
    required this.onRetry,
    required this.onLoadMore,
    this.headerControls,
    this.emptyAction,
    this.likedArticleIds = const {},
    this.dislikedArticleIds = const {},
    this.onLike,
    this.onDislike,
    this.onBlock,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Article> articles;
  final bool isLoading;
  final bool isFailure;
  final bool isEmpty;
  final bool isPaginating;
  final String? errorMessage;
  final String emptyTitle;
  final String emptyMessage;
  final Widget? emptyAction;
  final Widget? headerControls;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final Set<String> likedArticleIds;
  final Set<String> dislikedArticleIds;
  final ValueChanged<Article>? onLike;
  final ValueChanged<Article>? onDislike;
  final ValueChanged<Article>? onBlock;

  @override
  State<ArticleFeedView> createState() => _ArticleFeedViewState();
}

class _ArticleFeedViewState extends State<ArticleFeedView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_maybeLoadMore)
      ..dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 380) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(child: _buildContent(context));
  }

  Widget _buildContent(BuildContext context) {
    if (widget.isLoading) {
      return const SkeletonLoader();
    }

    if (widget.isFailure && widget.articles.isEmpty) {
      return AppErrorState(
        message: widget.errorMessage ?? 'Unable to load articles',
        onRetry: widget.onRetry,
      );
    }

    if (widget.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          children: [
            const SizedBox(height: 80),
            AppEmptyState(
              title: widget.emptyTitle,
              message: widget.emptyMessage,
              action: widget.emptyAction,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(widget.subtitle),
                if (widget.headerControls != null) ...[
                  const SizedBox(height: 20),
                  widget.headerControls!,
                ],
                const SizedBox(height: 18),
              ],
            ),
          ),
          SliverList.separated(
            itemBuilder: (context, index) {
              final article = widget.articles[index];
              return ArticleFeedCard(
                article: article,
                isLiked: widget.likedArticleIds.contains(article.id),
                isDisliked: widget.dislikedArticleIds.contains(article.id),
                onLike: widget.onLike == null
                    ? null
                    : () => widget.onLike!(article),
                onDislike: widget.onDislike == null
                    ? null
                    : () => widget.onDislike!(article),
                onBlock: widget.onBlock == null
                    ? null
                    : () => widget.onBlock!(article),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemCount: widget.articles.length,
          ),
          if (widget.isPaginating)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}
