import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ThemeData global aplikasi MountClimb.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.background,
      // ColorScheme Material 3 digenerate langsung dari seed warna biru
      // bawaan Flutter (Colors.blue), bukan warna custom.
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        primary: AppColors.primary,
        secondary: AppColors.accentGold,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
