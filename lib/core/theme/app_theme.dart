import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0E0E10);
  static const Color bg = background;
  static const Color surface = Color(0xFF151517);
  static const Color surfaceAlt = Color(0xFF1C1C20);
  static const Color appBarTop = Color(0xFF211437);
  static const Color appBarBottom = Color(0xFF120B1E);
  static const Color accent = Color(0xFF7C4DFF);
  static const Color accent2 = Color(0xFFEA80FC);
  static const Color textPrimary = Color(0xF2FFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
}

class AppTheme {
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color surfaceAlt = AppColors.surfaceAlt;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color accent = AppColors.accent;

  static ThemeData themeData() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surface,
        centerTitle: true,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.accent,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
