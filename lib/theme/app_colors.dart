import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primaryDark = Color(0xFF5A3825);    // Dark Brown
  static const primary = Color(0xFFE74C3C);        // Moroccan Red
  static const accent1 = Color(0xFF26A69A);        // Teal Blue (Moroccan tiles)
  static const accent2 = Color(0xFFF4D03F);        // Moroccan Yellow/Gold
  static const accent3 = Color(0xFF16A085);        // Moroccan Green
  
  // Background Colors
  static const background = Color(0xFFF8F5F2);     // Warm Off-white
  static const cardBackground = Color(0xFFFFFFFF); // White
  
  // Text Colors
  static const textPrimary = Color(0xFF2C3E50);    // Dark Slate
  static const textSecondary = Color(0xFFE74C3C);  // Moroccan Red
  static const textLight = Color(0xFFFFFFFF);      // White
  
  // Accent Colors
  static const accent = Color(0xFFA32F2F);         // Deep Red
  static const highlight = Color(0xFFE2B13C);      // Golden Yellow
  
  // Status Colors
  static const success = Color(0xFF16A085);        // Green
  static const error = Color(0xFFA32F2F);          // Deep Red

  // borders
  static const Color border = Color(0xFF5A3825);   // Dark Brown for borders
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    letterSpacing: -0.5,
  );

  static const heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    letterSpacing: -0.3,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Inter'
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
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
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}