import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/responsive_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsivePage(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 760;
            final visual = _OnboardingVisual(isWide: isWide);
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Read, write, and refine your professional article feed.',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Follow categories, publish ideas, react to stories, and keep your reading workflow focused across phone, tablet, and web.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Start reading',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => context.go('/login'),
                ),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Create a new account'),
                ),
              ],
            );
            return isWide
                ? Row(
                    children: [
                      Expanded(child: copy),
                      const SizedBox(width: 42),
                      Expanded(child: visual),
                    ],
                  )
                : ListView(
                    children: [visual, const SizedBox(height: 28), copy],
                  );
          },
        ),
      ),
    );
  }
}

class _OnboardingVisual extends StatelessWidget {
  const _OnboardingVisual({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isWide ? 520 : 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: NetworkImage(
            'https://picsum.photos/seed/article-feed-onboarding/900/900',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          margin: const EdgeInsets.all(18),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: .78),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Text(
            'Personalized topics, clean reading, fast publishing.',
          ),
        ),
      ),
    );
  }
}
