import '../../../../core/storage/secure_storage_service.dart';

class AuthLocalDatasource {
  AuthLocalDatasource(this._storage);

  final SecureStorageService _storage;

  Future<void> saveTokens(String accessToken, String? refreshToken) =>
      _storage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);

  Future<bool> hasToken() async =>
      (await _storage.accessToken)?.isNotEmpty == true;
  Future<String?> get refreshToken => _storage.refreshToken;

  /// Persists the user email so OTP flows can use it without re-entry.
  Future<void> saveEmail(String email) => _storage.setEmail(email);
  Future<String?> get email => _storage.email;

  Future<void> clear() => _storage.clearAll();
}

