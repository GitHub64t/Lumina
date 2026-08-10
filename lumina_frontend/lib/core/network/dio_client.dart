import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/session_controller.dart';
import '../auth/token_manager.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';
import 'dio_interceptor.dart';

class DioClient {
  DioClient(SecureStorageService storage, SessionController sessionController)
    : dio = Dio(_baseOptions()),
      _rawDio = Dio(_baseOptions()) {
    _tokenManager = TokenManager(
      storage: storage,
      refreshDio: _rawDio,
      sessionController: sessionController,
    );
    dio.interceptors.add(
      DioAuthInterceptor(tokenManager: _tokenManager, refreshDio: _rawDio),
    );
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  final Dio dio;
  final Dio _rawDio;
  late final TokenManager _tokenManager;

  static BaseOptions _baseOptions() => BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    responseType: ResponseType.json,
    contentType: Headers.jsonContentType,
    headers: const {'Accept': 'application/json'},
    validateStatus: (status) => status != null && status >= 200 && status < 300,
  );

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => dio.get<T>(
        path,
        queryParameters: _cleanMap(query),
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => dio.post<T>(
        path,
        data: data,
        queryParameters: _cleanMap(query),
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => dio.put<T>(
        path,
        data: data,
        queryParameters: _cleanMap(query),
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => dio.patch<T>(
        path,
        data: data,
        queryParameters: _cleanMap(query),
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => dio.delete<T>(
        path,
        data: data,
        queryParameters: _cleanMap(query),
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> multipart<T>(
    String path, {
    required Map<String, dynamic> fields,
    String method = 'POST',
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    final formData = FormData.fromMap(
      _cleanMap(fields) ?? const <String, dynamic>{},
    );
    return _guard(
      () => dio.request<T>(
        path,
        data: formData,
        queryParameters: _cleanMap(query),
        options: (options ?? Options()).copyWith(
          method: method,
          contentType: Headers.multipartFormDataContentType,
        ),
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      if (error.error is AppException) {
        throw error.error as AppException;
      }
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic>? _cleanMap(Map<String, dynamic>? value) {
    if (value == null) return null;
    return Map<String, dynamic>.from(value)
      ..removeWhere((_, item) => item == null);
  }
}
