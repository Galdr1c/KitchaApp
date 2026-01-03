/// Client-side rate limiting utility.
/// Prevents rapid repeated API calls or user actions.
class RateLimiter {
  static final Map<String, DateTime> _lastCallTimes = {};

  /// Checks if an action can proceed based on cooldown period.
  /// Returns true if enough time has passed since the last call.
  static bool canProceed(
    String action, {
    Duration cooldown = const Duration(seconds: 1),
  }) {
    final now = DateTime.now();
    final lastCall = _lastCallTimes[action];

    if (lastCall == null || now.difference(lastCall) >= cooldown) {
      _lastCallTimes[action] = now;
      return true;
    }

    return false;
  }

  /// Resets the cooldown for a specific action.
  static void reset(String action) {
    _lastCallTimes.remove(action);
  }

  /// Clears all rate limiting data.
  static void clearAll() {
    _lastCallTimes.clear();
  }

  /// Gets remaining cooldown time for an action.
  /// Returns Duration.zero if no cooldown is active.
  static Duration getRemainingCooldown(
    String action, {
    Duration cooldown = const Duration(seconds: 1),
  }) {
    final lastCall = _lastCallTimes[action];
    if (lastCall == null) {
      return Duration.zero;
    }

    final elapsed = DateTime.now().difference(lastCall);
    if (elapsed >= cooldown) {
      return Duration.zero;
    }

    return cooldown - elapsed;
  }
}
