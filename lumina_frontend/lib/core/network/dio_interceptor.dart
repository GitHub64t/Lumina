import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class DioAuthInterceptor extends QueuedInterceptor {
  DioAuthInterceptor({
    required SecureStorageService storage,
    required Dio refreshDio,
  }) : _storage = storage,
       _refreshDio = refreshDio;

  final SecureStorageService _storage;
  final Dio _refreshDio;

  static const _skipAuthKey = 'skipAuth';
  static const _retryCountKey = 'retryCount';
  static const _maxRetries = 2;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.putIfAbsent('Accept', () => 'application/json');

    final skipAuth = options.extra[_skipAuthKey] == true;
    if (!skipAuth) {
      final token = await _storage.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRefresh(err)) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        try {
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          handler.reject(retryError);
          return;
        }
      }
      await _storage.clearTokens();
    }

    if (_shouldRetry(err)) {
      try {
        final response = await _retry(err.requestOptions);
        handler.resolve(response);
        return;
      } on DioException catch (retryError) {
        handler.reject(retryError);
        return;
      }
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ApiException.fromDio(err),
        message: err.message,
      ),
    );
  }

  bool _shouldRefresh(DioException error) {
    final statusCode = error.response?.statusCode;
    final isRefreshCall =
        error.requestOptions.path == ApiConstants.refreshToken;
    final skipAuth = error.requestOptions.extra[_skipAuthKey] == true;
    return statusCode == 401 && !isRefreshCall && !skipAuth;
  }

  bool _shouldRetry(DioException error) {
    final retryCount =
        (error.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    final isIdempotent = {
      'GET',
      'HEAD',
    }.contains(error.requestOptions.method.toUpperCase());
    final transientStatus =
        error.response?.statusCode == 408 ||
        error.response?.statusCode == 429 ||
        ((error.response?.statusCode ?? 0) >= 500);
    final transientType =
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;

    return isIdempotent &&
        retryCount < _maxRetries &&
        (transientStatus || transientType);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _storage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(extra: {_skipAuthKey: true}),
      );
      final data = response.data ?? const <String, dynamic>{};
      final tokenPayload = data['token'] is Map
          ? Map<String, dynamic>.from(data['token'] as Map)
          : data;
      final accessToken = tokenPayload['accessToken']?.toString();
      final nextRefreshToken = tokenPayload['refreshToken']?.toString();

      if (accessToken == null || accessToken.isEmpty) return false;
      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: nextRefreshToken ?? refreshToken,
      );
      return true;
    } on DioException {
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final retryCount = (requestOptions.extra[_retryCountKey] as int?) ?? 0;
    requestOptions.extra[_retryCountKey] = retryCount + 1;

    final accessToken = await _storage.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    }

    await Future<void>.delayed(Duration(milliseconds: 250 * (retryCount + 1)));

    return _refreshDio.fetch<dynamic>(requestOptions);
  }
}
