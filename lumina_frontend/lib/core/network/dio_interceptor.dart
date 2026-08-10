import 'package:dio/dio.dart';

import '../auth/token_manager.dart';
import 'api_exception.dart';

class DioAuthInterceptor extends QueuedInterceptor {
  DioAuthInterceptor({
    required TokenManager tokenManager,
    required Dio refreshDio,
  }) : _tokenManager = tokenManager,
       _refreshDio = refreshDio;

  final TokenManager _tokenManager;
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
      final token = await _tokenManager.accessToken;
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
      final result = await _tokenManager.refreshAccessToken(
        failedAccessToken: _accessTokenFrom(err.requestOptions),
      );
      if (result.isRefreshed) {
        try {
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          handler.reject(retryError);
          return;
        }
      }
      if (result.status == TokenRefreshStatus.sessionExpired) {
        handler.reject(_wrap(err));
        return;
      }
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

    handler.reject(_wrap(err));
  }

  bool _shouldRefresh(DioException error) {
    final statusCode = error.response?.statusCode;
    final skipAuth = error.requestOptions.extra[_skipAuthKey] == true;
    final retryCount =
        (error.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    return statusCode == 401 && !skipAuth && retryCount == 0;
  }

  bool _shouldRetry(DioException error) {
    final retryCount =
        (error.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    final skipRetry = error.requestOptions.extra[_skipAuthKey] == true;
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

    return !skipRetry &&
        isIdempotent &&
        retryCount < _maxRetries &&
        (transientStatus || transientType);
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final retryCount = (requestOptions.extra[_retryCountKey] as int?) ?? 0;
    requestOptions.extra[_retryCountKey] = retryCount + 1;

    final accessToken = await _tokenManager.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      requestOptions.headers.remove('Authorization');
    }

    return _refreshDio.fetch<dynamic>(requestOptions);
  }

  String? _accessTokenFrom(RequestOptions options) {
    final header = options.headers['Authorization']?.toString();
    if (header == null || !header.startsWith('Bearer ')) return null;
    return header.substring(7);
  }

  DioException _wrap(DioException error) {
    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: ApiException.fromDio(error),
      message: error.message,
    );
  }
}
