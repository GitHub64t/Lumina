import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/extensions.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const destinations = [
    _Destination('Feed', AppIcons.home, '/dashboard'),
    _Destination('Search', AppIcons.search, '/search'),
    _Destination('Create', AppIcons.create, '/articles/create'),
    _Destination('Alerts', AppIcons.notifications, '/notifications'),
    _Destination('Settings', AppIcons.settings, '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = destinations.indexWhere(
      (item) => location.startsWith(item.path),
    );
    final selectedIndex = index < 0 ? 0 : index;

    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              extended: true,
              onDestinationSelected: (value) =>
                  context.go(destinations[value].path),
              destinations: [
                for (final item in destinations)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
              ],
            ),
            VerticalDivider(
              width: 1,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: .35),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => context.go(destinations[value].path),
        destinations: [
          for (final item in destinations)
            NavigationDestination(icon: Icon(item.icon), label: item.label),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.path);
  final String label;
  final IconData icon;
  final String path;
}
