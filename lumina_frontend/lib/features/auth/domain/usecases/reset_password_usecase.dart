import '../repository/auth_repository.dart';

class ResetPasswordUsecase {
  const ResetPasswordUsecase(this._repository);

  final AuthRepository _repository;

  /// [email] + [otp] + [newPassword] as required by ResetPasswordDto.
  Future<void> call({
    required String email,
    required String otp,
    required String newPassword,
  }) => _repository.resetPassword(email: email, otp: otp, newPassword: newPassword);
}
