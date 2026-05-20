import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/secure_storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(ThemeMode.system) {
    _restore();
  }

  final SecureStorageService _storage;

  Future<void> _restore() async {
    final value = await _storage.themeMode;
    emit(switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    });
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    await _storage.setThemeMode(mode.name);
  }
}
