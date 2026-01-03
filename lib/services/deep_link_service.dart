import 'dart:async';
import 'package:flutter/material.dart';

/// Service for handling deep links in the app.
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  static const String scheme = 'kitcha';
  static const String host = 'app';

  StreamSubscription? _subscription;
  final StreamController<String> _linkController = StreamController.broadcast();

  /// Stream of deep links.
  Stream<String> get linkStream => _linkController.stream;

  /// Initialize deep link handling.
  void initialize(BuildContext context) {
    _handleInitialLink(context);
    // In production, use uni_links package:
    // _subscription = uriLinkStream.listen((Uri? uri) {
    //   if (uri != null) _handleLink(context, uri.toString());
    // });
  }

  Future<void> _handleInitialLink(BuildContext context) async {
    // In production, use uni_links package:
    // try {
    //   final initialLink = await getInitialLink();
    //   if (initialLink != null) _handleLink(context, initialLink);
    // } catch (e) {
    //   print('[DeepLinkService] Initial link error: $e');
    // }
  }

  /// Handle incoming deep link.
  void handleLink(BuildContext context, String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) return;

    print('[DeepLinkService] Handling: $link');

    if (uri.pathSegments.isEmpty) return;

    final resource = uri.pathSegments[0];

    switch (resource) {
      case 'recipe':
        if (uri.pathSegments.length > 1) {
          final recipeId = uri.pathSegments[1];
          _navigateToRecipe(context, recipeId);
        }
        break;
      case 'profile':
        if (uri.pathSegments.length > 1) {
          final userId = uri.pathSegments[1];
          _navigateToProfile(context, userId);
        }
        break;
      case 'premium':
        _navigateToPremium(context);
        break;
      case 'referral':
        if (uri.pathSegments.length > 1) {
          final code = uri.pathSegments[1];
          _handleReferralCode(context, code);
        }
        break;
      case 'challenge':
        _navigateToChallenges(context);
        break;
      default:
        print('[DeepLinkService] Unknown resource: $resource');
    }
  }

  void _navigateToRecipe(BuildContext context, String recipeId) {
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => RecipeDetailScreen(recipeId: recipeId),
    // ));
    print('[DeepLinkService] Navigate to recipe: $recipeId');
  }

  void _navigateToProfile(BuildContext context, String userId) {
    print('[DeepLinkService] Navigate to profile: $userId');
  }

  void _navigateToPremium(BuildContext context) {
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => PremiumScreen(),
    // ));
    print('[DeepLinkService] Navigate to premium');
  }

  void _handleReferralCode(BuildContext context, String code) {
    print('[DeepLinkService] Handle referral: $code');
  }

  void _navigateToChallenges(BuildContext context) {
    print('[DeepLinkService] Navigate to challenges');
  }

  /// Create recipe share link.
  static String createRecipeLink(String recipeId) {
    return '$scheme://$host/recipe/$recipeId';
  }

  /// Create profile share link.
  static String createProfileLink(String userId) {
    return '$scheme://$host/profile/$userId';
  }

  /// Create referral link.
  static String createReferralLink(String code) {
    return '$scheme://$host/referral/$code';
  }

  /// Create premium promo link.
  static String createPremiumLink() {
    return '$scheme://$host/premium';
  }

  void dispose() {
    _subscription?.cancel();
    _linkController.close();
  }
}
