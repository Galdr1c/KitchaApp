import 'package:flutter/material.dart';

/// Seasonal theme types.
enum SeasonalTheme {
  none,
  newYear,       // 25 Aralık - 7 Ocak
  valentines,    // 10-14 Şubat
  ramadan,       // Ramazan ayı (değişken)
  spring,        // 20 Mart - 20 Haziran
  summer,        // 21 Haziran - 22 Eylül
  halloween,     // 25-31 Ekim
  thanksgiving,  // Kasım son perşembe
  christmas,     // 20-25 Aralık
}

/// Seasonal theme data model.
class SeasonalThemeData {
  final SeasonalTheme theme;
  final String name;
  final Color primaryColor;
  final Color accentColor;
  final String animationAsset;
  final List<String> emojis;
  final String greeting;
  final List<String> suggestedCategories;

  const SeasonalThemeData({
    required this.theme,
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    required this.animationAsset,
    required this.emojis,
    required this.greeting,
    this.suggestedCategories = const [],
  });

  LinearGradient get gradient => LinearGradient(
        colors: [primaryColor, accentColor],
      );
}

/// Service for seasonal theme management.
class SeasonalService {
  static final SeasonalService _instance = SeasonalService._internal();
  factory SeasonalService() => _instance;
  SeasonalService._internal();

  static const Map<SeasonalTheme, SeasonalThemeData> _themes = {
    SeasonalTheme.newYear: SeasonalThemeData(
      theme: SeasonalTheme.newYear,
      name: 'Yeni Yıl',
      primaryColor: Color(0xFFFFD700),
      accentColor: Color(0xFFFF6347),
      animationAsset: 'assets/animations/fireworks.json',
      emojis: ['🎊', '🎉', '✨', '🥳'],
      greeting: 'Mutlu Yıllar! 🎉',
      suggestedCategories: ['Parti', 'Kutlama', 'Tatlı'],
    ),
    SeasonalTheme.valentines: SeasonalThemeData(
      theme: SeasonalTheme.valentines,
      name: 'Sevgililer Günü',
      primaryColor: Color(0xFFFF69B4),
      accentColor: Color(0xFFFF1493),
      animationAsset: 'assets/animations/hearts.json',
      emojis: ['💕', '💖', '💗', '❤️'],
      greeting: 'Sevgiyle! 💕',
      suggestedCategories: ['Romantik', 'Çikolata', 'Tatlı'],
    ),
    SeasonalTheme.ramadan: SeasonalThemeData(
      theme: SeasonalTheme.ramadan,
      name: 'Ramazan',
      primaryColor: Color(0xFF9B59B6),
      accentColor: Color(0xFF8E44AD),
      animationAsset: 'assets/animations/stars_moon.json',
      emojis: ['🌙', '⭐', '🕌', '🤲'],
      greeting: 'Hayırlı Ramazanlar! 🌙',
      suggestedCategories: ['İftar', 'Çorba', 'Ramazan Pidesi', 'Tatlı'],
    ),
    SeasonalTheme.spring: SeasonalThemeData(
      theme: SeasonalTheme.spring,
      name: 'İlkbahar',
      primaryColor: Color(0xFF4CAF50),
      accentColor: Color(0xFFE91E63),
      animationAsset: 'assets/animations/flowers.json',
      emojis: ['🌸', '🌷', '🌻', '🐝'],
      greeting: 'Bahar geldi! 🌸',
      suggestedCategories: ['Salata', 'Hafif', 'Taze'],
    ),
    SeasonalTheme.summer: SeasonalThemeData(
      theme: SeasonalTheme.summer,
      name: 'Yaz',
      primaryColor: Color(0xFFFF9800),
      accentColor: Color(0xFF03A9F4),
      animationAsset: 'assets/animations/sun.json',
      emojis: ['☀️', '🏖️', '🍉', '🌴'],
      greeting: 'Yaz keyfi! ☀️',
      suggestedCategories: ['Izgara', 'Salata', 'İçecek', 'Dondurma'],
    ),
    SeasonalTheme.halloween: SeasonalThemeData(
      theme: SeasonalTheme.halloween,
      name: 'Halloween',
      primaryColor: Color(0xFFFF8C00),
      accentColor: Color(0xFF8B4513),
      animationAsset: 'assets/animations/bats.json',
      emojis: ['🎃', '👻', '🦇', '🕷️'],
      greeting: 'Hadi biraz korkalım! 🎃',
      suggestedCategories: ['Balkabağı', 'Parti'],
    ),
    SeasonalTheme.christmas: SeasonalThemeData(
      theme: SeasonalTheme.christmas,
      name: 'Noel',
      primaryColor: Color(0xFFDC143C),
      accentColor: Color(0xFF228B22),
      animationAsset: 'assets/animations/snowflakes.json',
      emojis: ['🎄', '🎅', '❄️', '⛄'],
      greeting: 'Mutlu Noeller! 🎄',
      suggestedCategories: ['Hindi', 'Tatlı', 'Sıcak İçecek'],
    ),
  };

  /// Get current seasonal theme based on date.
  SeasonalTheme getCurrentTheme() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    // Yeni Yıl (25 Aralık - 7 Ocak)
    if ((month == 12 && day >= 25) || (month == 1 && day <= 7)) {
      return SeasonalTheme.newYear;
    }

    // Sevgililer Günü (10-14 Şubat)
    if (month == 2 && day >= 10 && day <= 14) {
      return SeasonalTheme.valentines;
    }

    // Ramazan (Mart-Nisan civarı, yıla göre değişir)
    // 2024: 10 Mart - 9 Nisan
    // 2025: 28 Şubat - 29 Mart
    // 2026: 17 Şubat - 19 Mart
    if (month == 2 && day >= 17 || month == 3 && day <= 19) {
      return SeasonalTheme.ramadan;
    }

    // Halloween (25-31 Ekim)
    if (month == 10 && day >= 25) {
      return SeasonalTheme.halloween;
    }

    // Noel (20-24 Aralık)
    if (month == 12 && day >= 20 && day < 25) {
      return SeasonalTheme.christmas;
    }

    // İlkbahar (20 Mart - 20 Haziran)
    if ((month == 3 && day >= 20) || month == 4 || month == 5 || (month == 6 && day <= 20)) {
      return SeasonalTheme.spring;
    }

    // Yaz (21 Haziran - 22 Eylül)
    if ((month == 6 && day >= 21) || month == 7 || month == 8 || (month == 9 && day <= 22)) {
      return SeasonalTheme.summer;
    }

    return SeasonalTheme.none;
  }

  /// Get theme data for a specific theme.
  SeasonalThemeData? getThemeData(SeasonalTheme theme) {
    return _themes[theme];
  }

  /// Get current theme data.
  SeasonalThemeData? getCurrentThemeData() {
    final theme = getCurrentTheme();
    if (theme == SeasonalTheme.none) return null;
    return _themes[theme];
  }

  /// Check if any seasonal theme is active.
  bool isSeasonActive() {
    return getCurrentTheme() != SeasonalTheme.none;
  }

  /// Get seasonal recipe suggestions.
  List<String> getSeasonalSuggestions() {
    final themeData = getCurrentThemeData();
    return themeData?.suggestedCategories ?? [];
  }

  /// Get greeting message.
  String getGreeting() {
    final themeData = getCurrentThemeData();
    return themeData?.greeting ?? 'Hoş geldin! 👋';
  }

  /// Get decorative emojis.
  List<String> getEmojis() {
    final themeData = getCurrentThemeData();
    return themeData?.emojis ?? [];
  }
}
