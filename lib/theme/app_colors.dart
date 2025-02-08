import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primaryDark = Color(0xFF5A3825);    // Dark Brown
  static const primary = Color(0xFFD97642);        // Burnt Orange
  
  // Background Colors
  static const background = Color(0xFFF8F5F2);     // Off-white
  static const cardBackground = Color(0xFFFFFFFF);  // White
  
  // Text Colors
  static const textPrimary = Color(0xFF5A3825);    // Dark Brown
  static const textSecondary = Color(0xFFD97642);  // Burnt Orange
  static const textLight = Color(0xFFFFFFFF);      // White
  
  // Accent Colors
  static const accent = Color(0xFFA32F2F);         // Deep Red
  static const highlight = Color(0xFFE2B13C);      // Golden Yellow
  
  // Status Colors
  static const success = Color(0xFFD97642);        // Burnt Orange
  static const error = Color(0xFFA32F2F);          // Deep Red

  // borders
  static const Color border = Color(0xFF5A3825);   // Dark Brown for borders
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
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Inter'
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
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
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