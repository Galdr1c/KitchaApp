import 'package:flutter/material.dart';
import '../services/revenue_cat_service.dart';
import '../services/analytics_service.dart';

/// Provider for subscription/premium status management.
class SubscriptionProvider extends ChangeNotifier {
  final RevenueCatService _revenueCat = RevenueCatService();
  final AnalyticsService _analytics = AnalyticsService();

  bool _isPremium = false;
  bool _isLoading = false;
  String _subscriptionType = 'free';
  String? _error;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String get subscriptionType => _subscriptionType;
  String? get error => _error;

  /// Initialize the subscription provider.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _revenueCat.initialize();
      await checkPremiumStatus();
    } catch (e) {
      _error = 'Abonelik durumu kontrol edilemedi: $e';
      print('[SubscriptionProvider] Initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check current premium status.
  Future<void> checkPremiumStatus() async {
    try {
      _isPremium = await _revenueCat.checkPremiumStatus();
      _subscriptionType = _isPremium ? 'premium' : 'free';
      _error = null;
    } catch (e) {
      _error = 'Abonelik durumu kontrol edilemedi: $e';
      print('[SubscriptionProvider] Error checking premium: $e');
    }
    notifyListeners();
  }

  /// Purchase monthly subscription.
  Future<bool> buyMonthly() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _analytics.logPremiumPaywallShown();
      
      final success = await _revenueCat.purchaseMonthly();
      if (success) {
        _isPremium = true;
        _subscriptionType = 'monthly';
        await _analytics.logSubscriptionPurchase('monthly', 39.99);
      }
      return success;
    } catch (e) {
      _error = 'Satın alma başarısız: $e';
      print('[SubscriptionProvider] Monthly purchase error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Purchase lifetime subscription.
  Future<bool> buyLifetime() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _analytics.logPremiumPaywallShown();
      
      final success = await _revenueCat.purchaseLifetime();
      if (success) {
        _isPremium = true;
        _subscriptionType = 'lifetime';
        await _analytics.logSubscriptionPurchase('lifetime', 299.99);
      }
      return success;
    } catch (e) {
      _error = 'Satın alma başarısız: $e';
      print('[SubscriptionProvider] Lifetime purchase error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restore previous purchases.
  Future<bool> restorePurchases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final restored = await _revenueCat.restorePurchases();
      if (restored) {
        _isPremium = true;
        await checkPremiumStatus();
      }
      return restored;
    } catch (e) {
      _error = 'Satın alımlar geri yüklenemedi: $e';
      print('[SubscriptionProvider] Restore error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear any errors.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
