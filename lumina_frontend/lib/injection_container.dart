import 'package:get_it/get_it.dart';

import 'core/auth/session_controller.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/article/data/datasource/article_remote_datasource.dart';
import 'features/article/data/repository/article_repository_impl.dart';
import 'features/article/domain/repository/article_repository.dart';
import 'features/article/domain/usecases/create_article_usecase.dart';
import 'features/article/domain/usecases/delete_article_usecase.dart';
import 'features/article/domain/usecases/edit_article_usecase.dart';
import 'features/article/domain/usecases/get_articles_usecase.dart';
import 'features/article/domain/usecases/get_my_articles_usecase.dart';
import 'features/article/presentation/bloc/my_articles_cubit.dart';
import 'features/auth/data/datasource/auth_local_datasource.dart';
import 'features/auth/data/datasource/auth_remote_datasource.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/refresh_token_usecase.dart';
import 'features/auth/domain/usecases/resend_forgot_password_otp_usecase.dart';
import 'features/auth/domain/usecases/resend_otp_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/domain/usecases/restore_session_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/auth/domain/usecases/verify_otp_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/presentation/bloc/feed_bloc.dart';
import 'features/preferences/data/datasource/preferences_remote_datasource.dart';
import 'features/preferences/data/repository/preferences_repository_impl.dart';
import 'features/preferences/domain/repository/preferences_repository.dart';
import 'features/preferences/domain/usecases/fetch_categories_usecase.dart';
import 'features/preferences/domain/usecases/get_preferences_usecase.dart';
import 'features/preferences/domain/usecases/save_preferences_usecase.dart';
import 'features/profile/data/datasource/profile_remote_datasource.dart';
import 'features/profile/data/repository/profile_repository_impl.dart';
import 'features/profile/domain/repository/profile_repository.dart';
import 'features/profile/domain/usecases/change_password_usecase.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_cubit.dart';
import 'features/reactions/data/datasource/reactions_remote_datasource.dart';
import 'features/reactions/data/repository/reactions_repository_impl.dart';
import 'features/reactions/domain/repository/reactions_repository.dart';
import 'features/reactions/domain/usecases/block_article_usecase.dart';
import 'features/reactions/domain/usecases/react_article_usecase.dart';
import 'features/settings/presentation/pages/theme_cubit.dart';

final sl = InjectionContainer(GetIt.instance);

class InjectionContainer {
  InjectionContainer(this._getIt);

  final GetIt _getIt;

  SecureStorageService get storage => _getIt<SecureStorageService>();
  SessionController get sessionController => _getIt<SessionController>();
  DioClient get dioClient => _getIt<DioClient>();
  AuthRepository get authRepository => _getIt<AuthRepository>();
  ArticleRepository get articleRepository => _getIt<ArticleRepository>();
  ProfileRepository get profileRepository => _getIt<ProfileRepository>();
  PreferencesRepository get preferencesRepository =>
      _getIt<PreferencesRepository>();
  ReactionsRepository get reactionsRepository => _getIt<ReactionsRepository>();
  AuthBloc get authBloc => _getIt<AuthBloc>();
  FeedBloc get feedBloc => _getIt<FeedBloc>();
  MyArticlesCubit get myArticlesCubit => _getIt<MyArticlesCubit>();
  ThemeCubit get themeCubit => _getIt<ThemeCubit>();

  T call<T extends Object>() => _getIt<T>();

  Future<void> init() async {
    if (_getIt.isRegistered<SecureStorageService>()) return;

    _getIt.registerLazySingleton<SecureStorageService>(
      SecureStorageService.new,
    );
    _getIt.registerLazySingleton<SessionController>(SessionController.new);
    _getIt.registerLazySingleton<DioClient>(
      () => DioClient(_getIt(), _getIt()),
    );

    // ── Data sources ──────────────────────────────────────────────────────────
    _getIt.registerLazySingleton<AuthLocalDatasource>(
      () => AuthLocalDatasource(_getIt()),
    );
    _getIt.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasource(_getIt()),
    );
    _getIt.registerLazySingleton<ArticleRemoteDatasource>(
      () => ArticleRemoteDatasource(_getIt()),
    );
    _getIt.registerLazySingleton<ProfileRemoteDatasource>(
      () => ProfileRemoteDatasource(_getIt()),
    );
    _getIt.registerLazySingleton<PreferencesRemoteDatasource>(
      () => PreferencesRemoteDatasource(_getIt()),
    );
    _getIt.registerLazySingleton<ReactionsRemoteDatasource>(
      () => ReactionsRemoteDatasource(_getIt()),
    );

