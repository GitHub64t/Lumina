import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_states/app_empty_state.dart';

class MyArticlesPage extends StatelessWidget {
  const MyArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppEmptyState(
        title: 'Your articles will appear here',
        message:
            'Drafts, published stories, edit actions, delete actions, and performance analytics are managed from this screen.',
        action: FilledButton.icon(
          onPressed: () => context.go('/articles/create'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Create article'),
        ),
      ),
    );
  }
}
