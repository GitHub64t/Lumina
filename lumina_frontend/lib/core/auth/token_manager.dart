import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'session_controller.dart';

enum TokenRefreshStatus { refreshed, sessionExpired, failed }

class TokenRefreshResult {
  const TokenRefreshResult(this.status, {this.error});

  final TokenRefreshStatus status;
  final Object? error;

  bool get isRefreshed => status == TokenRefreshStatus.refreshed;
}

class TokenManager {
  TokenManager({
    required SecureStorageService storage,
    required Dio refreshDio,
    required SessionController sessionController,
  }) : _storage = storage,
       _refreshDio = refreshDio,
       _sessionController = sessionController;

  final SecureStorageService _storage;
  final Dio _refreshDio;
  final SessionController _sessionController;

  Future<TokenRefreshResult>? _refreshInFlight;

  Future<String?> get accessToken => _storage.accessToken;
  Future<String?> get refreshToken => _storage.refreshToken;

  Future<void> saveTokens({required String accessToken, String? refreshToken}) {
    return _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> clearSession() => _storage.clearAll();

  Future<TokenRefreshResult> refreshAccessToken({String? failedAccessToken}) {
    final activeRefresh = _refreshInFlight;
    if (activeRefresh != null) return activeRefresh;

    final refresh = _refreshAccessToken(failedAccessToken: failedAccessToken);
    _refreshInFlight = refresh;
    return refresh.whenComplete(() => _refreshInFlight = null);
  }

  Future<TokenRefreshResult> _refreshAccessToken({
    String? failedAccessToken,
  }) async {
    final currentAccessToken = await _storage.accessToken;
    if (failedAccessToken != null &&
        currentAccessToken != null &&
        currentAccessToken.isNotEmpty &&
        currentAccessToken != failedAccessToken) {
      return const TokenRefreshResult(TokenRefreshStatus.refreshed);
    }

    final storedRefreshToken = await _storage.refreshToken;
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      await _expireSession(SessionExpiredReason.missingRefreshToken);
      return const TokenRefreshResult(TokenRefreshStatus.sessionExpired);
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        data: {'refreshToken': storedRefreshToken},
        options: Options(extra: const {'skipAuth': true}),
      );

      final payload = _extractTokenPayload(response.data);
      final accessToken =
          payload['accessToken']?.toString() ??
          payload['access_token']?.toString() ??
          '';
      final nextRefreshToken =
          payload['refreshToken']?.toString() ??
          payload['refresh_token']?.toString() ??
          storedRefreshToken;

      if (accessToken.isEmpty) {
        await _expireSession(SessionExpiredReason.invalidRefreshResponse);
        return const TokenRefreshResult(TokenRefreshStatus.sessionExpired);
      }

      await saveTokens(
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
      );
      return const TokenRefreshResult(TokenRefreshStatus.refreshed);
    } on DioException catch (error) {
      if (_isRefreshTokenRejected(error)) {
        await _expireSession(SessionExpiredReason.rejectedRefreshToken);
        return TokenRefreshResult(
          TokenRefreshStatus.sessionExpired,
          error: error,
        );
      }
      return TokenRefreshResult(TokenRefreshStatus.failed, error: error);
    } catch (error) {
      return TokenRefreshResult(TokenRefreshStatus.failed, error: error);
    }
  }

  Map<String, dynamic> _extractTokenPayload(Object? data) {
    if (data is! Map) return const <String, dynamic>{};
    final map = Map<String, dynamic>.from(data);

    for (final key in const ['data', 'result', 'payload']) {
      final nested = map[key];
      if (nested is Map) {
        return _extractTokenPayload(nested);
      }
    }

    for (final key in const ['token', 'tokens']) {
      final token = map[key];
      if (token is Map) {
        return Map<String, dynamic>.from(token);
      }
    }

    return map;
  }

  bool _isRefreshTokenRejected(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 400 || statusCode == 401 || statusCode == 403;
  }

  Future<void> _expireSession(SessionExpiredReason reason) async {
    await clearSession();
    _sessionController.notifySessionExpired(reason);
  }
}
