import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe_comment.dart';
import 'firebase_service.dart';
import 'analytics_service.dart';
import 'gamification_service.dart';

/// Service for managing recipe comments and ratings.
class CommentService {
  static final CommentService _instance = CommentService._internal();
  factory CommentService() => _instance;
  CommentService._internal();

  final AnalyticsService _analytics = AnalyticsService();

  /// Add a comment to a recipe.
  Future<RecipeComment?> addComment({
    required String recipeId,
    required int rating,
    required String text,
    List<String>? imageUrls,
  }) async {
    if (!FirebaseService.isAvailable) return null;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    try {
      final comment = RecipeComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recipeId: recipeId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Anonim',
        userAvatar: currentUser.photoURL,
        rating: rating,
        text: text,
        images: imageUrls ?? [],
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .collection('comments')
          .doc(comment.id)
          .set(comment.toJson());

      // Update recipe rating
      await _updateRecipeRating(recipeId);

      // Award XP for commenting
      await GamificationService().addXP(15, reason: 'comment_added');

      await _analytics.logEvent('comment_added', {
        'recipe_id': recipeId,
        'rating': rating,
      });

      return comment;
    } catch (e) {
      print('[CommentService] Add comment error: $e');
      return null;
    }
  }

  /// Get comments for a recipe.
  Future<List<RecipeComment>> getComments(String recipeId, {int limit = 20}) async {
    if (!FirebaseService.isAvailable) {
      return _getMockComments(recipeId);
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => RecipeComment.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('[CommentService] Get comments error: $e');
      return _getMockComments(recipeId);
    }
  }

  /// Get recipe rating.
  Future<RecipeRating> getRecipeRating(String recipeId) async {
    if (!FirebaseService.isAvailable) {
      return RecipeRating(
        recipeId: recipeId,
        averageRating: 4.5,
        totalRatings: 128,
        ratingDistribution: {1: 2, 2: 5, 3: 15, 4: 42, 5: 64},
      );
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .get();

      if (!doc.exists) return RecipeRating.empty(recipeId);

      final data = doc.data();
      return RecipeRating(
        recipeId: recipeId,
        averageRating: (data?['averageRating'] ?? 0).toDouble(),
        totalRatings: data?['totalRatings'] ?? 0,
        ratingDistribution: Map<int, int>.from(
            data?['ratingDistribution'] ?? {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}),
      );
    } catch (e) {
      return RecipeRating.empty(recipeId);
    }
  }

  /// Mark a comment as helpful.
  Future<void> markHelpful(String recipeId, String commentId) async {
    if (!FirebaseService.isAvailable) return;

    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .collection('comments')
          .doc(commentId)
          .update({'helpfulCount': FieldValue.increment(1)});
    } catch (e) {
      print('[CommentService] Mark helpful error: $e');
    }
  }

  /// Delete own comment.
  Future<bool> deleteComment(String recipeId, String commentId) async {
    if (!FirebaseService.isAvailable) return false;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .collection('comments')
          .doc(commentId)
          .get();

      if (doc.data()?['userId'] != currentUser.uid) return false;

      await doc.reference.delete();
      await _updateRecipeRating(recipeId);

      return true;
    } catch (e) {
      print('[CommentService] Delete comment error: $e');
      return false;
    }
  }

  /// Update recipe's average rating.
  Future<void> _updateRecipeRating(String recipeId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .collection('comments')
          .get();

      if (snapshot.docs.isEmpty) return;

      final ratings = snapshot.docs
          .map((doc) => doc.data()['rating'] as int)
          .toList();

      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final r in ratings) {
        distribution[r] = (distribution[r] ?? 0) + 1;
      }

      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .update({
        'averageRating': avg,
        'totalRatings': ratings.length,
        'ratingDistribution': distribution,
      });
    } catch (e) {
      print('[CommentService] Update rating error: $e');
    }
  }

  List<RecipeComment> _getMockComments(String recipeId) {
    return [
      RecipeComment(
        id: '1',
        recipeId: recipeId,
        userId: 'user1',
        userName: 'Ayşe Hanım',
        rating: 5,
        text: 'Harika bir tarif! Ailem çok beğendi. Kesinlikle tekrar yapacağım. 🎉',
        helpfulCount: 24,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RecipeComment(
        id: '2',
        recipeId: recipeId,
        userId: 'user2',
        userName: 'Mehmet Bey',
        rating: 4,
        text: 'Güzel bir tarif ama bence biraz daha tuz eklenebilir.',
        helpfulCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      RecipeComment(
        id: '3',
        recipeId: recipeId,
        userId: 'user3',
        userName: 'Zeynep',
        rating: 5,
        text: 'En sevdiğim tarif oldu! 😍',
        helpfulCount: 15,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
