part of 'auth_bloc.dart';

enum AuthStatus {
  checking,
  unauthenticated,
  loading,
  pendingOtp,
  passwordResetSent,
  passwordResetOtpResent,
  passwordResetSuccess,
  otpResent,
  authenticated,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.error,
    this.pendingResetEmail,
  });

  final AuthStatus status;
  final User? user;
  final String? error;
  /// Holds the email during the forgot-password → OTP → reset flow.
  final String? pendingResetEmail;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading =>
      status == AuthStatus.loading || status == AuthStatus.checking;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool clearError = false,
    String? pendingResetEmail,
    bool clearPendingResetEmail = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : error ?? this.error,
      pendingResetEmail: clearPendingResetEmail
          ? null
          : pendingResetEmail ?? this.pendingResetEmail,
    );
  }

  @override
  List<Object?> get props => [status, user, error, pendingResetEmail];
}
