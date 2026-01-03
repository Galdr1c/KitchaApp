import 'remote_config_service.dart';

/// Service for managing feature flags.
/// Supports both remote configuration and local overrides for testing.
class FeatureFlagService {
  static final FeatureFlagService _instance = FeatureFlagService._internal();
  factory FeatureFlagService() => _instance;
  FeatureFlagService._internal();

  final RemoteConfigService _remoteConfig = RemoteConfigService();
  
  // Local overrides for testing and development
  final Map<String, bool> _localOverrides = {};

  /// Check if a feature is enabled.
  /// Local overrides take precedence over remote config.
  bool isEnabled(String featureName) {
    // Check local override first
    if (_localOverrides.containsKey(featureName)) {
      return _localOverrides[featureName]!;
    }

    // Check remote config
    return _remoteConfig.isFeatureEnabled(featureName);
  }

  /// Set a local override for testing.
  void setLocalOverride(String featureName, bool enabled) {
    _localOverrides[featureName] = enabled;
    print('[FeatureFlagService] Set override: $featureName = $enabled');
  }

  /// Remove a specific local override.
  void removeLocalOverride(String featureName) {
    _localOverrides.remove(featureName);
  }

  /// Clear all local overrides.
  void clearLocalOverrides() {
    _localOverrides.clear();
    print('[FeatureFlagService] Cleared all overrides');
  }

  /// Get all current feature states (including overrides).
  Map<String, bool> getAllFeatures() {
    final features = <String, bool>{};
    
    // Add known features from remote config
    for (final feature in Feature.values) {
      features[feature.key] = isEnabled(feature.key);
    }
    
    // Add any local overrides not in enum
    for (final entry in _localOverrides.entries) {
      features[entry.key] = entry.value;
    }
    
    return features;
  }

  /// Check multiple features at once.
  Map<String, bool> checkFeatures(List<String> featureNames) {
    return Map.fromEntries(
      featureNames.map((name) => MapEntry(name, isEnabled(name))),
    );
  }
}

/// Known feature flags.
enum Feature {
  snapAndCook('snap_and_cook'),
  socialFeed('social_feed'),
  referralSystem('referral_system'),
  seasonalThemes('seasonal_themes'),
  advancedSearch('advanced_search'),
  weeklyReview('weekly_review'),
  gamification('gamification'),
  aiRecommendations('ai_recommendations'),
  mealPlanner('meal_planner'),
  shoppingList('shopping_list');

  final String key;
  const Feature(this.key);
}

/// Extension for convenient feature checking.
extension FeatureExtension on Feature {
  bool get isEnabled => FeatureFlagService().isEnabled(key);
}
