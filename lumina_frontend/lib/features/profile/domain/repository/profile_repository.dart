import '../../data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();

  /// UpdateProfileDto fields: userId, firstName, lastName, dateOfBirth.
  Future<ProfileModel> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    String? dateOfBirth,
  });

  /// ChangePasswordDto fields: userId, oldPassword, newPassword.
  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  });
}
