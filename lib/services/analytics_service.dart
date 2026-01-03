import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_service.dart';

/// Firebase Analytics wrapper with predefined events.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? get _analytics =>
      FirebaseService.isAvailable ? FirebaseAnalytics.instance : null;

  FirebaseAnalyticsObserver? get observer =>
      _analytics != null ? FirebaseAnalyticsObserver(analytics: _analytics!) : null;

  /// Log a custom event with optional parameters.
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    if (_analytics == null) return;
    
    try {
      await _analytics!.logEvent(
        name: name,
        parameters: parameters?.map((key, value) => MapEntry(key, value)),
      );
    } catch (e) {
      print('[AnalyticsService] Error logging event: $e');
    }
  }

  /// Log when a recipe is viewed.
  Future<void> logRecipeView(String recipeId, String recipeName) async {
    await logEvent('recipe_viewed', {
      'recipe_id': recipeId,
      'recipe_name': recipeName,
    });
  }

  /// Log when a recipe is added to favorites.
  Future<void> logFavoriteAdd(String recipeId) async {
    await logEvent('favorite_added', {'recipe_id': recipeId});
  }

  /// Log when a recipe is removed from favorites.
  Future<void> logFavoriteRemove(String recipeId) async {
    await logEvent('favorite_removed', {'recipe_id': recipeId});
  }

  /// Log calorie calculation.
  Future<void> logCalorieCalculate(int calories) async {
    await logEvent('calorie_calculated', {'calories': calories});
  }

  /// Log when premium paywall is shown.
  Future<void> logPremiumPaywallShown() async {
    await logEvent('premium_paywall_shown', null);
  }

  /// Log subscription purchase.
  Future<void> logSubscriptionPurchase(String type, double price) async {
    await logEvent('subscription_purchased', {
      'subscription_type': type,
      'price': price,
    });
  }

  /// Log AI camera usage.
  Future<void> logAICameraUsed() async {
    await logEvent('ai_camera_used', null);
  }

  /// Log shopping list creation.
  Future<void> logShoppingListCreated(int itemCount) async {
    await logEvent('shopping_list_created', {'item_count': itemCount});
  }

  /// Log comment posted.
  Future<void> logCommentPosted(String recipeId) async {
    await logEvent('comment_posted', {'recipe_id': recipeId});
  }

  /// Log badge unlocked.
  Future<void> logBadgeUnlocked(String badgeId) async {
    await logEvent('badge_unlocked', {'badge_id': badgeId});
  }

  /// Log search performed.
  Future<void> logSearch(String query) async {
    await logEvent('search', {'search_term': query});
  }

  /// Log screen view.
  Future<void> logScreenView(String screenName) async {
    if (_analytics == null) return;
    
    try {
      await _analytics!.logScreenView(screenName: screenName);
    } catch (e) {
      print('[AnalyticsService] Error logging screen view: $e');
    }
  }

  /// Set user property.
  Future<void> setUserProperty(String name, String value) async {
    if (_analytics == null) return;
    
    try {
      await _analytics!.setUserProperty(name: name, value: value);
    } catch (e) {
      print('[AnalyticsService] Error setting user property: $e');
    }
  }

  /// Set user ID for analytics.
  Future<void> setUserId(String? userId) async {
    if (_analytics == null) return;
    
    try {
      await _analytics!.setUserId(id: userId);
    } catch (e) {
      print('[AnalyticsService] Error setting user ID: $e');
    }
  }
}
