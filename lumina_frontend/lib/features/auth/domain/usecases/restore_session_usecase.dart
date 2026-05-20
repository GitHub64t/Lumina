import '../entities/user.dart';
import '../repository/auth_repository.dart';

class RestoreSessionUsecase {
  const RestoreSessionUsecase(this._repository);

  final AuthRepository _repository;

  Future<User?> call() => _repository.restoreSession();
}
