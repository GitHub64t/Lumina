import '../../data/models/profile_model.dart';
import '../repository/profile_repository.dart';

class UpdateProfileUsecase {
  const UpdateProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileModel> call({
    required String userId,
    required String firstName,
    required String lastName,
    String? dateOfBirth,
  }) {
    return _repository.updateProfile(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
    );
  }
}
