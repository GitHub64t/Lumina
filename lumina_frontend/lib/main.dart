import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/constants/app_strings.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/presentation/bloc/feed_bloc.dart';
import 'features/settings/presentation/pages/theme_cubit.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await sl.init();
  runApp(ArticleFeedApp(router: AppRouter(sl.authBloc)));
}

class ArticleFeedApp extends StatelessWidget {
  const ArticleFeedApp({required this.router, super.key});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: sl.authBloc),
        BlocProvider<FeedBloc>.value(value: sl.feedBloc),
        BlocProvider<ThemeCubit>.value(value: sl.themeCubit),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == AuthStatus.unauthenticated,
        listener: (context, state) => router.router.go('/login'),
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) => MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode,
            routerConfig: router.router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: FlutterQuillLocalizations.supportedLocales,
          ),
        ),
      ),
    );
  }
}
