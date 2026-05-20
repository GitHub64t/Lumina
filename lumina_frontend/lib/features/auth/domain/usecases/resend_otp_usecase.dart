import '../repository/auth_repository.dart';

class ResendOtpUsecase {
  const ResendOtpUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) => _repository.resendOtp(email);
}
