import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Size get screen => MediaQuery.sizeOf(this);
  bool get isMobile => screen.width < 700;
  bool get isTablet => screen.width >= 700 && screen.width < 1024;
  bool get isDesktop => screen.width >= 1024;
}
