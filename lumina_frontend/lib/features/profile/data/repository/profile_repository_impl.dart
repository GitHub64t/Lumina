import '../../domain/repository/profile_repository.dart';
import '../datasource/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required ProfileRemoteDatasource remote})
    : _remote = remote;

  final ProfileRemoteDatasource _remote;

  @override
  Future<ProfileModel> getProfile() => _remote.getProfile();

  @override
  Future<ProfileModel> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    String? dateOfBirth,
  }) {
    return _remote.updateProfile(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
    );
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) {
    return _remote.changePassword(
      userId: userId,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
