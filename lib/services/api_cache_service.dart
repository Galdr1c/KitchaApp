import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for caching API responses using SharedPreferences.
/// Provides time-based expiration for different data types.
class ApiCacheService {
  static final ApiCacheService _instance = ApiCacheService._internal();
  factory ApiCacheService() => _instance;
  ApiCacheService._internal();

  static const String _recipeCachePrefix = 'cache_recipe_';
  static const String _nutritionCachePrefix = 'cache_nutrition_';
  static const String _searchCachePrefix = 'cache_search_';

  // Cache durations
  static const int _recipeCacheHours = 24;
  static const int _nutritionCacheDays = 7;
  static const int _searchCacheHours = 6;

  /// Cache a recipe with 24-hour expiration.
  Future<void> cacheRecipe(String id, Map<String, dynamic> data) async {
    await _setCache('$_recipeCachePrefix$id', data, hours: _recipeCacheHours);
  }

  /// Get a cached recipe if not expired.
  Future<Map<String, dynamic>?> getRecipe(String id) async {
    return await _getCache('$_recipeCachePrefix$id', hours: _recipeCacheHours);
  }

  /// Cache nutrition data with 7-day expiration.
  Future<void> cacheNutrition(String key, Map<String, dynamic> data) async {
    await _setCache('$_nutritionCachePrefix$key', data, days: _nutritionCacheDays);
  }

  /// Get cached nutrition data if not expired.
  Future<Map<String, dynamic>?> getNutrition(String key) async {
    return await _getCache('$_nutritionCachePrefix$key', days: _nutritionCacheDays);
  }

  /// Cache search results with 6-hour expiration.
  Future<void> cacheSearchResults(String query, List<Map<String, dynamic>> results) async {
    await _setCache('$_searchCachePrefix$query', {'results': results}, hours: _searchCacheHours);
  }

  /// Get cached search results if not expired.
  Future<List<Map<String, dynamic>>?> getSearchResults(String query) async {
    final cached = await _getCache('$_searchCachePrefix$query', hours: _searchCacheHours);
    if (cached != null && cached['results'] != null) {
      return List<Map<String, dynamic>>.from(cached['results']);
    }
    return null;
  }

  /// Internal method to set cache with timestamp.
  Future<void> _setCache(String key, Map<String, dynamic> data, {int? hours, int? days}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(key, jsonEncode(cacheData));
  }

  /// Internal method to get cache and check expiration.
  Future<Map<String, dynamic>?> _getCache(String key, {int? hours, int? days}) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(key);

    if (cachedString == null) return null;

    try {
      final cached = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cached['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Calculate max age in milliseconds
      int maxAgeMs = 0;
      if (hours != null) {
        maxAgeMs = hours * 60 * 60 * 1000;
      } else if (days != null) {
        maxAgeMs = days * 24 * 60 * 60 * 1000;
      }

      // Check if expired
      if (now - timestamp > maxAgeMs) {
        await prefs.remove(key);
        return null;
      }

      return cached['data'] as Map<String, dynamic>;
    } catch (e) {
      print('[ApiCacheService] Error reading cache: $e');
      await prefs.remove(key);
      return null;
    }
  }

  /// Clear all cached data.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('cache_')) {
        await prefs.remove(key);
      }
    }
    print('[ApiCacheService] Cleared all cache');
  }

  /// Clear expired cache entries.
  Future<int> clearExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
    int cleared = 0;

    for (final key in keys) {
      final cachedString = prefs.getString(key);
      if (cachedString == null) continue;

      try {
        final cached = jsonDecode(cachedString) as Map<String, dynamic>;
        final timestamp = cached['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;

        // Determine cache type and max age
        int maxAgeMs;
        if (key.startsWith(_recipeCachePrefix)) {
          maxAgeMs = _recipeCacheHours * 60 * 60 * 1000;
        } else if (key.startsWith(_nutritionCachePrefix)) {
          maxAgeMs = _nutritionCacheDays * 24 * 60 * 60 * 1000;
        } else if (key.startsWith(_searchCachePrefix)) {
          maxAgeMs = _searchCacheHours * 60 * 60 * 1000;
        } else {
          maxAgeMs = 24 * 60 * 60 * 1000; // Default 24 hours
        }

        if (now - timestamp > maxAgeMs) {
          await prefs.remove(key);
          cleared++;
        }
      } catch (e) {
        await prefs.remove(key);
        cleared++;
      }
    }

    print('[ApiCacheService] Cleared $cleared expired entries');
    return cleared;
  }

  /// Get cache statistics.
  Future<Map<String, int>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    int recipes = 0;
    int nutrition = 0;
    int search = 0;

    for (final key in keys) {
      if (key.startsWith(_recipeCachePrefix)) recipes++;
      if (key.startsWith(_nutritionCachePrefix)) nutrition++;
      if (key.startsWith(_searchCachePrefix)) search++;
    }

    return {
      'recipes': recipes,
      'nutrition': nutrition,
      'search': search,
      'total': recipes + nutrition + search,
    };
  }
}
