import 'package:flutter/material.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({this.shrinkWrap = false, super.key});

  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline.withValues(alpha: .18);
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.all(24),
      itemBuilder: (context, index) => Container(
        height: 168,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: 5,
    );
  }
}
