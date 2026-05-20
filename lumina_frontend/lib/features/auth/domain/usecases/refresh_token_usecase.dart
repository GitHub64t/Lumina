import '../repository/auth_repository.dart';

class RefreshTokenUsecase {
  const RefreshTokenUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.refreshToken();
}
