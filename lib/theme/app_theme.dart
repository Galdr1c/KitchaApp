import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme configuration class
class AppTheme {
  // Kitcha Professional Palette
  static const Color primaryColor = Color(0xFFE94B3C); // Warm Tomato Red
  static const Color backgroundDark = Color(0xFF1E1E1E); // Charcoal Black
  static const Color backgroundLight = Color(0xFFFAFAF8); // Soft Cream White
  static const Color accentAI = Color(0xFF2ED8A7); // AI Fresh Mint Green
  static const Color neutralGray = Color(0xFF9CA3AF); // Cool Gray
  
  // Semantic colors
  static const Color success = accentAI;
  static const Color error = Color(0xFFD32F2F);
  
  /// Light Theme
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentAI,
        surface: Colors.white,
        background: backgroundLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundLight,
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: backgroundDark,
        foregroundColor: backgroundLight,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
        labelStyle: const TextStyle(color: neutralGray),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: neutralGray,
        type: BottomNavigationBarType.fixed,
      ),
    );
    
    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(color: backgroundDark, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.poppins(color: backgroundDark, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(color: backgroundDark),
        bodyMedium: GoogleFonts.poppins(color: neutralGray),
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentAI,
        surface: backgroundDark,
        background: Colors.black,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: backgroundLight,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
        labelStyle: const TextStyle(color: neutralGray),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF252525),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    
    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(color: backgroundLight, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.poppins(color: backgroundLight, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(color: backgroundLight),
        bodyMedium: GoogleFonts.poppins(color: neutralGray),
      ),
    );
  }

  // --- Shimmer Themes ---
  static Color get shimmerBaseColor => backgroundDark.withOpacity(0.1);
  static Color get shimmerHighlightColor => backgroundLight.withOpacity(0.1);
  static Color get shimmerBaseColorDark => Colors.white.withOpacity(0.05);
  static Color get shimmerHighlightColorDark => Colors.white.withOpacity(0.1);
}
