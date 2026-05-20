import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  const ErrorHandler._();

  static Failure map(Object error) {
    if (error is UnauthorizedException) {
      return AuthFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }
    if (error is ValidationException) {
      return ValidationFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }
    if (error is NetworkException || error is TimeoutException) {
      final exception = error as AppException;
      return NetworkFailure(
        exception.message,
        code: exception.code,
        statusCode: exception.statusCode,
      );
    }
    if (error is ServerException) {
      return ServerFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }
    if (error is CacheException) {
      return CacheFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }
    return Failure(error.toString());
  }
}
