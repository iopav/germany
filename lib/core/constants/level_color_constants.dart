import 'package:flutter/material.dart';

class LevelColorConstants {
  LevelColorConstants._();

  static const Color a1 = Color(0xFF4FC3F7);
  static const Color a2 = Color(0xFF29B6F6);
  static const Color b1 = Color(0xFF66BB6A);
  static const Color b2 = Color(0xFF43A047);
  static const Color c1 = Color(0xFFFFB74D);
  static const Color c2 = Color(0xFFEF5350);
  static const Color fallback = Color(0xFFB0BEC5);

  static Color forLevel(String level) {
    switch (level.trim().toUpperCase()) {
      case 'A1':
        return a1;
      case 'A2':
        return a2;
      case 'B1':
        return b1;
      case 'B2':
        return b2;
      case 'C1':
        return c1;
      case 'C2':
        return c2;
      default:
        return fallback;
    }
  }
}