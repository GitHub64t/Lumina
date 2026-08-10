import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/chips/category_chip.dart';
import '../../../../core/utils/debounce.dart';
import '../../../../core/utils/session_error_handler.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../preferences/presentation/bloc/preferences_cubit.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/article_feed_view.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _search = TextEditingController();
  final _searchDebounce = Debounce(const Duration(milliseconds: 350));

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const FeedRequested());
  }

  @override
  void dispose() {
    _search.dispose();
    _searchDebounce.dispose();
    super.dispose();
  }

  Future<void> _refreshFeed() async {
    final bloc = context.read<FeedBloc>()..add(const FeedRefreshed());
    await bloc.stream.firstWhere(
      (state) =>
          state.status != FeedStatus.refreshing &&
          state.status != FeedStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Load real categories for the filter chips.
      create: (_) => PreferencesCubit(sl.preferencesRepository)..load(),
      child: Scaffold(
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
            if (state.status == FeedStatus.pageFailure && state.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          child: BlocBuilder<FeedBloc, FeedState>(
            builder: (context, feedState) {
              return ArticleFeedView(
                title: 'Your feed',
                subtitle: 'Personalised articles based on your interests.',
                articles: feedState.articles,
                isLoading: feedState.status == FeedStatus.loading,
                isFailure: feedState.status == FeedStatus.failure,
                isEmpty: feedState.status == FeedStatus.empty,
                isPaginating: feedState.status == FeedStatus.paginating,
                errorMessage: feedState.error,
                emptyTitle: 'Your feed is empty',
                emptyMessage:
                    'No articles match your current preferences.\n'
                    'Update your interests to see personalised content.',
                emptyAction: TextButton.icon(
                  onPressed: () => context.go('/preferences'),
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Set preferences'),
                ),
                headerControls: _FeedHeaderControls(
                  searchController: _search,
                  searchDebounce: _searchDebounce,
                  feedState: feedState,
                ),
                onRefresh: _refreshFeed,
                onRetry: () =>
                    context.read<FeedBloc>().add(const FeedRequested()),
                onLoadMore: () =>
                    context.read<FeedBloc>().add(const FeedNextPageRequested()),
                likedArticleIds: feedState.likedArticleIds,
                dislikedArticleIds: feedState.dislikedArticleIds,
                onLike: (article) => context.read<FeedBloc>().add(
                  FeedArticleLiked(
                    userId: context.read<AuthBloc>().state.user?.id ?? '',
                    articleId: article.id,
                  ),
                ),
                onDislike: (article) => context.read<FeedBloc>().add(
                  FeedArticleDisliked(
                    userId: context.read<AuthBloc>().state.user?.id ?? '',
                    articleId: article.id,
                  ),
                ),
                onBlock: (article) {
                  context.read<FeedBloc>().add(
                    FeedArticleBlocked(
                      userId: context.read<AuthBloc>().state.user?.id ?? '',
                      articleId: article.id,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Article hidden from this session'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeedHeaderControls extends StatelessWidget {
  const _FeedHeaderControls({
    required this.searchController,
    required this.searchDebounce,
    required this.feedState,
  });

  final TextEditingController searchController;
  final Debounce searchDebounce;
  final FeedState feedState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: (value) => searchDebounce(
            () => context.read<FeedBloc>().add(FeedSearchChanged(value)),
          ),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Search articles, authors, or topics',
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<PreferencesCubit, PreferencesState>(
          builder: (context, prefState) {
            final categories = prefState.categories;
            if (categories.isEmpty) {
              return const SizedBox.shrink();
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(
                    label: 'All',
                    selected: feedState.category == 'All',
                    onSelected: (_) => context.read<FeedBloc>().add(
                      const FeedCategoryChanged('All'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ...categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CategoryChip(
                        label: cat.name,
                        selected: feedState.category == cat.id,
                        onSelected: (_) => context.read<FeedBloc>().add(
                          FeedCategoryChanged(cat.id),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
