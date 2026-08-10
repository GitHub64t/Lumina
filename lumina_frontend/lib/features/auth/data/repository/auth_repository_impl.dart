import 'package:flutter/foundation.dart';

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

    // Persist tokens immediately so every subsequent request is authenticated.
    await _persistTokens(
      accessToken: result.token.accessToken,
      refreshToken: result.token.refreshToken,
      source: 'login',
    );

    return result.user;
  }

  @override
  Future<User> signup(SignupModel model) async {
    final userStub = await _remote.signup(model);
    // Signup triggers OTP — no token yet.
    // Persist email so verifyOtp / resendOtp don't need it re-entered.
    await _local.saveEmail(userStub.email);
    return userStub;
  }

  @override
  Future<void> refreshToken() async {
    final stored = await _local.refreshToken;
    if (stored == null || stored.isEmpty) return;
    final token = await _remote.refreshToken(stored);
    await _persistTokens(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken ?? stored,
      source: 'refreshToken',
    );
  }

  @override
  Future<void> verifyOtp(String code) async {
    final email = await _local.email ?? '';
    final response = await _remote.verifyOtp(email, code);

    // Try to extract and save tokens from the verify-otp response.
    // Some backends return tokens here; others require a subsequent login.
    final saved = await _saveTokensFromMap(response, source: 'verifyOtp');
    if (!saved) {
      // Also try one level deeper.
      final inner = response['data'];
      if (inner is Map) {
        await _saveTokensFromMap(
          Map<String, dynamic>.from(inner),
          source: 'verifyOtp.data',
        );
      }
    }
  }

  @override
  Future<void> resendOtp(String email) => _remote.resendSignupOtp(email);

  @override
  Future<void> forgotPassword(String email) async {
    await _remote.forgotPassword(email);
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
      // Local cleanup must succeed even when the API is unavailable.
    } finally {
      await _local.clear();
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Saves tokens to secure storage and logs the outcome in debug mode.
  Future<void> _persistTokens({
    required String accessToken,
    String? refreshToken,
    required String source,
  }) async {
    if (accessToken.isEmpty) {
      if (kDebugMode) {
        debugPrint('[Auth] ⚠️  _persistTokens[$source]: '
            'accessToken is empty — NOT saving');
      }
      return;
    }
    await _local.saveTokens(accessToken, refreshToken);
    if (kDebugMode) {
      debugPrint('[Auth] ✅ _persistTokens[$source]: '
          'accessToken saved (${accessToken.substring(0, accessToken.length.clamp(0, 20))}…)');
    }
  }

  /// Searches [map] for an access token and persists it.
  /// Returns true if a non-empty token was found and saved.
  Future<bool> _saveTokensFromMap(
    Map<String, dynamic> map, {
    required String source,
  }) async {
    // Check all common nesting locations.
    final candidates = <Map<dynamic, dynamic>>[
      if (map['token'] is Map) map['token'] as Map,
      if (map['tokens'] is Map) map['tokens'] as Map,
      map, // accessToken directly in map
    ];

    for (final candidate in candidates) {
      final access = candidate['accessToken']?.toString() ??
          candidate['access_token']?.toString() ??
          '';
      if (access.isEmpty) continue;

      final refresh = candidate['refreshToken']?.toString() ??
          candidate['refresh_token']?.toString();

      await _persistTokens(
        accessToken: access,
        refreshToken: refresh,
        source: source,
      );
      return true;
    }

    if (kDebugMode) {
      debugPrint('[Auth] ⚠️  _saveTokensFromMap[$source]: '
          'no token found. Map keys: ${map.keys.toList()}');
    }
    return false;
  }
}
