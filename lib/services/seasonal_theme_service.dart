import 'package:flutter/material.dart';

/// Service for seasonal theme management.
class SeasonalThemeService {
  static final SeasonalThemeService _instance = SeasonalThemeService._internal();
  factory SeasonalThemeService() => _instance;
  SeasonalThemeService._internal();

  /// Get current season.
  Season getCurrentSeason() {
    final month = DateTime.now().month;
    
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }

  /// Get seasonal theme data.
  SeasonalTheme getSeasonalTheme() {
    switch (getCurrentSeason()) {
      case Season.spring:
        return const SeasonalTheme(
          name: 'Bahar',
          primaryColor: Color(0xFF4CAF50),
          accentColor: Color(0xFFE91E63),
          gradientColors: [Color(0xFF81C784), Color(0xFFFFF176)],
          emoji: '🌸',
          greeting: 'Bahar geldi, taze lezzetler seni bekliyor!',
          suggestedCategories: ['Salata', 'Hafif Yemekler', 'Sebze'],
          decorativeEmojis: ['🌷', '🌻', '🐝', '🦋'],
        );
      case Season.summer:
        return const SeasonalTheme(
          name: 'Yaz',
          primaryColor: Color(0xFFFF9800),
          accentColor: Color(0xFF03A9F4),
          gradientColors: [Color(0xFFFFB74D), Color(0xFF4FC3F7)],
          emoji: '☀️',
          greeting: 'Sıcak yaz günlerinde serinleten tarifler!',
          suggestedCategories: ['İçecek', 'Meyve', 'Izgara', 'Dondurma'],
          decorativeEmojis: ['🍉', '🍦', '🏖️', '🌴'],
        );
      case Season.autumn:
        return const SeasonalTheme(
          name: 'Sonbahar',
          primaryColor: Color(0xFFFF5722),
          accentColor: Color(0xFF795548),
          gradientColors: [Color(0xFFFF8A65), Color(0xFFFFCC80)],
          emoji: '🍂',
          greeting: 'Sonbaharın sıcak lezzetleri!',
          suggestedCategories: ['Çorba', 'Güveç', 'Fırın', 'Tatlı'],
          decorativeEmojis: ['🎃', '🍁', '🌰', '🥧'],
        );
      case Season.winter:
        return const SeasonalTheme(
          name: 'Kış',
          primaryColor: Color(0xFF2196F3),
          accentColor: Color(0xFF9C27B0),
          gradientColors: [Color(0xFF64B5F6), Color(0xFFE1BEE7)],
          emoji: '❄️',
          greeting: 'Kış sofralarını ısıtan tarifler!',
          suggestedCategories: ['Çorba', 'Kızartma', 'Sıcak İçecek', 'Hamur İşi'],
          decorativeEmojis: ['⛄', '🎄', '🔥', '☕'],
        );
    }
  }

  /// Check if there's a special holiday.
  SpecialEvent? getCurrentSpecialEvent() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    // Ramadan (approximate, should use Hijri calendar)
    if (month == 3 || month == 4) {
      return const SpecialEvent(
        name: 'Ramazan',
        emoji: '🌙',
        greeting: 'Ramazan ayına özel iftar tarifleri!',
        suggestedCategories: ['İftar', 'Çorba', 'Tatlı'],
      );
    }

    // New Year
    if ((month == 12 && day >= 25) || (month == 1 && day <= 5)) {
      return const SpecialEvent(
        name: 'Yılbaşı',
        emoji: '🎄',
        greeting: 'Yeni yıla özel lezzetler!',
        suggestedCategories: ['Parti', 'Tatlı', 'İçecek'],
      );
    }

    // Valentine's Day
    if (month == 2 && day >= 10 && day <= 14) {
      return const SpecialEvent(
        name: 'Sevgililer Günü',
        emoji: '💕',
        greeting: 'Romantik akşam yemekleri için öneriler!',
        suggestedCategories: ['Romantik', 'Tatlı', 'Çikolata'],
      );
    }

    return null;
  }

  /// Get seasonal recipe suggestions.
  List<String> getSeasonalIngredients() {
    switch (getCurrentSeason()) {
      case Season.spring:
        return ['enginar', 'bezelye', 'çilek', 'kuşkonmaz', 'ıspanak'];
      case Season.summer:
        return ['domates', 'biber', 'patlıcan', 'karpuz', 'şeftali'];
      case Season.autumn:
        return ['balkabağı', 'mantar', 'elma', 'ayva', 'armut'];
      case Season.winter:
        return ['lahana', 'pırasa', 'kereviz', 'portakal', 'nar'];
    }
  }
}

/// Seasons enum.
enum Season { spring, summer, autumn, winter }

/// Seasonal theme data.
class SeasonalTheme {
  final String name;
  final Color primaryColor;
  final Color accentColor;
  final List<Color> gradientColors;
  final String emoji;
  final String greeting;
  final List<String> suggestedCategories;
  final List<String> decorativeEmojis;

  const SeasonalTheme({
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    required this.gradientColors,
    required this.emoji,
    required this.greeting,
    required this.suggestedCategories,
    required this.decorativeEmojis,
  });

  LinearGradient get gradient => LinearGradient(colors: gradientColors);
}

/// Special event data.
class SpecialEvent {
  final String name;
  final String emoji;
  final String greeting;
  final List<String> suggestedCategories;

  const SpecialEvent({
    required this.name,
    required this.emoji,
    required this.greeting,
    required this.suggestedCategories,
  });
}
