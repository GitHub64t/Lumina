import 'package:flutter/material.dart';

class AppTextTheme {
  const AppTextTheme._();

  static TextTheme build(Color color) {
    const family = 'Arial';
    return TextTheme(
      displaySmall: TextStyle(
        fontFamily: family,
        fontSize: 38,
        height: 1.05,
        fontWeight: FontWeight.w800,
        color: color,
      ),
      headlineMedium: TextStyle(
        fontFamily: family,
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: color,
      ),
      titleLarge: TextStyle(
        fontFamily: family,
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleMedium: TextStyle(
        fontFamily: family,
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      bodyLarge: TextStyle(
        fontFamily: family,
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: TextStyle(
        fontFamily: family,
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      labelLarge: TextStyle(
        fontFamily: family,
        fontSize: 14,
        height: 1,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}
