import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    this.size = 72.0,
    this.showText = false,
    super.key,
  });

  final double size;
  final bool showText;

  static const String assetPath = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(size * 0.22),
              ),
              child: Icon(
                Icons.article_rounded,
                size: size * 0.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'LUMINA',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
          ),
        ],
      ],
    );
  }
}
