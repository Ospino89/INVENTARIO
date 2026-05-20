import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgPrimary = Color(0xFF0F1729);
  static const Color bgSidebar = Color(0xFF0A1020);
  static const Color bgCard = Color(0xFF1A2540);
  static const Color bgCardDeep = Color(0xFF15203A);
  static const Color borderColor = Color(0xFF2A3A5C);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC4CDD9);
  static const Color textMuted = Color(0xFF8892A4);
  static const Color textHint = Color(0xFF4A5568);
  static const Color accent = Color(0xFF4F6EF7);
  static const Color accentPink = Color(0xFFF472B6);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);
  static const Color successBg = Color(0xFF0D2E1A);
  static const Color warningBg = Color(0xFF2E2010);
  static const Color dangerBg = Color(0xFF2E1010);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgPrimary,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(primary: accent, surface: bgCard),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgSidebar,
      foregroundColor: textPrimary,
      elevation: 0,
    ),
  );
}
