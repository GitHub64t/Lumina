import '../../data/models/profile_model.dart';
import '../repository/profile_repository.dart';

class GetProfileUsecase {
  const GetProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileModel> call() => _repository.getProfile();
}
