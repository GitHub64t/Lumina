import '../../features/auth/presentation/bloc/auth_bloc.dart';

class RouteGuards {
  const RouteGuards._();

  static bool isPublic(String location) {
    return location == '/' ||
        location == '/onboarding' ||
        location == '/login' ||
        location == '/signup' ||
        location == '/otp' ||
        location == '/forgot-password' ||
        location == '/reset-password';
  }

  static String? authRedirect(AuthState auth, String location) {
    if (auth.status == AuthStatus.checking) {
      return null;
    }
    if (auth.status == AuthStatus.pendingOtp && location != '/otp') {
      return '/otp';
    }
    if (!auth.isAuthenticated && !isPublic(location)) {
      return '/login';
    }
    if (auth.isAuthenticated && isPublic(location)) {
      return '/dashboard';
    }
    return null;
  }
}
