import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Kumpulan TextStyle yang dipakai berulang di seluruh aplikasi.
/// Dipisah dari widget/page supaya typography konsisten & mudah diubah.
class AppTextStyles {
  AppTextStyles._();

  static final heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static final title = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final body = TextStyle(
    fontSize: 13,
    color: AppColors.textMuted,
    height: 1.5,
  );

  static final caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static final price = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );
}
