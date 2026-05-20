import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/error_widgets/app_error_state.dart';
import '../../../../core/utils/session_error_handler.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../dashboard/presentation/bloc/feed_bloc.dart';
import '../bloc/article_detail_cubit.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArticleDetailCubit(sl.articleRepository)..load(id),
      child: Scaffold(
        body: BlocConsumer<ArticleDetailCubit, ArticleDetailState>(
          listener: (context, state) {
            if (state.status == ArticleDetailStatus.deleted) {
              context.read<FeedBloc>().add(const FeedRefreshed());
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Article deleted')));
              context.go('/dashboard');
            }
            if (state.status == ArticleDetailStatus.failure &&
                state.error != null) {
              SessionErrorHandler.handle(context, state.error);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (context, state) {
            final article = state.article;
            if (state.status == ArticleDetailStatus.failure) {
              return AppErrorState(
                message: state.error ?? 'Unable to load article',
                onRetry: () => context.read<ArticleDetailCubit>().load(id),
              );
            }
            if (state.status == ArticleDetailStatus.loading ||
                article == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ResponsivePage(
              child: ListView(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      article.imageUrl ?? '',
                      height: 360,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Wrap(
                    spacing: 10,
                    children: [
                      Chip(
                        label: Text(article.categoryId ?? 'General'),
                      ),
                      Chip(label: Text('${article.readMinutes} min read')),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'By ${article.author}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    article.body,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () =>
                            context.read<ArticleDetailCubit>().like(),
                        icon: Icon(
                          state.isLiked
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined,
                        ),
                        label: Text(
                          'Like ${article.likes + (state.isLiked ? 1 : 0)}',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.read<ArticleDetailCubit>().dislike(),
                        icon: Icon(
                          state.isDisliked
                              ? Icons.thumb_down_alt
                              : Icons.thumb_down_alt_outlined,
                        ),
                        label: Text(
                          'Dislike ${article.dislikes + (state.isDisliked ? 1 : 0)}',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.go('/articles/${article.id}/edit'),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit'),
                      ),
                      OutlinedButton.icon(
                        onPressed: state.status == ArticleDetailStatus.deleting
                            ? null
                            : () => context.read<ArticleDetailCubit>().delete(
                                article.id,
                              ),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
