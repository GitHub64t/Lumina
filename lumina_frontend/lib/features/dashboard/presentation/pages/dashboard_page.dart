import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/chips/category_chip.dart';
import '../../../../core/widgets/empty_states/app_empty_state.dart';
import '../../../../core/widgets/error_widgets/app_error_state.dart';
import '../../../../core/widgets/loaders/skeleton_loader.dart';
import '../../../../core/utils/session_error_handler.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/article_feed_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  final _categories = const [
    'All',
    'Design',
    'Engineering',
    'Product',
    'AI',
    'Business',
  ];

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const FeedRequested());
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 380) {
        context.read<FeedBloc>().add(const FeedNextPageRequested());
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/articles/create'),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Write'),
      ),
      body: BlocListener<FeedBloc, FeedState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == FeedStatus.failure && state.error != null) {
            SessionErrorHandler.handle(context, state.error);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        child: ResponsivePage(
          child: BlocBuilder<FeedBloc, FeedState>(
            builder: (context, state) {
              if (state.status == FeedStatus.loading) {
                return const SkeletonLoader();
              }
              if (state.status == FeedStatus.failure &&
                  state.articles.isEmpty) {
                return AppErrorState(
                  message: state.error ?? 'Unable to load feed',
                  onRetry: () =>
                      context.read<FeedBloc>().add(const FeedRequested()),
                );
              }
              if (state.status == FeedStatus.empty) {
                return RefreshIndicator(
                  onRefresh: () async =>
                      context.read<FeedBloc>().add(const FeedRefreshed()),
                  child: ListView(
                    children: const [
                      SizedBox(height: 160),
                      AppEmptyState(
                        title: 'No articles yet',
                        message:
                            'Change filters or publish the first article in this category.',
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<FeedBloc>().add(const FeedRefreshed()),
                child: CustomScrollView(
                  controller: _scroll,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your feed',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Personalized articles, trending categories, and quick publishing tools.',
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _search,
                            onChanged: (value) => context.read<FeedBloc>().add(
                              FeedSearchChanged(value),
                            ),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search_rounded),
                              hintText: 'Search articles, authors, or topics',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final category in _categories)
                                CategoryChip(
                                  label: category,
                                  selected: state.category == category,
                                  onSelected: (_) => context
                                      .read<FeedBloc>()
                                      .add(FeedCategoryChanged(category)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        final article = state.articles[index];
                        return ArticleFeedCard(
                          article: article,
                          isLiked: state.likedArticleIds.contains(article.id),
                          isDisliked: state.dislikedArticleIds.contains(
                            article.id,
                          ),
                          onLike: () => context.read<FeedBloc>().add(
                            FeedArticleLiked(
                              userId: context
                                  .read<AuthBloc>()
                                  .state
                                  .user
                                  ?.id ?? '',
                              articleId: article.id,
                            ),
                          ),
                          onDislike: () => context.read<FeedBloc>().add(
                            FeedArticleDisliked(
                              userId: context
                                  .read<AuthBloc>()
                                  .state
                                  .user
                                  ?.id ?? '',
                              articleId: article.id,
                            ),
                          ),
                          onBlock: () {
                            context.read<FeedBloc>().add(
                              FeedArticleBlocked(
                                userId: context
                                    .read<AuthBloc>()
                                    .state
                                    .user
                                    ?.id ?? '',
                                articleId: article.id,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Article hidden from this session',
                                ),
                              ),
                            );
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemCount: state.articles.length,
                    ),
                    if (state.status == FeedStatus.paginating)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
