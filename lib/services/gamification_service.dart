import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamification_models.dart';
import 'firebase_service.dart';
import 'analytics_service.dart';

/// Service for managing gamification features (XP, badges, streaks).
class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final AnalyticsService _analytics = AnalyticsService();

  /// Get current user's stats.
  Future<UserStats> getUserStats() async {
    // Try Firebase first
    if (FirebaseService.isAvailable) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          
          if (doc.exists && doc.data()?['gamification'] != null) {
            return UserStats.fromJson(doc.data()!['gamification']);
          }
        } catch (e) {
          print('[GamificationService] Error loading from Firestore: $e');
        }
      }
    }

    // Fallback to local storage
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('user_stats');
    if (statsJson != null) {
      return UserStats.fromJson(jsonDecode(statsJson));
    }

    return const UserStats();
  }

  /// Save user stats.
  Future<void> _saveStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_stats', jsonEncode(stats.toJson()));

    // Sync to Firebase if available
    if (FirebaseService.isAvailable) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .set({
            'gamification': stats.toJson(),
          }, SetOptions(merge: true));
        } catch (e) {
          print('[GamificationService] Error saving to Firestore: $e');
        }
      }
    }
  }

  /// Add XP for an action.
  Future<XPResult> addXP(XPAction action, {bool isPremium = false}) async {
    final stats = await getUserStats();
    
    // Calculate XP (premium users get 50% bonus)
    int xpGained = action.xpValue;
    if (isPremium) {
      xpGained = (xpGained * 1.5).round();
    }

    final newXP = stats.totalXP + xpGained;
    final oldLevel = stats.level;
    final newLevel = UserStats.calculateLevel(newXP);
    final leveledUp = newLevel > oldLevel;

    final newStats = stats.copyWith(
      totalXP: newXP,
      level: newLevel,
    );

    await _saveStats(newStats);
    
    // Log analytics
    await _analytics.logEvent('xp_gained', {
      'action': action.name,
      'xp': xpGained,
      'total_xp': newXP,
    });

    return XPResult(
      xpGained: xpGained,
      totalXP: newXP,
      leveledUp: leveledUp,
      newLevel: newLevel,
    );
  }

  /// Track recipe view.
  Future<XPResult> trackRecipeView({bool isPremium = false}) async {
    final stats = await getUserStats();
    final newStats = stats.copyWith(
      recipesViewed: stats.recipesViewed + 1,
    );
    await _saveStats(newStats);

    // Check for badge unlocks
    await _checkBadgeUnlocks(newStats);

    return addXP(XPAction.viewRecipe, isPremium: isPremium);
  }

  /// Track calorie analysis.
  Future<XPResult> trackCalorieAnalysis({bool isPremium = false}) async {
    final stats = await getUserStats();
    final newStats = stats.copyWith(
      caloriesAnalyzed: stats.caloriesAnalyzed + 1,
    );
    await _saveStats(newStats);

    await _checkBadgeUnlocks(newStats);

    return addXP(XPAction.analyzeCalories, isPremium: isPremium);
  }

  /// Track daily login and update streak.
  Future<StreakResult> trackDailyLogin() async {
    final stats = await getUserStats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = stats.daysStreak;
    int newLongestStreak = stats.longestStreak;
    bool streakBroken = false;
    bool streakExtended = false;

    if (stats.lastActivityDate != null) {
      final lastActive = DateTime(
        stats.lastActivityDate!.year,
        stats.lastActivityDate!.month,
        stats.lastActivityDate!.day,
      );
      
      final daysDiff = today.difference(lastActive).inDays;

      if (daysDiff == 0) {
        // Same day, no change
      } else if (daysDiff == 1) {
        // Consecutive day
        newStreak = stats.daysStreak + 1;
        streakExtended = true;
        if (newStreak > newLongestStreak) {
          newLongestStreak = newStreak;
        }
      } else {
        // Streak broken
        streakBroken = true;
        newStreak = 1;
      }
    } else {
      // First login
      newStreak = 1;
    }

    final newStats = stats.copyWith(
      daysStreak: newStreak,
      longestStreak: newLongestStreak,
      lastActivityDate: now,
    );
    await _saveStats(newStats);

    // Add login XP
    if (streakExtended || stats.lastActivityDate == null) {
      await addXP(XPAction.dailyLogin);
    }

    // Check streak badges
    await _checkBadgeUnlocks(newStats);

    return StreakResult(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      streakExtended: streakExtended,
      streakBroken: streakBroken,
    );
  }

  /// Check and unlock badges based on current stats.
  Future<List<Badge>> _checkBadgeUnlocks(UserStats stats) async {
    final unlockedBadges = <Badge>[];

    for (final badge in Badges.all) {
      if (stats.unlockedBadgeIds.contains(badge.id)) {
        continue; // Already unlocked
      }

      bool shouldUnlock = false;

      switch (badge.category) {
        case BadgeCategory.recipes:
          shouldUnlock = stats.recipesViewed >= badge.requiredValue;
          break;
        case BadgeCategory.analysis:
          shouldUnlock = stats.caloriesAnalyzed >= badge.requiredValue;
          break;
        case BadgeCategory.streak:
          shouldUnlock = stats.daysStreak >= badge.requiredValue;
          break;
        default:
          break;
      }

      if (shouldUnlock) {
        await _unlockBadge(badge);
        unlockedBadges.add(badge);
      }
    }

    return unlockedBadges;
  }

  /// Unlock a badge.
  Future<void> _unlockBadge(Badge badge) async {
    final stats = await getUserStats();
    
    if (stats.unlockedBadgeIds.contains(badge.id)) {
      return; // Already unlocked
    }

    final newBadgeIds = [...stats.unlockedBadgeIds, badge.id];
    final newStats = stats.copyWith(
      unlockedBadgeIds: newBadgeIds,
      totalXP: stats.totalXP + badge.xpReward,
    );

    await _saveStats(newStats);

    // Log analytics
    await _analytics.logBadgeUnlocked(badge.id);
  }

  /// Get all badges with unlock status.
  Future<List<BadgeWithStatus>> getAllBadgesWithStatus() async {
    final stats = await getUserStats();

    return Badges.all.map((badge) {
      int currentValue = 0;
      
      switch (badge.category) {
        case BadgeCategory.recipes:
          currentValue = stats.recipesViewed;
          break;
        case BadgeCategory.analysis:
          currentValue = stats.caloriesAnalyzed;
          break;
        case BadgeCategory.streak:
          currentValue = stats.daysStreak;
          break;
        default:
          break;
      }

      return BadgeWithStatus(
        badge: badge,
        isUnlocked: stats.unlockedBadgeIds.contains(badge.id),
        currentValue: currentValue,
      );
    }).toList();
  }
}

/// Result of XP addition.
class XPResult {
  final int xpGained;
  final int totalXP;
  final bool leveledUp;
  final int newLevel;

  const XPResult({
    required this.xpGained,
    required this.totalXP,
    required this.leveledUp,
    required this.newLevel,
  });
}

/// Result of streak tracking.
class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final bool streakExtended;
  final bool streakBroken;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.streakExtended,
    required this.streakBroken,
  });
}

/// Badge with current unlock status.
class BadgeWithStatus {
  final Badge badge;
  final bool isUnlocked;
  final int currentValue;

  const BadgeWithStatus({
    required this.badge,
    required this.isUnlocked,
    required this.currentValue,
  });

  double get progress => (currentValue / badge.requiredValue).clamp(0.0, 1.0);
}
