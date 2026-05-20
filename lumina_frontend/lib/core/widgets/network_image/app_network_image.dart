import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.height,
    this.width,
    this.borderRadius = 18,
    super.key,
  });

  final String url;
  final double? height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: width,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: height,
          width: width,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: .18),
        ),
        errorWidget: (context, url, error) => Container(
          height: height,
          width: width,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: .18),
          child: const Icon(Icons.image_not_supported_rounded),
        ),
      ),
    );
  }
}
