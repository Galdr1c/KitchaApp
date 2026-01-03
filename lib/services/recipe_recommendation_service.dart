import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

/// Service for smart recipe recommendations.
class RecipeRecommendationService {
  static final RecipeRecommendationService _instance =
      RecipeRecommendationService._internal();
  factory RecipeRecommendationService() => _instance;
  RecipeRecommendationService._internal();

  static const String _historyKey = 'recipe_view_history';
  static const String _favoritesKey = 'favorite_recipes';

  /// Get personalized recommendations based on user behavior.
  Future<List<RecipeRecommendation>> getRecommendations({int limit = 10}) async {
    final history = await _getViewHistory();
    final favorites = await _getFavorites();
    
    final recommendations = <RecipeRecommendation>[];

    // Add time-based suggestions
    recommendations.addAll(_getTimeSuggestions());

    // Add category-based suggestions from history
    if (history.isNotEmpty) {
      recommendations.addAll(_getCategorySuggestions(history));
    }

    // Add seasonal suggestions
    recommendations.addAll(_getSeasonalSuggestions());

    // Add trending suggestions
    recommendations.addAll(_getTrendingSuggestions());

    return recommendations.take(limit).toList();
  }

  /// Get suggestions based on time of day.
  List<RecipeRecommendation> _getTimeSuggestions() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 10) {
      return [
        const RecipeRecommendation(
          type: RecommendationType.timeBased,
          title: '☕ Günaydın!',
          subtitle: 'Kahvaltı tarifleri',
          query: 'kahvaltı',
          icon: '🍳',
        ),
      ];
    } else if (hour >= 11 && hour < 14) {
      return [
        const RecipeRecommendation(
          type: RecommendationType.timeBased,
          title: '🍽️ Öğle Vakti',
          subtitle: 'Hızlı ve lezzetli',
          query: 'öğle yemeği',
          icon: '🥗',
        ),
      ];
    } else if (hour >= 17 && hour < 21) {
      return [
        const RecipeRecommendation(
          type: RecommendationType.timeBased,
          title: '🌙 Akşam Yemeği',
          subtitle: 'Aile için tarifler',
          query: 'akşam yemeği',
          icon: '🍲',
        ),
      ];
    } else if (hour >= 14 && hour < 17) {
      return [
        const RecipeRecommendation(
          type: RecommendationType.timeBased,
          title: '🍰 Tatlı Zamanı',
          subtitle: 'Hafif atıştırmalıklar',
          query: 'tatlı',
          icon: '🧁',
        ),
      ];
    }
    
    return [];
  }

  /// Get suggestions based on viewed categories.
  List<RecipeRecommendation> _getCategorySuggestions(List<String> history) {
    // Analyze most viewed categories (simplified)
    return [
      const RecipeRecommendation(
        type: RecommendationType.personalized,
        title: '❤️ Beğenebileceğin',
        subtitle: 'Geçmişine göre öneriler',
        query: 'popüler',
        icon: '⭐',
      ),
    ];
  }

  /// Get seasonal recipe suggestions.
  List<RecipeRecommendation> _getSeasonalSuggestions() {
    final month = DateTime.now().month;
    
    if (month >= 3 && month <= 5) {
      // Spring
      return [
        const RecipeRecommendation(
          type: RecommendationType.seasonal,
          title: '🌸 Bahar Lezzetleri',
          subtitle: 'Taze ve hafif',
          query: 'bahar',
          icon: '🥒',
        ),
      ];
    } else if (month >= 6 && month <= 8) {
      // Summer
      return [
        const RecipeRecommendation(
          type: RecommendationType.seasonal,
          title: '☀️ Yaz Tarifleri',
          subtitle: 'Serinleten lezzetler',
          query: 'yaz',
          icon: '🍉',
        ),
      ];
    } else if (month >= 9 && month <= 11) {
      // Autumn
      return [
        const RecipeRecommendation(
          type: RecommendationType.seasonal,
          title: '🍂 Sonbahar',
          subtitle: 'Sıcacık yemekler',
          query: 'sonbahar',
          icon: '🎃',
        ),
      ];
    } else {
      // Winter
      return [
        const RecipeRecommendation(
          type: RecommendationType.seasonal,
          title: '❄️ Kış Lezzetleri',
          subtitle: 'Isıtan tarifler',
          query: 'kış çorbası',
          icon: '🍜',
        ),
      ];
    }
  }

  /// Get trending recipes.
  List<RecipeRecommendation> _getTrendingSuggestions() {
    return [
      const RecipeRecommendation(
        type: RecommendationType.trending,
        title: '🔥 Trend Tarifler',
        subtitle: 'En çok arananlar',
        query: 'trend',
        icon: '📈',
      ),
    ];
  }

  /// Track recipe view for personalization.
  Future<void> trackRecipeView(String recipeId, String category) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey) ?? '[]';
    
    List<String> history;
    try {
      history = List<String>.from(jsonDecode(historyJson));
    } catch (_) {
      history = [];
    }

    history.insert(0, '$recipeId:$category');
    if (history.length > 100) {
      history = history.sublist(0, 100);
    }

    await prefs.setString(_historyKey, jsonEncode(history));
  }

  Future<List<String>> _getViewHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_historyKey) ?? '[]';
    
    try {
      return List<String>.from(jsonDecode(json));
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> _getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_favoritesKey) ?? '[]';
    
    try {
      return List<String>.from(jsonDecode(json));
    } catch (_) {
      return [];
    }
  }
}

/// Recipe recommendation model.
class RecipeRecommendation {
  final RecommendationType type;
  final String title;
  final String subtitle;
  final String query;
  final String icon;
  final String? recipeId;

  const RecipeRecommendation({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.query,
    required this.icon,
    this.recipeId,
  });
}

/// Types of recommendations.
enum RecommendationType {
  timeBased,
  personalized,
  seasonal,
  trending,
  similar,
}
