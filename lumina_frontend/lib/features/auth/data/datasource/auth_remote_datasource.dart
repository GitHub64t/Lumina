import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response_parser.dart';
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
      data: model.toJson(),
      options: _skipAuthOptions,
    );
    final raw = ApiResponseParser.map(response.data);
    return _parseAuthResponse(raw);
  }

  Future<UserModel> signup(SignupModel model) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.signup,
      data: model.toJson(),
      options: _skipAuthOptions,
    );
    // Signup only returns { data: { email, attemptsRemaining } } — no token.
    // Build a stub UserModel from what we have.
    final inner = ApiResponseParser.map(response.data);
    final email = inner['email']?.toString() ?? model.email;
    return UserModel.fromJson({
      '_id': '',
      'email': email,
      'firstName': model.firstName,
      'lastName': model.lastName,
    });
  }

  /// POST /auth/signup/verify-otp {email, otp}
  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.verifyOtp,
      data: {'email': email, 'otp': code},
      options: _skipAuthOptions,
    );
    return response.data == null
        ? <String, dynamic>{}
        : ApiResponseParser.map(response.data);
  }

  /// POST /auth/signup/resend-otp {email}
  Future<void> resendSignupOtp(String email) => _client.post(
    ApiConstants.resendOtp,
    data: {'email': email},
    options: _skipAuthOptions,
  );

  /// POST /auth/forgot-password {email}
  Future<void> forgotPassword(String email) => _client.post(
    ApiConstants.forgotPassword,
    data: {'email': email},
    options: _skipAuthOptions,
  );

  /// POST /auth/forgot-password/resend-otp {email}
  Future<void> resendForgotPasswordOtp(String email) => _client.post(
    ApiConstants.resendForgotPasswordOtp,
    data: {'email': email},
    options: _skipAuthOptions,
  );

  /// POST /auth/reset-password {email, otp, newPassword}
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) => _client.post(
    ApiConstants.resetPassword,
    data: {'email': email, 'otp': otp, 'newPassword': newPassword},
    options: _skipAuthOptions,
  );

  /// POST /auth/refresh-token {refreshToken}
  Future<TokenModel> refreshToken(String token) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.refreshToken,
      data: {'refreshToken': token},
      options: _skipAuthOptions,
    );
    final raw = response.data == null
        ? <String, dynamic>{}
        : ApiResponseParser.map(response.data);
    return TokenModel.fromJson(_extractTokenMap(raw));
  }

  /// GET /users/profile
  Future<UserModel> me() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConstants.me);
    final envelope = response.data == null
        ? <String, dynamic>{}
        : ApiResponseParser.map(response.data);

    if (kDebugMode) {
      debugPrint('[Auth] me() envelope keys: ${envelope.keys.toList()}');
    }

    return UserModel.fromJson(_extractUserMap(envelope));
  }

  Future<void> logout() => _client.post(ApiConstants.logout);

  static Options get _skipAuthOptions =>
      Options(extra: const {'skipAuth': true});

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Parses a login/verify-otp response that contains both user and token.
  ({UserModel user, TokenModel token}) _parseAuthResponse(
    Map<String, dynamic> raw,
  ) {
    // Unwrap one level if present.
    final Map<String, dynamic> envelope = raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : raw;

    final userMap = _extractUserMap(envelope);
    final tokenMap = _extractTokenMap(envelope);

    // Debug log — remove before release or keep behind assert.
    if (kDebugMode) {
      debugPrint(
        '[Auth] ── login response envelope keys: '
        '${envelope.keys.toList()}',
      );
      debugPrint('[Auth] userMap  → ${userMap.keys.toList()}');
      debugPrint('[Auth] tokenMap → $tokenMap');
    }

    return (
      user: UserModel.fromJson(userMap),
      token: TokenModel.fromJson(tokenMap),
    );
  }

  /// Finds the user object inside [map].
  /// Checks: map['user'], map['profile'], map itself (as fallback).
  Map<String, dynamic> _extractUserMap(Map<String, dynamic> map) {
    for (final key in ['user', 'profile']) {
      if (map[key] is Map) {
        return Map<String, dynamic>.from(map[key] as Map);
      }
    }
    // If neither key exists, the map itself may be the user object.
    return map;
  }

  /// Finds the token data inside [map].
  ///
  /// Handles every common shape:
  ///   • map['token']       = { accessToken, refreshToken }
  ///   • map['tokens']      = { accessToken, refreshToken }
  ///   • map['accessToken'] directly at map level        (most common!)
  ///   • map['data']        = { accessToken, refreshToken }
  Map<String, dynamic> _extractTokenMap(Map<String, dynamic> map) {
    // Priority 1: nested token objects
    for (final key in ['token', 'tokens']) {
      if (map[key] is Map) {
        return Map<String, dynamic>.from(map[key] as Map);
      }
    }

    // Priority 2: accessToken directly in map (e.g. data.accessToken)
    if (map['accessToken'] != null || map['access_token'] != null) {
      return map;
    }

    // Priority 3: one more level under 'data'
    if (map['data'] is Map) {
      final inner = Map<String, dynamic>.from(map['data'] as Map);
      for (final key in ['token', 'tokens']) {
        if (inner[key] is Map) {
          return Map<String, dynamic>.from(inner[key] as Map);
        }
      }
      if (inner['accessToken'] != null || inner['access_token'] != null) {
        return inner;
      }
    }

    // Not found — return empty map; TokenModel will produce empty accessToken.
    if (kDebugMode) {
      debugPrint(
        '[Auth] ⚠️  _extractTokenMap: no token found in map keys '
        '${map.keys.toList()}',
      );
    }
    return <String, dynamic>{};
  }
}
