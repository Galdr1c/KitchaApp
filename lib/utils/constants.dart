import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // App info
  static const String appName = 'Kitcha';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'kitcha.db';
  static const int databaseVersion = 1;

  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxSearchResults = 20;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Image
  static const double maxImageSize = 1024.0;
  static const int imageQuality = 85;

  // Animation
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Nutrition
  static const int defaultDailyCalories = 2000;
  static const double defaultDailyProtein = 50.0;
  static const double defaultDailyCarbs = 250.0;
  static const double defaultDailyFat = 65.0;
}

/// App color palette
class AppColors {
  // Primary colors (Warm Tomato Red)
  static const Color primary = Color(0xFFE94B3C);
  static const Color primaryLight = Color(0xFFF17C71);
  static const Color primaryDark = Color(0xFFC83B2F);

  // Secondary colors (AI Mint Green)
  static const Color secondary = Color(0xFF2ED8A7);
  static const Color secondaryLight = Color(0xFF63E2BE);
  static const Color secondaryDark = Color(0xFF24A581);

  // Accent colors
  static const Color accent = Color(0xFFE94B3C);
  
  // Neutral colors
  static const Color background = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF2ED8A7);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Text colors
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFFBDBDBD);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkTextPrimary = Color(0xFFFAFAF8);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // Nutrition indicator colors
  static const Color caloriesColor = Color(0xFFE94B3C);
  static const Color proteinColor = Color(0xFF2ED8A7);
  static const Color carbsColor = Color(0xFFFFCA28);
  static const Color fatColor = Color(0xFFAB47BC);
  static const Color fiberColor = Color(0xFF66BB6A);
}

/// Text styles
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}

/// Route names
class AppRoutes {
  static const String home = '/';
  static const String recipeSearch = '/recipe-search';
  static const String recipeDetail = '/recipe-detail';
  static const String favorites = '/favorites';
  static const String camera = '/camera';
  static const String analysis = '/analysis';
  static const String history = '/history';
  static const String settings = '/settings';
}

