import '../repository/auth_repository.dart';

class VerifyOtpUsecase {
  const VerifyOtpUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String code) => _repository.verifyOtp(code);
}
