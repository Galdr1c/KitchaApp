import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../screens/premium_screen.dart';
import '../widgets/login_bottom_sheet.dart';
import '../services/auth_service.dart';

/// Utility class to protect features that require login or premium subscription.
class ActionGuard {
  /// Protects an action that requires user login.
  /// Shows a login bottom sheet if user is not logged in.
  static Future<void> protect(
    BuildContext context,
    VoidCallback callback, {
    String featureName = 'Bu özellik',
  }) async {
    final authService = AuthService();
    
    if (authService.currentUser != null || authService.isGuest) {
      // User is logged in or has explicitly chosen guest mode
      callback();
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => LoginBottomSheet(
          featureName: featureName,
        ),
      );
    }
  }

  /// Checks if user has premium subscription.
  /// Navigates to premium screen if not premium.
  /// Returns true if user is premium, false otherwise.
  static Future<bool> checkPremium(
    BuildContext context, {
    String featureName = 'Bu özellik',
  }) async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    
    if (subscriptionProvider.isPremium) {
      return true;
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );
      return false;
    }
  }

  /// Checks if user can perform a daily-limited action.
  /// For free users, enforces daily limits (e.g., 1 calorie analysis per day).
  static Future<bool> checkDailyLimit(
    BuildContext context,
    String actionKey,
    int freeLimit, {
    required int currentCount,
  }) async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    
    if (subscriptionProvider.isPremium) {
      return true;
    }

    if (currentCount < freeLimit) {
      return true;
    }

    // Show premium screen when limit reached
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    );
    return false;
  }
}
