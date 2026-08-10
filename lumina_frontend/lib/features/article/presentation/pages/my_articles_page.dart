import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/session_error_handler.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../dashboard/presentation/widgets/article_feed_view.dart';
import '../bloc/my_articles_cubit.dart';

class MyArticlesPage extends StatefulWidget {
  const MyArticlesPage({super.key});

  @override
  State<MyArticlesPage> createState() => _MyArticlesPageState();
}

class _MyArticlesPageState extends State<MyArticlesPage> {
  @override
  void initState() {
    super.initState();
    context.read<MyArticlesCubit>().load();
  }

  Future<void> _refreshArticles() async {
    final cubit = context.read<MyArticlesCubit>()..refresh();
    await cubit.stream.firstWhere(
      (state) =>
          state.status != MyArticlesStatus.refreshing &&
          state.status != MyArticlesStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/articles/create'),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Write'),
      ),
      body: BlocListener<MyArticlesCubit, MyArticlesState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == MyArticlesStatus.failure && state.error != null) {
            SessionErrorHandler.handle(context, state.error);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.status == MyArticlesStatus.pageFailure &&
              state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        child: BlocBuilder<MyArticlesCubit, MyArticlesState>(
          builder: (context, state) {
            return ArticleFeedView(
              title: 'My Articles',
              subtitle: 'Articles you have posted.',
              articles: state.articles,
              isLoading: state.status == MyArticlesStatus.loading,
              isFailure: state.status == MyArticlesStatus.failure,
              isEmpty: state.status == MyArticlesStatus.empty,
              isPaginating: state.status == MyArticlesStatus.paginating,
              errorMessage: state.error,
              emptyTitle: 'No articles yet',
              emptyMessage: "You haven't posted any articles yet.",
              emptyAction: FilledButton.icon(
                onPressed: () => context.go('/articles/create'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create article'),
              ),
              onRefresh: _refreshArticles,
              onRetry: () => context.read<MyArticlesCubit>().load(),
              onLoadMore: () => context.read<MyArticlesCubit>().loadNextPage(),
              likedArticleIds: state.likedArticleIds,
              dislikedArticleIds: state.dislikedArticleIds,
              onLike: (article) => context.read<MyArticlesCubit>().likeArticle(
                userId: context.read<AuthBloc>().state.user?.id ?? '',
                articleId: article.id,
              ),
              onDislike: (article) =>
                  context.read<MyArticlesCubit>().dislikeArticle(
                    userId: context.read<AuthBloc>().state.user?.id ?? '',
                    articleId: article.id,
                  ),
              onBlock: (article) {
                context.read<MyArticlesCubit>().blockArticle(
                  userId: context.read<AuthBloc>().state.user?.id ?? '',
                  articleId: article.id,
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
    );
  }
}

class MyArticlesScreen extends StatelessWidget {
  const MyArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyArticlesCubit>(),
      child: const MyArticlesPage(),
    );
  }
}
