import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/network_image/app_network_image.dart';
import '../../../../shared/models/article.dart';

class ArticleFeedCard extends StatelessWidget {
  const ArticleFeedCard({
    required this.article,
    this.isLiked = false,
    this.isDisliked = false,
    this.onLike,
    this.onDislike,
    this.onBlock,
    super.key,
  });

  final Article article;
  final bool isLiked;
  final bool isDisliked;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onBlock;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/article/${article.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 620;
              final image = AppNetworkImage(
                url: article.imageUrl ?? '',
                height: isWide ? 156 : 180,
                width: isWide ? 230 : double.infinity,
              );
              final content = _CardContent(
                article: article,
                isLiked: isLiked,
                isDisliked: isDisliked,
                onLike: onLike,
                onDislike: onDislike,
                onBlock: onBlock,
              );
              return isWide
                  ? Row(
                      children: [
                        Expanded(child: content),
                        const SizedBox(width: 16),
                        image,
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [image, const SizedBox(height: 16), content],
                    );
            },
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.article,
    required this.isLiked,
    required this.isDisliked,
    this.onLike,
    this.onDislike,
    this.onBlock,
  });

  final Article article;
  final bool isLiked;
  final bool isDisliked;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onBlock;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(
                // Show human-readable name; fall back gracefully.
                article.categoryName ?? article.categoryId ?? 'General',
              ),
            ),
            Chip(label: Text('${article.readMinutes} min read')),
          ],
        ),
        const SizedBox(height: 10),
        Text(article.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(article.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 16),
        Row(
          children: [
            // Safe first-letter avatar: avoid empty-string crash.
            CircleAvatar(
              child: Text(
                article.author.isNotEmpty
                    ? article.author[0].toUpperCase()
                    : '?',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${article.author} • ${DateFormatter.relative(article.publishedAt)}',
              ),
            ),
            IconButton(
              tooltip: 'Like',
              onPressed: onLike,
              icon: Icon(
                isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
              ),
            ),
            Text('${article.likes + (isLiked ? 1 : 0)}'),
            IconButton(
              tooltip: 'Dislike',
              onPressed: onDislike,
              icon: Icon(
                isDisliked
                    ? Icons.thumb_down_alt
                    : Icons.thumb_down_alt_outlined,
              ),
            ),
            Text('${article.dislikes + (isDisliked ? 1 : 0)}'),
            IconButton(
              tooltip: 'Block',
              onPressed: onBlock,
              icon: const Icon(Icons.block_rounded),
            ),
          ],
        ),
      ],
    );
  }
}
