import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing in-app review prompts.
/// Uses a cooldown period and minimum action count before prompting.
/// 
/// Note: Full implementation requires in_app_review package.
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  static const int _minActions = 10; // Minimum actions before asking
  static const int _cooldownDays = 30; // Don't ask again for 30 days

  /// Check conditions and maybe request a review.
  Future<void> maybeRequestReview() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if review is available (would use InAppReview.instance.isAvailable())
    // For now, we'll check our local conditions
    
    // Check last request date
    final lastRequest = prefs.getInt('last_review_request') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSince = (now - lastRequest) / (1000 * 60 * 60 * 24);

    if (daysSince < _cooldownDays) {
      print('[ReviewService] Cooldown not expired, skipping review request');
      return;
    }

    // Check user actions
    final actionCount = prefs.getInt('user_action_count') ?? 0;
    if (actionCount < _minActions) {
      print('[ReviewService] Not enough actions ($actionCount < $_minActions)');
      return;
    }

    // Request review
    // await InAppReview.instance.requestReview();
    print('[ReviewService] Requesting review...');

    // Save request date and reset action count
    await prefs.setInt('last_review_request', now);
    await prefs.setInt('user_action_count', 0);
  }

  /// Open the app's store listing.
  Future<void> openStoreListing() async {
    // await InAppReview.instance.openStoreListing(appStoreId: 'YOUR_APP_STORE_ID');
    print('[ReviewService] Opening store listing...');
  }

  /// Increment the user action count (call on important actions).
  Future<void> incrementActionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('user_action_count') ?? 0;
    await prefs.setInt('user_action_count', count + 1);
    print('[ReviewService] Action count incremented to ${count + 1}');
  }

  /// Get current action count.
  Future<int> getActionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_action_count') ?? 0;
  }

  /// Reset action count (useful for testing).
  Future<void> resetActionCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_action_count', 0);
  }

  /// Force reset cooldown (useful for testing).
  Future<void> resetCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_review_request');
  }
}
