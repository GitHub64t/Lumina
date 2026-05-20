abstract class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.code});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode, super.code});
}

class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.statusCode, super.code});
}

class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.statusCode,
    super.code,
    this.errors,
  });

  final Map<String, dynamic>? errors;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired'])
    : super(statusCode: 401, code: 'unauthorized');
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}
