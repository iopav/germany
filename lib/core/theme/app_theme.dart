import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppTheme {
  static ThemeData lightTheme(AppPalette palette) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: palette.primary,
      extensions: [palette],
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: palette.primary,
            brightness: Brightness.light,
          ).copyWith(
            primary: palette.primary,
            secondary: palette.secondary,
            tertiary: palette.tertiary,
            surface: palette.surface,
            onPrimary: palette.onPrimary,
            onSecondary: palette.onPrimary,
            onSurface: palette.onSurface,
            error: palette.error,
          ),
      scaffoldBackgroundColor: palette.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: palette.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.onSurfaceVariant,
      ),
    );
  }
}
