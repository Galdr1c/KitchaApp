import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';
import 'logger_service.dart';

/// Service for caching recipe translations to avoid repeated API calls.
class TranslationCacheService {
  static final TranslationCacheService _instance = TranslationCacheService._internal();
  factory TranslationCacheService() => _instance;
  TranslationCacheService._internal();

  static const String _cacheKey = 'translation_cache';
  static const Duration _cacheExpiry = Duration(days: 30);

  Map<String, CachedTranslation>? _memoryCache;

  /// Get cached translation for a recipe.
  Future<Map<String, String>?> getTranslation(String recipeId, String targetLang) async {
    final cacheKey = '${recipeId}_$targetLang';

    // Check memory cache first
    if (_memoryCache != null && _memoryCache!.containsKey(cacheKey)) {
      final cached = _memoryCache![cacheKey]!;
      if (!cached.isExpired) {
        LoggerService.debug('Translation cache hit (memory): $cacheKey');
        return cached.translations;
      }
    }

    // Check Firestore cache
    if (FirebaseService.isAvailable) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('translation_cache')
            .doc(cacheKey)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final timestamp = (data['timestamp'] as Timestamp).toDate();
          
          if (DateTime.now().difference(timestamp) < _cacheExpiry) {
            final translations = Map<String, String>.from(data['translations'] ?? {});
            
            // Store in memory cache
            _memoryCache ??= {};
            _memoryCache![cacheKey] = CachedTranslation(
              translations: translations,
              timestamp: timestamp,
            );
            
            LoggerService.debug('Translation cache hit (Firestore): $cacheKey');
            return translations;
          }
        }
      } catch (e) {
        LoggerService.warning('Firestore cache read error: $e');
      }
    }

    // Check local cache as fallback
    final localCache = await _getLocalCache();
    if (localCache.containsKey(cacheKey)) {
      final cached = localCache[cacheKey]!;
      if (!cached.isExpired) {
        LoggerService.debug('Translation cache hit (local): $cacheKey');
        return cached.translations;
      }
    }

    LoggerService.debug('Translation cache miss: $cacheKey');
    return null;
  }

  /// Save translation to cache.
  Future<void> saveTranslation(
    String recipeId,
    String targetLang,
    Map<String, String> translations,
  ) async {
    final cacheKey = '${recipeId}_$targetLang';
    final now = DateTime.now();

    // Save to memory cache
    _memoryCache ??= {};
    _memoryCache![cacheKey] = CachedTranslation(
      translations: translations,
      timestamp: now,
    );

    // Save to Firestore
    if (FirebaseService.isAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('translation_cache')
            .doc(cacheKey)
            .set({
          'recipeId': recipeId,
          'targetLang': targetLang,
          'translations': translations,
          'timestamp': FieldValue.serverTimestamp(),
        });
        LoggerService.debug('Translation saved to Firestore: $cacheKey');
      } catch (e) {
        LoggerService.warning('Firestore cache write error: $e');
      }
    }

    // Save to local cache as backup
    await _saveToLocalCache(cacheKey, translations, now);
  }

  /// Get translated recipe fields if available.
  Future<RecipeTranslation?> getRecipeTranslation(String recipeId, String targetLang) async {
    final translations = await getTranslation(recipeId, targetLang);
    if (translations == null) return null;

    return RecipeTranslation(
      title: translations['title'],
      description: translations['description'],
      ingredients: translations['ingredients']?.split('|||'),
      instructions: translations['instructions']?.split('|||'),
    );
  }

  /// Save recipe translation.
  Future<void> saveRecipeTranslation(
    String recipeId,
    String targetLang,
    RecipeTranslation translation,
  ) async {
    final translations = <String, String>{};

    if (translation.title != null) {
      translations['title'] = translation.title!;
    }
    if (translation.description != null) {
      translations['description'] = translation.description!;
    }
    if (translation.ingredients != null) {
      translations['ingredients'] = translation.ingredients!.join('|||');
    }
    if (translation.instructions != null) {
      translations['instructions'] = translation.instructions!.join('|||');
    }

    await saveTranslation(recipeId, targetLang, translations);
  }

  /// Clear expired cache entries.
  Future<void> clearExpiredCache() async {
    // Clear memory cache
    _memoryCache?.removeWhere((_, v) => v.isExpired);

    // Clear local cache
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_cacheKey);
    if (cacheJson != null) {
      try {
        final cache = Map<String, dynamic>.from(jsonDecode(cacheJson));
        cache.removeWhere((key, value) {
          final timestamp = DateTime.parse(value['timestamp']);
          return DateTime.now().difference(timestamp) > _cacheExpiry;
        });
        await prefs.setString(_cacheKey, jsonEncode(cache));
      } catch (e) {
        LoggerService.warning('Cache cleanup error: $e');
      }
    }

    LoggerService.info('Translation cache cleaned');
  }

  /// Get cache statistics.
  Future<TranslationCacheStats> getStats() async {
    int memoryCount = _memoryCache?.length ?? 0;
    int localCount = 0;
    int firestoreCount = 0;

    final localCache = await _getLocalCache();
    localCount = localCache.length;

    if (FirebaseService.isAvailable) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('translation_cache')
            .count()
            .get();
        firestoreCount = snapshot.count ?? 0;
      } catch (e) {
        // Ignore
      }
    }

    return TranslationCacheStats(
      memoryEntries: memoryCount,
      localEntries: localCount,
      firestoreEntries: firestoreCount,
    );
  }

  Future<Map<String, CachedTranslation>> _getLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_cacheKey);
    if (cacheJson == null) return {};

    try {
      final cache = Map<String, dynamic>.from(jsonDecode(cacheJson));
      return cache.map((key, value) => MapEntry(
            key,
            CachedTranslation(
              translations: Map<String, String>.from(value['translations'] ?? {}),
              timestamp: DateTime.parse(value['timestamp']),
            ),
          ));
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveToLocalCache(
    String cacheKey,
    Map<String, String> translations,
    DateTime now,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cache = await _getLocalCache();

      cache[cacheKey] = CachedTranslation(
        translations: translations,
        timestamp: now,
      );

      final cacheMap = cache.map((key, value) => MapEntry(
            key,
            {
              'translations': value.translations,
              'timestamp': value.timestamp.toIso8601String(),
            },
          ));

      await prefs.setString(_cacheKey, jsonEncode(cacheMap));
    } catch (e) {
      LoggerService.warning('Local cache write error: $e');
    }
  }
}

/// Cached translation entry.
class CachedTranslation {
  final Map<String, String> translations;
  final DateTime timestamp;

  CachedTranslation({
    required this.translations,
    required this.timestamp,
  });

  bool get isExpired =>
      DateTime.now().difference(timestamp) > const Duration(days: 30);
}

/// Recipe translation data.
class RecipeTranslation {
  final String? title;
  final String? description;
  final List<String>? ingredients;
  final List<String>? instructions;

  RecipeTranslation({
    this.title,
    this.description,
    this.ingredients,
    this.instructions,
  });
}

/// Translation cache statistics.
class TranslationCacheStats {
  final int memoryEntries;
  final int localEntries;
  final int firestoreEntries;

  TranslationCacheStats({
    required this.memoryEntries,
    required this.localEntries,
    required this.firestoreEntries,
  });

  int get totalEntries => memoryEntries + localEntries + firestoreEntries;
}
