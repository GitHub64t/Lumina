import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/article/presentation/pages/article_detail_page.dart';
import '../../features/article/presentation/pages/article_editor_page.dart';
import '../../features/article/presentation/pages/my_articles_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/password_pages.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/widgets/app_shell.dart';
import '../../features/preferences/presentation/pages/preferences_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'route_guards.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    redirect: (context, state) =>
        RouteGuards.authRedirect(_authBloc.state, state.uri.path),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/article/:id',
            builder: (context, state) =>
                ArticleDetailPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/articles/create',
            builder: (context, state) => const ArticleEditorPage(),
          ),
          GoRoute(
            path: '/articles/:id/edit',
            builder: (context, state) =>
                ArticleEditorPage(articleId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/my-articles',
            builder: (context, state) => const MyArticlesScreen(),
          ),
          GoRoute(
            path: '/preferences',
            builder: (context, state) => const PreferencesPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(state.error?.message ?? 'Route not found')),
    ),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
