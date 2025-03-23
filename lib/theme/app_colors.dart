import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primaryDark = Color(0xFF5A3825);    // Dark Brown
  static const primary = Color(0xFFE74C3C);        // Moroccan Red
  static const primaryLight = Color(0xFFF8D7D5);   // Light Red
  
  // Accent Colors
  static const accent1 = Color(0xFF26A69A);        // Teal Blue (Moroccan tiles)
  static const accent2 = Color(0xFFF4D03F);        // Moroccan Yellow/Gold
  static const accent3 = Color(0xFF16A085);        // Moroccan Green
  
  // Background Colors
  static const background = Color(0xFFF8F5F2);     // Warm Off-white
  static const cardBackground = Color(0xFFFFFFFF); // White
  static const secondaryBackground = Color(0xFFFAF6F0); // Cream
  
  // Text Colors
  static const textPrimary = Color(0xFF2C3E50);    // Dark Slate
  static const textSecondary = Color(0xFF7F8C8D);  // Medium Gray
  static const textTertiary = Color(0xFFBDC3C7);   // Light Gray
  static const textLight = Color(0xFFFFFFFF);      // White
  
  // Status Colors
  static const success = Color(0xFF16A085);        // Green
  static const error = Color(0xFFA32F2F);          // Deep Red
  static const warning = Color(0xFFF39C12);        // Orange
  static const info = Color(0xFF3498DB);           // Blue

  // Borders
  static const border = Color(0xFFE0E0E0);         // Light Gray
  static const borderDark = Color(0xFF5A3825);     // Dark Brown
  
  // Shadows
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowMedium = Colors.black.withOpacity(0.1);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFFC0392B)],
  );
  
  static const LinearGradient moroccanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE74C3C),
      Color(0xFFF4D03F),
    ],
  );
  
  // Difficulty Colors
  static const Map<String, Color> difficultyColors = {
    'Easy': Color(0xFF16A085),      // Green
    'Medium': Color(0xFFF39C12),    // Orange
    'Hard': Color(0xFFE74C3C),      // Red
  };
  
  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Breakfast': Color(0xFF3498DB),  // Blue
    'Lunch': Color(0xFFF4D03F),      // Yellow
    'Dinner': Color(0xFFE74C3C),     // Red
    'Snack': Color(0xFF16A085),      // Green
    'Dessert': Color(0xFF9B59B6),    // Purple
  };
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    letterSpacing: -0.5,
    height: 1.3,
  );

  static const heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    letterSpacing: -0.3,
    height: 1.35,
  );
  
  static const heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    height: 1.4,
  );
  
  static const heading4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    height: 1.4,
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
  
  static const bodySmall = TextStyle(
    fontSize: 12,
    height: 1.4,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );
  
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    fontFamily: 'Inter',
    letterSpacing: 0.5,
  );
  
  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
    letterSpacing: 0.3,
  );
  
  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
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
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double circular = 100.0;
}

class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> elevated = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 6,
      offset: const Offset(0, 3),
    ),
  ];
}