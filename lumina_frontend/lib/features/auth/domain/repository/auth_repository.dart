import '../../data/models/login_model.dart';
import '../../data/models/signup_model.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(LoginModel model);
  Future<User> signup(SignupModel model);
  Future<void> refreshToken();
  Future<void> verifyOtp(String code);
  Future<void> resendOtp(String email);
  Future<void> forgotPassword(String email);
  Future<void> resendForgotPasswordOtp(String email);
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<User?> restoreSession();
  Future<void> logout();
}
