import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/challenge.dart';
import 'analytics_service.dart';

/// Service for managing weekly challenges.
class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  static const String _challengesKey = 'weekly_challenges';
  static const String _weekStartKey = 'current_week_start';

  final AnalyticsService _analytics = AnalyticsService();

  /// Get current week's challenges.
  Future<List<Challenge>> getCurrentChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we need to refresh challenges for new week
    final currentWeekStart = WeeklyChallenges.getCurrentWeekStart();
    final savedWeekStart = prefs.getString(_weekStartKey);
    
    if (savedWeekStart != currentWeekStart.toIso8601String()) {
      // New week, generate new challenges
      await _generateNewChallenges(currentWeekStart);
    }

    // Load saved challenges
    final challengesJson = prefs.getString(_challengesKey);
    if (challengesJson == null) {
      return WeeklyChallenges.getForWeek(currentWeekStart);
    }

    try {
      final List<dynamic> decoded = jsonDecode(challengesJson);
      return decoded.map((json) => Challenge.fromJson(json)).toList();
    } catch (e) {
      print('[ChallengeService] Error loading challenges: $e');
      return WeeklyChallenges.getForWeek(currentWeekStart);
    }
  }

  /// Generate new challenges for the week.
  Future<void> _generateNewChallenges(DateTime weekStart) async {
    final prefs = await SharedPreferences.getInstance();
    final challenges = WeeklyChallenges.getForWeek(weekStart);
    
    await prefs.setString(_weekStartKey, weekStart.toIso8601String());
    await _saveChallenges(challenges);
  }

  /// Save challenges to storage.
  Future<void> _saveChallenges(List<Challenge> challenges) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(challenges.map((c) => c.toJson()).toList());
    await prefs.setString(_challengesKey, json);
  }

  /// Update progress for a challenge type.
  Future<Challenge?> updateProgress(ChallengeType type, {int increment = 1}) async {
    final challenges = await getCurrentChallenges();
    Challenge? completedChallenge;

    final updated = challenges.map((challenge) {
      if (challenge.type == type && !challenge.isCompleted) {
        final newCount = challenge.currentCount + increment;
        final isNowComplete = newCount >= challenge.targetCount;
        
        if (isNowComplete && !challenge.isCompleted) {
          completedChallenge = challenge.copyWith(
            currentCount: newCount,
            isCompleted: true,
          );
          return completedChallenge!;
        }
        
        return challenge.copyWith(currentCount: newCount);
      }
      return challenge;
    }).toList();

    await _saveChallenges(updated);

    if (completedChallenge != null) {
      await _analytics.logChallengeCompleted(completedChallenge!.id);
    }

    return completedChallenge;
  }

  /// Mark a challenge as claimed (XP received).
  Future<void> claimChallenge(String challengeId) async {
    final challenges = await getCurrentChallenges();
    
    // Already completed challenges are marked, this is for explicit claim UI
    await _saveChallenges(challenges);

    await _analytics.logEvent('challenge_claimed', {'challenge_id': challengeId});
  }

  /// Get total XP available from unclaimed completed challenges.
  Future<int> getUnclaimedXP() async {
    final challenges = await getCurrentChallenges();
    return challenges
        .where((c) => c.isCompleted)
        .fold(0, (sum, c) => sum + c.xpReward);
  }

  /// Get overall progress across all challenges.
  Future<double> getOverallProgress() async {
    final challenges = await getCurrentChallenges();
    if (challenges.isEmpty) return 0;
    
    final total = challenges.fold(0.0, (sum, c) => sum + c.progress) / challenges.length;
    return total;
  }

  /// Check if all challenges are completed.
  Future<bool> areAllCompleted() async {
    final challenges = await getCurrentChallenges();
    return challenges.every((c) => c.isCompleted);
  }
}
