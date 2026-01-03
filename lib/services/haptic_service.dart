import 'package:flutter/services.dart';

/// Service for haptic feedback throughout the app.
class HapticService {
  /// Light haptic feedback for subtle interactions.
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for standard interactions.
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for significant actions.
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection feedback for list/picker selections.
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Success feedback pattern.
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error feedback pattern.
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }

  /// Vibrate pattern for notifications.
  static Future<void> notification() async {
    await HapticFeedback.vibrate();
  }
}
