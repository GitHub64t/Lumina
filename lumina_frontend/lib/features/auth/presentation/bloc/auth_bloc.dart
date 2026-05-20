import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/login_model.dart';
import '../../data/models/signup_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/resend_forgot_password_otp_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUsecase loginUsecase,
    required SignupUsecase signupUsecase,
    required VerifyOtpUsecase verifyOtpUsecase,
    required ResendOtpUsecase resendOtpUsecase,
    required ForgotPasswordUsecase forgotPasswordUsecase,
    required ResendForgotPasswordOtpUsecase resendForgotPasswordOtpUsecase,
    required ResetPasswordUsecase resetPasswordUsecase,
    required RestoreSessionUsecase restoreSessionUsecase,
    required LogoutUsecase logoutUsecase,
  }) : _loginUsecase = loginUsecase,
       _signupUsecase = signupUsecase,
       _verifyOtpUsecase = verifyOtpUsecase,
       _resendOtpUsecase = resendOtpUsecase,
       _forgotPasswordUsecase = forgotPasswordUsecase,
       _resendForgotPasswordOtpUsecase = resendForgotPasswordOtpUsecase,
       _resetPasswordUsecase = resetPasswordUsecase,
       _restoreSessionUsecase = restoreSessionUsecase,
       _logoutUsecase = logoutUsecase,
       super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthOtpVerified>(_onOtp);
    on<AuthOtpResent>(_onResendOtp);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthForgotPasswordOtpResent>(_onResendForgotPasswordOtp);
    on<AuthResetPasswordRequested>(_onResetPassword);
    on<AuthLogoutRequested>(_onLogout);
  }

  final LoginUsecase _loginUsecase;
  final SignupUsecase _signupUsecase;
  final VerifyOtpUsecase _verifyOtpUsecase;
  final ResendOtpUsecase _resendOtpUsecase;
  final ForgotPasswordUsecase _forgotPasswordUsecase;
  final ResendForgotPasswordOtpUsecase _resendForgotPasswordOtpUsecase;
  final ResetPasswordUsecase _resetPasswordUsecase;
  final RestoreSessionUsecase _restoreSessionUsecase;
  final LogoutUsecase _logoutUsecase;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.checking));
    try {
      final user = await _restoreSessionUsecase();
      emit(
        state.copyWith(
          status: user == null
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
          user: user,
          clearError: true,
        ),
      );
    } catch (_) {
      await _logoutUsecase();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _loginUsecase(
        LoginModel(credential: event.credential, password: event.password),
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (error) {
      emit(state.copyWith(status: AuthStatus.failure, error: error.toString()));
    }
  }

  Future<void> _onSignup(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _signupUsecase(
        SignupModel(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          phone: event.phone,
          dateOfBirth: event.dateOfBirth,
          password: event.password,
        ),
      );
      emit(state.copyWith(status: AuthStatus.pendingOtp, user: user));
    } catch (error) {
      emit(state.copyWith(status: AuthStatus.failure, error: error.toString()));
    }
  }

  Future<void> _onOtp(AuthOtpVerified event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _verifyOtpUsecase(event.code);
      // verifyOtp may have saved tokens from the response.
      // restoreSession reads the saved access token and fetches the full profile.
      final user = await _restoreSessionUsecase();
      if (user != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        // Tokens were not in the OTP response (some backends return them
        // only on first login). Keep the stub user from signup and mark
        // authenticated — the user is verified at this point.
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: state.user, // stub UserModel from signup
          ),
        );
      }
    } catch (error) {
      emit(state.copyWith(status: AuthStatus.failure, error: error.toString()));
    }
  }

  Future<void> _onResendOtp(
    AuthOtpResent event,
    Emitter<AuthState> emit,
  ) async {
    final email = state.user?.email;
    if (email == null || email.isEmpty) return;
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _resendOtpUsecase(email);
      emit(state.copyWith(status: AuthStatus.otpResent));
    } catch (error) {
      emit(state.copyWith(status: AuthStatus.failure, error: error.toString()));
    }
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _forgotPasswordUsecase(event.email);
      emit(
        state.copyWith(
          status: AuthStatus.passwordResetSent,
          pendingResetEmail: event.email,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: AuthStatus.failure, error: error.toString()));
    }
  }

  Future<void> _onResendForgotPasswordOtp(
    AuthForgotPasswordOtpResent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _resendForgotPasswordOtpUsecase(event.email);
      emit(state.copyWith(status: AuthStatus.passwordResetOtpResent));
    } catch (error) {
      emit(state.copyWith(status: AuthStatus.failure, error: error.toString()));
    }
  }

  Future<void> _onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _resetPasswordUsecase(
        email: event.email,
        otp: event.otp,
        newPassword: event.newPassword,
      );
      emit(
        state.copyWith(
          status: AuthStatus.passwordResetSuccess,
          clearPendingResetEmail: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: AuthStatus.failure, error: error.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUsecase();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
