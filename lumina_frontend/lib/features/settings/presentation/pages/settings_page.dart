import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/responsive_page.dart';
import 'theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsivePage(
        child: ListView(
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_rounded),
                    title: const Text('Edit profile'),
                    onTap: () => context.go('/profile'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_rounded),
                    title: const Text('Change password'),
                    onTap: () => context.go('/profile'),
                  ),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, mode) => SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_rounded),
                      title: const Text('Dark mode'),
                      value: mode == ThemeMode.dark,
                      onChanged: (value) => context.read<ThemeCubit>().setTheme(
                        value ? ThemeMode.dark : ThemeMode.light,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.tune_rounded),
                    title: const Text('Preferences management'),
                    onTap: () => context.go('/preferences'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded),
                    title: const Text('Logout'),
                    onTap: () => context.read<AuthBloc>().add(
                      const AuthLogoutRequested(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
