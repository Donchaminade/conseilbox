import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.cafe,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.cafe, primary: AppColors.cafe, secondary: AppColors.chocolat),
      textTheme: TextTheme(
        titleLarge: AppTextStyles.title,
        bodyMedium: AppTextStyles.body,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cafe,
        foregroundColor: AppColors.blanc,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}