import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/login_model.dart';
import '../models/signup_model.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._client);

  final DioClient _client;

  Future<({UserModel user, TokenModel token})> login(LoginModel model) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: model.toJson(), // {credential, password}
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    return _authPayload(data);
  }

  Future<UserModel> signup(SignupModel model) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.signup,
      data: model.toJson(), // {firstName,lastName,email,phone,dateOfBirth,password}
    );
    // The signup endpoint returns: {"data":{"email":"…","attemptsRemaining":5}}
    // There is no user/token at this stage — OTP must be verified first.
    // We build a stub UserModel so the OTP page can display the email.
    final data = Map<String, dynamic>.from(response.data as Map);
    final payload = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : <String, dynamic>{};
    final email = payload['email']?.toString() ?? model.email;
    return UserModel.fromJson({
      '_id': '',
      'email': email,
      'firstName': model.firstName,
      'lastName': model.lastName,
    });
  }

  /// Verifies the signup OTP — POST /auth/signup/verify-otp {email, otp}
  /// Returns the raw response body (may contain tokens for immediate auth).
  Future<Object?> verifyOtp(String email, String code) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.verifyOtp,
      data: {'email': email, 'otp': code},
    );
    return response.data;
  }

  /// Resends the signup OTP — POST /auth/signup/resend-otp {email}
  Future<void> resendSignupOtp(String email) => _client.post(
    ApiConstants.resendOtp,
    data: {'email': email},
  );

  /// Sends forgot-password OTP — POST /auth/forgot-password {email}
  Future<void> forgotPassword(String email) =>
      _client.post(ApiConstants.forgotPassword, data: {'email': email});

  /// Resends forgot-password OTP — POST /auth/forgot-password/resend-otp {email}
  Future<void> resendForgotPasswordOtp(String email) => _client.post(
    ApiConstants.resendForgotPasswordOtp,
    data: {'email': email},
  );

  /// Resets password — POST /auth/reset-password {email, otp, newPassword}
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) => _client.post(
    ApiConstants.resetPassword,
    data: {'email': email, 'otp': otp, 'newPassword': newPassword},
  );

  Future<TokenModel> refreshToken(String refreshToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final tokenPayload = data['token'] is Map
        ? Map<String, dynamic>.from(data['token'] as Map)
        : data;
    return TokenModel.fromJson(tokenPayload);
  }

  /// Fetches the current user profile from GET /users/profile.
  Future<UserModel> me() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConstants.me);
    final data = Map<String, dynamic>.from(response.data as Map);
    final envelope = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
    final userPayload = envelope['user'] is Map
        ? Map<String, dynamic>.from(envelope['user'] as Map)
        : envelope;
    return UserModel.fromJson(userPayload);
  }

  Future<void> logout() => _client.post(ApiConstants.logout);

  ({UserModel user, TokenModel token}) _authPayload(Map<String, dynamic> data) {
    final envelope = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
    final tokenRaw = envelope['token'] ?? envelope['tokens'];
    return (
      user: UserModel.fromJson(
        Map<String, dynamic>.from(envelope['user'] as Map),
      ),
      token: TokenModel.fromJson(
        Map<String, dynamic>.from(tokenRaw as Map),
      ),
    );
  }
}
