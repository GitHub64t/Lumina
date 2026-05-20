import '../../data/models/signup_model.dart';
import '../entities/user.dart';
import '../repository/auth_repository.dart';

class SignupUsecase {
  const SignupUsecase(this._repository);
  final AuthRepository _repository;

  Future<User> call(SignupModel model) => _repository.signup(model);
}
