import '../repository/auth_repository.dart';

class ResendForgotPasswordOtpUsecase {
  const ResendForgotPasswordOtpUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) =>
      _repository.resendForgotPasswordOtp(email);
}
