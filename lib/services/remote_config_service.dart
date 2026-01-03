import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'firebase_service.dart';

/// Service for Firebase Remote Config and A/B testing.
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  FirebaseRemoteConfig? _remoteConfig;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize Remote Config with defaults.
  Future<void> initialize() async {
    if (_isInitialized || !FirebaseService.isAvailable) {
      return;
    }

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values
      await _remoteConfig!.setDefaults({
        'premium_monthly_price': 39.99,
        'premium_lifetime_price': 299.99,
        'free_daily_analysis_limit': 1,
        'paywall_button_color': '#FF6347',
        'show_referral_banner': false,
        'feature_flags': '{}',
        'ad_frequency': 3,
        'enable_snap_and_cook': false,
        'enable_social_feed': false,
        'enable_gamification': false,
        'min_app_version': '1.0.0',
      });

      await _remoteConfig!.fetchAndActivate();
      _isInitialized = true;
      print('[RemoteConfigService] Initialized successfully');
    } catch (e) {
      print('[RemoteConfigService] Initialization failed: $e');
    }
  }

  /// Get premium monthly subscription price.
  double getPremiumMonthlyPrice() {
    return _remoteConfig?.getDouble('premium_monthly_price') ?? 39.99;
  }

  /// Get premium lifetime subscription price.
  double getPremiumLifetimePrice() {
    return _remoteConfig?.getDouble('premium_lifetime_price') ?? 299.99;
  }

  /// Get the daily free analysis limit.
  int getFreeDailyAnalysisLimit() {
    return _remoteConfig?.getInt('free_daily_analysis_limit') ?? 1;
  }

  /// Get the paywall button color.
  Color getPaywallButtonColor() {
    final hex = _remoteConfig?.getString('paywall_button_color') ?? '#FF6347';
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFFF6347);
    }
  }

  /// Check if referral banner should be shown.
  bool shouldShowReferralBanner() {
    return _remoteConfig?.getBool('show_referral_banner') ?? false;
  }

  /// Get ad display frequency (show interstitial every N recipe views).
  int getAdFrequency() {
    return _remoteConfig?.getInt('ad_frequency') ?? 3;
  }

  /// Get all feature flags as a map.
  Map<String, bool> getFeatureFlags() {
    final jsonString = _remoteConfig?.getString('feature_flags') ?? '{}';
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return json.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      return {};
    }
  }

  /// Check if a specific feature is enabled.
  bool isFeatureEnabled(String featureName) {
    // Check direct remote config values first
    switch (featureName) {
      case 'snap_and_cook':
        return _remoteConfig?.getBool('enable_snap_and_cook') ?? false;
      case 'social_feed':
        return _remoteConfig?.getBool('enable_social_feed') ?? false;
      case 'gamification':
        return _remoteConfig?.getBool('enable_gamification') ?? false;
      default:
        // Check feature flags JSON
        final flags = getFeatureFlags();
        return flags[featureName] ?? false;
    }
  }

  /// Get minimum required app version.
  String getMinAppVersion() {
    return _remoteConfig?.getString('min_app_version') ?? '1.0.0';
  }

  /// Get a string value by key.
  String getString(String key, {String defaultValue = ''}) {
    return _remoteConfig?.getString(key) ?? defaultValue;
  }

  /// Get an int value by key.
  int getInt(String key, {int defaultValue = 0}) {
    return _remoteConfig?.getInt(key) ?? defaultValue;
  }

  /// Get a double value by key.
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _remoteConfig?.getDouble(key) ?? defaultValue;
  }

  /// Get a bool value by key.
  bool getBool(String key, {bool defaultValue = false}) {
    return _remoteConfig?.getBool(key) ?? defaultValue;
  }

  /// Force fetch and activate new config values.
  Future<bool> forceRefresh() async {
    if (_remoteConfig == null) return false;

    try {
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // Force fetch
      ));
      
      final updated = await _remoteConfig!.fetchAndActivate();
      print('[RemoteConfigService] Force refresh: $updated');
      return updated;
    } catch (e) {
      print('[RemoteConfigService] Force refresh failed: $e');
      return false;
    }
  }
}
