import 'package:flutter/foundation.dart';

/// Google AdMob manager for banner and interstitial ads.
/// Uses test IDs in debug mode, production IDs in release.
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  bool _isInitialized = false;
  int _interstitialCounter = 0;

  // Test IDs (for development)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // Production IDs (replace with your actual IDs)
  static const String _prodBannerAdUnitId = 'YOUR_BANNER_AD_UNIT_ID';
  static const String _prodInterstitialAdUnitId = 'YOUR_INTERSTITIAL_AD_UNIT_ID';

  /// Get the appropriate banner ad unit ID based on build mode.
  String get bannerAdUnitId {
    return kDebugMode ? _testBannerAdUnitId : _prodBannerAdUnitId;
  }

  /// Get the appropriate interstitial ad unit ID based on build mode.
  String get interstitialAdUnitId {
    return kDebugMode ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;
  }

  /// Whether the AdManager is initialized.
  bool get isInitialized => _isInitialized;

  /// Initialize the Mobile Ads SDK.
  /// Note: Actual initialization requires google_mobile_ads package.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // MobileAds.instance.initialize() would be called here
      // when google_mobile_ads is added as a dependency
      _isInitialized = true;
      print('[AdManager] Initialized successfully');
    } catch (e) {
      print('[AdManager] Initialization failed: $e');
    }
  }

  /// Track recipe views and show interstitial after every 3 views.
  /// Returns true if an interstitial should be shown.
  bool shouldShowInterstitial() {
    _interstitialCounter++;
    return _interstitialCounter % 3 == 0;
  }

  /// Reset the interstitial counter.
  void resetInterstitialCounter() {
    _interstitialCounter = 0;
  }

  /// Check if ads should be shown based on premium status.
  bool shouldShowAds(bool isPremium) {
    return !isPremium;
  }

  /// Dispose of resources.
  void dispose() {
    _isInitialized = false;
    _interstitialCounter = 0;
  }
}

/// Placeholder for banner ad state management.
/// Full implementation requires google_mobile_ads package.
class BannerAdState {
  bool isLoaded = false;
  String? errorMessage;

  void reset() {
    isLoaded = false;
    errorMessage = null;
  }
}

/// Placeholder for interstitial ad state management.
/// Full implementation requires google_mobile_ads package.
class InterstitialAdState {
  bool isLoaded = false;
  bool isShowing = false;
  String? errorMessage;

  void reset() {
    isLoaded = false;
    isShowing = false;
    errorMessage = null;
  }
}