    // ── Repositories ──────────────────────────────────────────────────────────
    _getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remote: _getIt(), local: _getIt()),
    );
    _getIt.registerLazySingleton<ArticleRepository>(
      () => ArticleRepositoryImpl(remote: _getIt()),
    );
    _getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remote: _getIt()),
    );
    _getIt.registerLazySingleton<PreferencesRepository>(
      () => PreferencesRepositoryImpl(remote: _getIt()),
    );
    _getIt.registerLazySingleton<ReactionsRepository>(
      () => ReactionsRepositoryImpl(_getIt()),
    );

    // ── Auth use cases ────────────────────────────────────────────────────────
    _getIt.registerLazySingleton<LoginUsecase>(() => LoginUsecase(_getIt()));
    _getIt.registerLazySingleton<SignupUsecase>(() => SignupUsecase(_getIt()));
    _getIt.registerLazySingleton<VerifyOtpUsecase>(
      () => VerifyOtpUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<ResendOtpUsecase>(
      () => ResendOtpUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<ForgotPasswordUsecase>(
      () => ForgotPasswordUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<ResetPasswordUsecase>(
      () => ResetPasswordUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<ResendForgotPasswordOtpUsecase>(
      () => ResendForgotPasswordOtpUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<RestoreSessionUsecase>(
      () => RestoreSessionUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<RefreshTokenUsecase>(
      () => RefreshTokenUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<LogoutUsecase>(() => LogoutUsecase(_getIt()));

    // ── Article use cases ─────────────────────────────────────────────────────
    _getIt.registerLazySingleton<GetArticlesUsecase>(
      () => GetArticlesUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<GetMyArticlesUsecase>(
      () => GetMyArticlesUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<CreateArticleUsecase>(
      () => CreateArticleUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<EditArticleUsecase>(
      () => EditArticleUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<DeleteArticleUsecase>(
      () => DeleteArticleUsecase(_getIt()),
    );

    // ── Profile use cases ─────────────────────────────────────────────────────
    _getIt.registerLazySingleton<GetProfileUsecase>(
      () => GetProfileUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<UpdateProfileUsecase>(
      () => UpdateProfileUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<ChangePasswordUsecase>(
      () => ChangePasswordUsecase(_getIt()),
    );

    // ── Preferences use cases ─────────────────────────────────────────────────
    _getIt.registerLazySingleton<FetchCategoriesUsecase>(
      () => FetchCategoriesUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<GetPreferencesUsecase>(
      () => GetPreferencesUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<SavePreferencesUsecase>(
      () => SavePreferencesUsecase(_getIt()),
    );

    // ── Reactions use cases ───────────────────────────────────────────────────
    _getIt.registerLazySingleton<ReactArticleUsecase>(
      () => ReactArticleUsecase(_getIt()),
    );
    _getIt.registerLazySingleton<BlockArticleUsecase>(
      () => BlockArticleUsecase(_getIt()),
    );

    // ── Blocs & cubits ────────────────────────────────────────────────────────
    _getIt.registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        loginUsecase: _getIt(),
        signupUsecase: _getIt(),
        verifyOtpUsecase: _getIt(),
        resendOtpUsecase: _getIt(),
        forgotPasswordUsecase: _getIt(),
        resetPasswordUsecase: _getIt(),
        restoreSessionUsecase: _getIt(),
        logoutUsecase: _getIt(),
        sessionController: _getIt(),
        resendForgotPasswordOtpUsecase: _getIt(),
      )..add(const AuthStarted()),
    );
    _getIt.registerLazySingleton<FeedBloc>(
      () => FeedBloc(
        _getIt(),
        reactArticleUsecase: _getIt(),
        blockArticleUsecase: _getIt(),
      ),
    );
    _getIt.registerFactory<MyArticlesCubit>(
      () => MyArticlesCubit(
        _getIt(),
        reactArticleUsecase: _getIt(),
        blockArticleUsecase: _getIt(),
      ),
    );
    _getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit(_getIt()));
    _getIt.registerFactory<ProfileCubit>(
      () => ProfileCubit(
        getProfileUsecase: _getIt(),
        updateProfileUsecase: _getIt(),
        changePasswordUsecase: _getIt(),
      ),
    );
  }
}
