import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/year_in_review.dart';
import 'firebase_service.dart';

/// Service for tracking and generating user statistics.
class UserStatsService {
  static final UserStatsService _instance = UserStatsService._internal();
  factory UserStatsService() => _instance;
  UserStatsService._internal();

  /// Track a recipe view.
  Future<void> trackRecipeView(String recipeId, String category) async {
    await _incrementStat('recipesViewed');
    await _incrementCategoryStat(category);
  }

  /// Track a calorie analysis.
  Future<void> trackAnalysis(int calories) async {
    await _incrementStat('analyses');
    await _addCalories(calories);
  }

  /// Track a favorite add.
  Future<void> trackFavorite() async {
    await _incrementStat('favorites');
  }

  /// Generate Year in Review data.
  Future<YearInReviewData> generateYearInReview(int year) async {
    if (!FirebaseService.isAvailable) {
      return YearInReviewData.mock(year);
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return YearInReviewData.mock(year);
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc(year.toString())
          .get();

      if (!doc.exists) {
        return YearInReviewData.mock(year);
      }

      return YearInReviewData.fromJson({...doc.data()!, 'year': year});
    } catch (e) {
      print('[UserStatsService] Error generating review: $e');
      return YearInReviewData.mock(year);
    }
  }

  /// Check if user has enough data for Year in Review.
  Future<bool> hasEnoughDataForReview(int year) async {
    try {
      final data = await generateYearInReview(year);
      return data.totalRecipesViewed >= 10;
    } catch (e) {
      return false;
    }
  }

  /// Get current year stats summary.
  Future<Map<String, int>> getCurrentYearStats() async {
    final year = DateTime.now().year;
    final data = await generateYearInReview(year);
    
    return {
      'recipes': data.totalRecipesViewed,
      'favorites': data.totalFavorites,
      'analyses': data.totalAnalyses,
      'calories': data.totalCalories,
      'xp': data.xpGained,
      'badges': data.badgesEarned,
    };
  }

  Future<void> _incrementStat(String stat) async {
    if (!FirebaseService.isAvailable) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final year = DateTime.now().year;
    final month = DateTime.now().month;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc(year.toString())
          .set({
        'total${stat[0].toUpperCase()}${stat.substring(1)}': FieldValue.increment(1),
        'monthlyBreakdown.$month': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      print('[UserStatsService] Error incrementing stat: $e');
    }
  }

  Future<void> _incrementCategoryStat(String category) async {
    if (!FirebaseService.isAvailable) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final year = DateTime.now().year;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc(year.toString())
          .set({
        'categoryViews.$category': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      print('[UserStatsService] Error tracking category: $e');
    }
  }

  Future<void> _addCalories(int calories) async {
    if (!FirebaseService.isAvailable) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final year = DateTime.now().year;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc(year.toString())
          .set({
        'totalCalories': FieldValue.increment(calories),
      }, SetOptions(merge: true));
    } catch (e) {
      print('[UserStatsService] Error adding calories: $e');
    }
  }
}
