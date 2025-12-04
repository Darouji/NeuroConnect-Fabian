// Archivo: lib/utils/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // --- TEMA CLARO ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlue,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textLight,
      elevation: 0,
    ),
    // CORRECCIÓN AQUÍ: Usamos CardThemeData en lugar de CardTheme
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight, width: 1.5),
      ),
    ),
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        color: AppColors.textLight,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: AppColors.textSubtleLight),
    ),
  );

  // --- TEMA OSCURO ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryBlue,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textDark,
      elevation: 0,
    ),
    // CORRECCIÓN AQUÍ: Usamos CardThemeData en lugar de CardTheme
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderDark, width: 1.5),
      ),
    ),
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: AppColors.textSubtleDark),
    ),
  );
}
