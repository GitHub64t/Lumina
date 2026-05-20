import '../repository/auth_repository.dart';

class ForgotPasswordUsecase {
  const ForgotPasswordUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) => _repository.forgotPassword(email);
}
