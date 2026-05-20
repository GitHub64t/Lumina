import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryFallback = <String, String>{};

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _emailKey = 'auth_email';
  static const _onboardingKey = 'onboarding_complete';
  static const _themeKey = 'theme_mode';

  Future<String?> get accessToken => _read(_accessTokenKey);
  Future<String?> get refreshToken => _read(_refreshTokenKey);
  Future<bool> get hasAccessToken async =>
      (await accessToken)?.isNotEmpty ?? false;

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _write(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await _write(_refreshTokenKey, refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _delete(_accessTokenKey);
    await _delete(_refreshTokenKey);
  }

  /// Email is stored after signup so OTP verification can include it.
  Future<String?> get email => _read(_emailKey);
  Future<void> setEmail(String value) => _write(_emailKey, value);

  /// Clears all auth-related data (tokens + email) on logout.
  Future<void> clearAll() async {
    await clearTokens();
    await _delete(_emailKey);
  }

  Future<bool> get isOnboardingComplete async =>
      (await _read(_onboardingKey)) == 'true';

  Future<void> setOnboardingComplete() => _write(_onboardingKey, 'true');

  Future<String?> get themeMode => _read(_themeKey);

  Future<void> setThemeMode(String value) => _write(_themeKey, value);

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on MissingPluginException {
      return _memoryFallback[key];
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on MissingPluginException {
      _memoryFallback[key] = value;
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on MissingPluginException {
      _memoryFallback.remove(key);
    }
  }
}

