import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primaryDark = Color(0xFF1F2937);    // Dark text color
  static const primary = Color(0xFF7FBEB3);        // Teal/mint accent color
  
  // Background Colors
  static const background = Color(0xFFFAFAFA);     // Light background
  static const cardBackground = Color(0xFFFFFFFF);  // White card background
  
  // Text Colors
  static const textPrimary = Color(0xFF1F2937);    // Primary text
  static const textSecondary = Color(0xFF6B7280);  // Secondary/gray text
  static const textLight = Color(0xFFFFFFFF);      // White text
  
  // Status Colors
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  static const heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
} 