import '../../data/models/login_model.dart';
import '../entities/user.dart';
import '../repository/auth_repository.dart';

class LoginUsecase {
  const LoginUsecase(this._repository);
  final AuthRepository _repository;

  Future<User> call(LoginModel model) => _repository.login(model);
}
