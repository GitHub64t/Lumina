import '../repository/profile_repository.dart';

class ChangePasswordUsecase {
  const ChangePasswordUsecase(this._repository);

  final ProfileRepository _repository;

  /// ChangePasswordDto: userId, oldPassword, newPassword.
  Future<void> call({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      userId: userId,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
