import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Service for handling localization and language settings.
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _langKey = 'selected_language';
  static const String _countryKey = 'selected_country';

  /// Supported locales.
  static const List<Locale> supportedLocales = [
    Locale('tr', 'TR'),
    Locale('en', 'US'),
    Locale('de', 'DE'),
    Locale('fr', 'FR'),
    Locale('es', 'ES'),
    Locale('ar', 'SA'),
    Locale('ru', 'RU'),
    Locale('pt', 'BR'),
    Locale('it', 'IT'),
    Locale('ja', 'JP'),
    Locale('ko', 'KR'),
    Locale('zh', 'CN'),
    Locale('nl', 'NL'),
    Locale('pl', 'PL'),
  ];

  /// Language display names.
  static const Map<String, String> languageNames = {
    'tr': 'Türkçe',
    'en': 'English',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'ar': 'العربية',
    'ru': 'Русский',
    'pt': 'Português',
    'it': 'Italiano',
    'ja': '日本語',
    'ko': '한국어',
    'zh': '中文',
    'nl': 'Nederlands',
    'pl': 'Polski',
  };

  /// RTL languages.
  static const List<String> rtlLanguages = ['ar', 'fa', 'he'];

  /// Get current locale.
  Future<Locale> getCurrentLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_langKey) ?? 'tr';
    final countryCode = prefs.getString(_countryKey) ?? 'TR';
    return Locale(langCode, countryCode);
  }

  /// Set locale.
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, locale.languageCode);
    await prefs.setString(_countryKey, locale.countryCode ?? '');
    print('[LocalizationService] Locale set to: ${locale.languageCode}');
  }

  /// Get language name.
  String getLanguageName(String code) {
    return languageNames[code] ?? code;
  }

  /// Check if RTL.
  bool isRTL(String languageCode) {
    return rtlLanguages.contains(languageCode);
  }

  /// Get text direction.
  TextDirection getTextDirection(String languageCode) {
    return isRTL(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }
}

/// Service for Turkish recipe database.
class RecipeDatabaseService {
  static final RecipeDatabaseService _instance = RecipeDatabaseService._internal();
  factory RecipeDatabaseService() => _instance;
  RecipeDatabaseService._internal();

  /// Turkish recipe categories.
  static const List<String> turkishCategories = [
    'Ana Yemek',
    'Çorba',
    'Salata',
    'Tatlı',
    'Kahvaltı',
    'Aperatif',
    'İçecek',
    'Hamur İşi',
    'Sebze Yemekleri',
    'Et Yemekleri',
    'Deniz Ürünleri',
    'Pilav',
    'Makarna',
  ];

  /// Get sample Turkish recipes.
  List<Map<String, dynamic>> getSampleRecipes() {
    return [
      {
        'id': 'tr_001',
        'title': 'İskender Kebap',
        'category': 'Ana Yemek',
        'difficulty': 'Orta',
        'prepTime': 30,
        'cookTime': 45,
        'servings': 4,
        'calories': 650,
        'ingredients': ['kuzu eti', 'pide', 'tereyağı', 'domates', 'yoğurt'],
        'tags': ['kebap', 'et', 'türk mutfağı'],
      },
      {
        'id': 'tr_002',
        'title': 'Menemen',
        'category': 'Kahvaltı',
        'difficulty': 'Kolay',
        'prepTime': 10,
        'cookTime': 15,
        'servings': 2,
        'calories': 280,
        'ingredients': ['yumurta', 'domates', 'yeşil biber', 'soğan'],
        'tags': ['kahvaltı', 'yumurta', 'kolay'],
      },
      {
        'id': 'tr_003',
        'title': 'Mercimek Çorbası',
        'category': 'Çorba',
        'difficulty': 'Kolay',
        'prepTime': 15,
        'cookTime': 30,
        'servings': 6,
        'calories': 180,
        'ingredients': ['kırmızı mercimek', 'soğan', 'havuç', 'patates'],
        'tags': ['çorba', 'vegan', 'sağlıklı'],
      },
      {
        'id': 'tr_004',
        'title': 'Karnıyarık',
        'category': 'Ana Yemek',
        'difficulty': 'Orta',
        'prepTime': 25,
        'cookTime': 40,
        'servings': 4,
        'calories': 420,
        'ingredients': ['patlıcan', 'kıyma', 'soğan', 'domates', 'biber'],
        'tags': ['patlıcan', 'kıyma', 'türk mutfağı'],
      },
      {
        'id': 'tr_005',
        'title': 'Baklava',
        'category': 'Tatlı',
        'difficulty': 'Zor',
        'prepTime': 60,
        'cookTime': 45,
        'servings': 24,
        'calories': 350,
        'ingredients': ['yufka', 'ceviz', 'tereyağı', 'şeker', 'su'],
        'tags': ['tatlı', 'bayram', 'geleneksel'],
      },
      {
        'id': 'tr_006',
        'title': 'Lahmacun',
        'category': 'Hamur İşi',
        'difficulty': 'Orta',
        'prepTime': 40,
        'cookTime': 15,
        'servings': 8,
        'calories': 280,
        'ingredients': ['un', 'kıyma', 'soğan', 'domates', 'maydanoz'],
        'tags': ['hamur işi', 'kıyma', 'fast food'],
      },
      {
        'id': 'tr_007',
        'title': 'Mantı',
        'category': 'Ana Yemek',
        'difficulty': 'Zor',
        'prepTime': 90,
        'cookTime': 20,
        'servings': 6,
        'calories': 480,
        'ingredients': ['un', 'kıyma', 'yoğurt', 'sarımsak', 'tereyağı'],
        'tags': ['hamur işi', 'kıyma', 'geleneksel'],
      },
      {
        'id': 'tr_008',
        'title': 'Pide',
        'category': 'Hamur İşi',
        'difficulty': 'Orta',
        'prepTime': 45,
        'cookTime': 20,
        'servings': 4,
        'calories': 520,
        'ingredients': ['un', 'kıyma', 'peynir', 'yumurta', 'maya'],
        'tags': ['hamur işi', 'fırın', 'türk mutfağı'],
      },
    ];
  }

  /// Search recipes.
  List<Map<String, dynamic>> searchRecipes(String query) {
    final recipes = getSampleRecipes();
    return recipes.where((r) {
      final title = (r['title'] as String).toLowerCase();
      final tags = (r['tags'] as List).join(' ').toLowerCase();
      return title.contains(query.toLowerCase()) ||
          tags.contains(query.toLowerCase());
    }).toList();
  }

  /// Get by category.
  List<Map<String, dynamic>> getByCategory(String category) {
    return getSampleRecipes()
        .where((r) => r['category'] == category)
        .toList();
  }
}
