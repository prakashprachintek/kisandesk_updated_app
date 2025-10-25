import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const labelSmall = TextStyle(
    fontSize: 12,
    color: AppColors.error,
  );
}
