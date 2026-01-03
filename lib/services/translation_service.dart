import 'translation_cache_service.dart';
import 'logger_service.dart';

/// Service for translating recipes with caching.
class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final TranslationCacheService _cache = TranslationCacheService();

  /// Translate recipe content.
  /// Returns cached translation if available, otherwise returns null.
  /// API translation should be called separately if cache miss.
  Future<RecipeTranslation?> getRecipeTranslation(
    String recipeId,
    String sourceLang,
    String targetLang,
  ) async {
    // Same language, no translation needed
    if (sourceLang == targetLang) return null;

    // Check cache first
    final cached = await _cache.getRecipeTranslation(recipeId, targetLang);
    if (cached != null) {
      LoggerService.debug('Translation found in cache: $recipeId -> $targetLang');
      return cached;
    }

    LoggerService.debug('No cached translation: $recipeId -> $targetLang');
    return null;
  }

  /// Save translation to cache after API call.
  Future<void> saveTranslation(
    String recipeId,
    String targetLang,
    RecipeTranslation translation,
  ) async {
    await _cache.saveRecipeTranslation(recipeId, targetLang, translation);
    LoggerService.info('Translation saved: $recipeId -> $targetLang');
  }

  /// Translate a single text field (with cache).
  Future<String?> translateField(
    String recipeId,
    String fieldName,
    String targetLang,
  ) async {
    final translations = await _cache.getTranslation(recipeId, targetLang);
    return translations?[fieldName];
  }

  /// Save single field translation.
  Future<void> saveFieldTranslation(
    String recipeId,
    String fieldName,
    String targetLang,
    String translatedValue,
  ) async {
    // Get existing cache or create new
    final existing = await _cache.getTranslation(recipeId, targetLang) ?? {};
    existing[fieldName] = translatedValue;
    await _cache.saveTranslation(recipeId, targetLang, existing);
  }

  /// Check if translation exists.
  Future<bool> hasTranslation(String recipeId, String targetLang) async {
    final cached = await _cache.getTranslation(recipeId, targetLang);
    return cached != null;
  }

  /// Get translation statistics.
  Future<TranslationStats> getStats() async {
    final cacheStats = await _cache.getStats();
    return TranslationStats(
      cachedTranslations: cacheStats.totalEntries,
      memoryCached: cacheStats.memoryEntries,
      localCached: cacheStats.localEntries,
      cloudCached: cacheStats.firestoreEntries,
    );
  }

  /// Clear all translations for a recipe.
  Future<void> clearRecipeTranslations(String recipeId) async {
    // Would need to implement in cache service
    LoggerService.info('Clearing translations for: $recipeId');
  }

  /// Supported languages.
  static const Map<String, String> supportedLanguages = {
    'tr': 'Türkçe',
    'en': 'English',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'ar': 'العربية',
    'ru': 'Русский',
    'it': 'Italiano',
    'pt': 'Português',
    'nl': 'Nederlands',
    'ja': '日本語',
    'ko': '한국어',
    'zh': '中文',
    'pl': 'Polski',
  };

  /// Get language name.
  static String getLanguageName(String code) {
    return supportedLanguages[code] ?? code.toUpperCase();
  }

  /// Check if language is RTL.
  static bool isRTL(String code) {
    return ['ar', 'he', 'fa', 'ur'].contains(code);
  }
}

/// Translation statistics.
class TranslationStats {
  final int cachedTranslations;
  final int memoryCached;
  final int localCached;
  final int cloudCached;

  TranslationStats({
    required this.cachedTranslations,
    required this.memoryCached,
    required this.localCached,
    required this.cloudCached,
  });

  /// Estimated API cost saved (assuming $0.002 per translation).
  double get estimatedSavings => cachedTranslations * 0.002;
}
