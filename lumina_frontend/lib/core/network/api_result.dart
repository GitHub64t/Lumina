import '../errors/failures.dart';
import '../errors/error_handler.dart';

sealed class ApiResult<T> {
  const ApiResult();

  static Future<ApiResult<T>> guard<T>(Future<T> Function() request) async {
    try {
      return ApiSuccess<T>(await request());
    } catch (error) {
      return ApiFailure<T>(ErrorHandler.map(error));
    }
  }

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      ApiSuccess<T>(:final data) => success(data),
      ApiFailure<T>(failure: final value) => failure(value),
    };
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.failure);
  final Failure failure;
}
