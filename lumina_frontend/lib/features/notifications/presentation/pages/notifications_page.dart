import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_states/app_empty_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppEmptyState(
        title: 'No notifications',
        message:
            'Likes, comments, moderation alerts, and publishing updates will appear here.',
      ),
    );
  }
}
