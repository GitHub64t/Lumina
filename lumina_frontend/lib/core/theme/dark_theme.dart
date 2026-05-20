import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'text_theme.dart';

class DarkTheme {
  const DarkTheme._();

  static ThemeData get data {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: scheme.copyWith(
        primary: AppColors.accent,
        surface: AppColors.darkSurface,
        outline: const Color(0xFF263248),
      ),
      textTheme: AppTextTheme.build(Colors.white),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF263248)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF263248)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF263248)),
        ),
      ),
    );
  }
}
