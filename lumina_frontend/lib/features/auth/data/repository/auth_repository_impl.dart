import '../../domain/entities/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_local_datasource.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/login_model.dart';
import '../models/signup_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDatasource remote,
    required AuthLocalDatasource local,
  }) : _remote = remote,
       _local = local;

  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  @override
  Future<User> login(LoginModel model) async {
    final result = await _remote.login(model);
    await _local.saveTokens(
      result.token.accessToken,
      result.token.refreshToken,
    );
    return result.user;
  }

  @override
  Future<User> signup(SignupModel model) async {
    final userStub = await _remote.signup(model);
    // Signup only triggers OTP — no token yet.
    // Persist email so verifyOtp / resendOtp can use it without the user re-entering it.
    await _local.saveEmail(userStub.email);
    return userStub;
  }

  @override
  Future<void> refreshToken() async {
    final refreshToken = await _local.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return;
    final token = await _remote.refreshToken(refreshToken);
    await _local.saveTokens(
      token.accessToken,
      token.refreshToken ?? refreshToken,
    );
  }

  @override
  Future<void> verifyOtp(String code) async {
    final email = await _local.email ?? '';
    final response = await _remote.verifyOtp(email, code);
    // Extract and persist tokens from the verify-otp response.
    // The API may nest tokens under different keys — check all known shapes.
    bool tokenSaved = false;
    if (response != null && response is Map) {
      tokenSaved = await _extractAndSaveTokens(response);
      if (!tokenSaved) {
        final inner = response['data'];
        if (inner is Map) {
          tokenSaved = await _extractAndSaveTokens(inner);
        }
      }
    }
    // Debug: log outcome so we can trace token issues in logcat.
    assert(() {
      if (tokenSaved) {
        // ignore: avoid_print
        print('[Auth] ✅ Tokens saved after OTP verification');
      } else {
        // ignore: avoid_print
        print('[Auth] ⚠️  No tokens in verify-otp response — '
            'response was: $response');
      }
      return true;
    }());
  }

  /// Searches [map] for { accessToken, refreshToken } under common key names.
  /// Returns true if an access token was found and saved.
  Future<bool> _extractAndSaveTokens(Map<dynamic, dynamic> map) async {
    // Try: map['token'], map['tokens'], map['accessToken'] directly
    final candidates = [
      map['token'],
      map['tokens'],
      map['data'],
      map, // root-level accessToken
    ];
    for (final candidate in candidates) {
      if (candidate is! Map) continue;
      final access = candidate['accessToken']?.toString() ?? '';
      if (access.isEmpty) continue;
      final refresh = candidate['refreshToken']?.toString();
      await _local.saveTokens(access, refresh);
      return true;
    }
    return false;
  }

  @override
  Future<void> resendOtp(String email) => _remote.resendSignupOtp(email);

  @override
  Future<void> forgotPassword(String email) async {
    await _remote.forgotPassword(email);
    // Store email so resend & reset flows can use it.
    await _local.saveEmail(email);
  }

  @override
  Future<void> resendForgotPasswordOtp(String email) =>
      _remote.resendForgotPasswordOtp(email);

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) => _remote.resetPassword(email: email, otp: otp, newPassword: newPassword);

  @override
  Future<User?> restoreSession() async {
    try {
      final hasToken = await _local.hasToken();
      if (!hasToken) return null;
      return await _remote.me();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {
      // Local token cleanup must succeed even when the API is unavailable.
    } finally {
      await _local.clear();
    }
  }
}
