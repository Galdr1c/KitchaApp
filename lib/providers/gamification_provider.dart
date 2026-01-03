import 'package:flutter/material.dart';
import '../models/gamification_models.dart';
import '../services/gamification_service.dart';

/// Provider for gamification state management.
class GamificationProvider extends ChangeNotifier {
  final GamificationService _service = GamificationService();

  UserStats _stats = const UserStats();
  List<BadgeWithStatus> _badges = [];
  bool _isLoading = false;
  String? _error;

  // Recent XP gain for animation
  XPResult? _lastXPResult;
  List<Badge> _recentlyUnlockedBadges = [];

  UserStats get stats => _stats;
  List<BadgeWithStatus> get badges => _badges;
  bool get isLoading => _isLoading;
  String? get error => _error;
  XPResult? get lastXPResult => _lastXPResult;
  List<Badge> get recentlyUnlockedBadges => _recentlyUnlockedBadges;

  // Convenience getters
  int get totalXP => _stats.totalXP;
  int get level => _stats.level;
  int get streak => _stats.daysStreak;
  double get levelProgress => _stats.levelProgress;
  int get xpForNextLevel => _stats.xpForNextLevel;
  int get unlockedBadgeCount => _stats.unlockedBadgeIds.length;
  int get totalBadgeCount => Badges.all.length;

  /// Load user stats and badges.
  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _service.getUserStats();
      _badges = await _service.getAllBadgesWithStatus();
      _error = null;
    } catch (e) {
      _error = 'Oyun verileri yüklenemedi: $e';
      print('[GamificationProvider] Error loading stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Track daily login on app open.
  Future<void> trackDailyLogin() async {
    try {
      final result = await _service.trackDailyLogin();
      
      if (result.streakExtended) {
        // Reload stats to get updated streak
        await loadStats();
      }
    } catch (e) {
      print('[GamificationProvider] Error tracking login: $e');
    }
  }

  /// Track recipe view and add XP.
  Future<void> trackRecipeView({bool isPremium = false}) async {
    try {
      _lastXPResult = await _service.trackRecipeView(isPremium: isPremium);
      await loadStats();
      notifyListeners();
    } catch (e) {
      print('[GamificationProvider] Error tracking recipe view: $e');
    }
  }

  /// Track calorie analysis and add XP.
  Future<void> trackCalorieAnalysis({bool isPremium = false}) async {
    try {
      _lastXPResult = await _service.trackCalorieAnalysis(isPremium: isPremium);
      await loadStats();
      notifyListeners();
    } catch (e) {
      print('[GamificationProvider] Error tracking analysis: $e');
    }
  }

  /// Add XP for generic action.
  Future<void> addXP(XPAction action, {bool isPremium = false}) async {
    try {
      _lastXPResult = await _service.addXP(action, isPremium: isPremium);
      await loadStats();
      notifyListeners();
    } catch (e) {
      print('[GamificationProvider] Error adding XP: $e');
    }
  }

  /// Clear the last XP result (after animation).
  void clearLastXPResult() {
    _lastXPResult = null;
    notifyListeners();
  }

  /// Clear recently unlocked badges (after showing notification).
  void clearRecentlyUnlockedBadges() {
    _recentlyUnlockedBadges = [];
    notifyListeners();
  }

  /// Get level title.
  String getLevelTitle() {
    switch (_stats.level) {
      case 1:
        return 'Newbie Chef 👨‍🍳';
      case 2:
        return 'Home Cook 🏠';
      case 3:
        return 'Kitchen Pro 🔪';
      case 4:
        return 'Sous Chef 👨‍🍳';
      case 5:
        return 'Master Chef ⭐';
      case 6:
        return 'Gordon Ramsay 🔥';
      default:
        return 'Iron Chef 🏆';
    }
  }

  /// Get color for rarity.
  Color getRarityColor(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return const Color(0xFFCD7F32); // Bronze
      case BadgeRarity.rare:
        return const Color(0xFFC0C0C0); // Silver
      case BadgeRarity.epic:
        return const Color(0xFFFFD700); // Gold
      case BadgeRarity.legendary:
        return const Color(0xFFE5E4E2); // Platinum
    }
  }
}
