part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.credential, required this.password});

  /// Can be email or phone number (matches LoginDto.credential).
  final String credential;
  final String password;

  @override
  List<Object?> get props => [credential, password];
}

class AuthSignupRequested extends AuthEvent {
  const AuthSignupRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String password;

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    dateOfBirth,
    password,
  ];
}

class AuthOtpVerified extends AuthEvent {
  const AuthOtpVerified(this.code);
  final String code;

  @override
  List<Object?> get props => [code];
}

class AuthOtpResent extends AuthEvent {
  const AuthOtpResent();
}

class AuthForgotPasswordRequested extends AuthEvent {
  const AuthForgotPasswordRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Resends the forgot-password OTP.
class AuthForgotPasswordOtpResent extends AuthEvent {
  const AuthForgotPasswordOtpResent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  const AuthResetPasswordRequested({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  final String email;
  final String otp;
  final String newPassword;

  @override
  List<Object?> get props => [email, otp, newPassword];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
