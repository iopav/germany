//  {
//   /* Primary brand colors */
//   --mosaica-charcoal: #1D241F;   /* main text, dark logo text, premium background */
//   --mosaica-gold: #C8A24A;       /* primary accent, lines, highlights, CTA accent */
//   --mosaica-terracotta: #B4553D; /* warm accent, section emphasis, secondary CTA */
//   --mosaica-clay: #C77B43;       /* softer orange/brown accent */

//   /* Supporting colors */
//   --mosaica-sage: #7B7C5C;       /* muted green, secondary UI elements */
//   --mosaica-slate: #5D6E70;      /* grey-blue, muted text, metadata */
//   --mosaica-cream: #F4E8CF;      /* table headers, soft panels */
//   --mosaica-light: #FAF7F0;      /* page/card background */
// }
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1D241F), // charcoal
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xFF1D241F), // charcoal
      secondary: const Color(0xFFC8A24A), // gold
      tertiary: const Color(0xFFB4553D), // terracotta
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      
    ),
    scaffoldBackgroundColor: const Color(0xFFFAF7F0), // light
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xFF1D241F), // charcoal
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: const Color(0xFF004AC6),
      unselectedItemColor: const Color(0xFF434655),
    ),
  );
}
