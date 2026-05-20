import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  const Failure(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  List<Object?> get props => [message, code, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.statusCode});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.statusCode});
}
