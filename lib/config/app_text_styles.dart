import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final TextStyle title = GoogleFonts.delius(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle body = GoogleFonts.delius(
    color: AppColors.textPrimary,
    fontSize: 16,
  );

  static final TextStyle small = GoogleFonts.delius(
    color: AppColors.textSecondary,
    fontSize: 14,
  );
  static final TextStyle label = GoogleFonts.delius(
    color: AppColors.textSecondary,
    fontSize: 12,
  );

  static final TextStyle bodySmall = GoogleFonts.delius(
    color: AppColors.textSecondary,
    fontSize: 12,
  );
}
