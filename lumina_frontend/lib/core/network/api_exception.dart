import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

class ApiException {
  const ApiException._();

  static AppException fromDio(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final payload = response?.data;
    final message = _messageFromPayload(payload) ?? _messageFromType(error);
    final code = _codeFromPayload(payload);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(message, statusCode: statusCode, code: code);
      case DioExceptionType.connectionError:
        return NetworkException(message, statusCode: statusCode, code: code);
      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          return UnauthorizedException(message);
        }
        if (statusCode == 422 || statusCode == 400) {
          return ValidationException(
            message,
            statusCode: statusCode,
            code: code,
            errors: _errorsFromPayload(payload),
          );
        }
        return ServerException(message, statusCode: statusCode, code: code);
      case DioExceptionType.cancel:
        return NetworkException(
          'Request was cancelled',
          statusCode: statusCode,
          code: code,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ServerException(message, statusCode: statusCode, code: code);
    }
  }

  static String? _messageFromPayload(Object? payload) {
    if (payload is Map) {
      final value = payload['message'] ?? payload['error'] ?? payload['detail'];
      if (value != null) return value.toString();
    }
    return null;
  }

  static String? _codeFromPayload(Object? payload) {
    if (payload is Map && payload['code'] != null) {
      return payload['code'].toString();
    }
    return null;
  }

  static Map<String, dynamic>? _errorsFromPayload(Object? payload) {
    if (payload is Map && payload['errors'] is Map) {
      return Map<String, dynamic>.from(payload['errors'] as Map);
    }
    return null;
  }

  static String _messageFromType(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out',
      DioExceptionType.sendTimeout => 'Request timed out',
      DioExceptionType.receiveTimeout => 'Response timed out',
      DioExceptionType.connectionError => 'No internet connection',
      DioExceptionType.badCertificate => 'Invalid server certificate',
      DioExceptionType.cancel => 'Request was cancelled',
      DioExceptionType.badResponse => 'Server error',
      DioExceptionType.unknown => error.message ?? 'Unexpected network error',
    };
  }
}
