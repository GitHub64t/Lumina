import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({required this.child, this.padding = const EdgeInsets.all(24), super.key});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
