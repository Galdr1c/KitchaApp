import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'firebase_service.dart';
import 'analytics_service.dart';

/// Service for social features - following, activity feed, etc.
class SocialService {
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  final AnalyticsService _analytics = AnalyticsService();

  /// Follow a user.
  Future<bool> followUser(String targetUserId) async {
    if (!FirebaseService.isAvailable) return false;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId == targetUserId) return false;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Add to current user's following
      batch.set(
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId),
        {'followedAt': FieldValue.serverTimestamp()},
      );

      // Add to target user's followers
      batch.set(
        FirebaseFirestore.instance
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId),
        {'followedAt': FieldValue.serverTimestamp()},
      );

      // Update counts
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(currentUserId),
        {'followingCount': FieldValue.increment(1)},
      );
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(targetUserId),
        {'followerCount': FieldValue.increment(1)},
      );

      await batch.commit();
      await _analytics.logEvent('user_followed', {'target': targetUserId});

      return true;
    } catch (e) {
      print('[SocialService] Follow error: $e');
      return false;
    }
  }

  /// Unfollow a user.
  Future<bool> unfollowUser(String targetUserId) async {
    if (!FirebaseService.isAvailable) return false;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return false;

    try {
      final batch = FirebaseFirestore.instance.batch();

      batch.delete(
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId),
      );

      batch.delete(
        FirebaseFirestore.instance
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId),
      );

      batch.update(
        FirebaseFirestore.instance.collection('users').doc(currentUserId),
        {'followingCount': FieldValue.increment(-1)},
      );
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(targetUserId),
        {'followerCount': FieldValue.increment(-1)},
      );

      await batch.commit();
      return true;
    } catch (e) {
      print('[SocialService] Unfollow error: $e');
      return false;
    }
  }

  /// Check if following a user.
  Future<bool> isFollowing(String targetUserId) async {
    if (!FirebaseService.isAvailable) return false;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return false;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get user's followers count.
  Future<int> getFollowersCount(String userId) async {
    if (!FirebaseService.isAvailable) return 0;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return doc.data()?['followerCount'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get user's following count.
  Future<int> getFollowingCount(String userId) async {
    if (!FirebaseService.isAvailable) return 0;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return doc.data()?['followingCount'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get activity feed.
  Future<List<ActivityItem>> getActivityFeed({int limit = 20}) async {
    // In production, fetch from Firestore based on following list
    // For now, return mock data
    return [
      ActivityItem(
        id: '1',
        type: ActivityType.newRecipe,
        userId: 'user1',
        userName: 'Ahmet Şef',
        message: 'yeni bir tarif paylaştı',
        recipeId: 'recipe1',
        recipeName: 'Mantı',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ActivityItem(
        id: '2',
        type: ActivityType.favorited,
        userId: 'user2',
        userName: 'Ayşe Mutfak',
        message: 'bir tarifi favorilere ekledi',
        recipeId: 'recipe2',
        recipeName: 'Karnıyarık',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ActivityItem(
        id: '3',
        type: ActivityType.badgeEarned,
        userId: 'user3',
        userName: 'Mehmet',
        message: '"Gurme" rozetini kazandı',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Post activity (for internal use).
  Future<void> postActivity(ActivityType type, Map<String, dynamic> data) async {
    if (!FirebaseService.isAvailable) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      await FirebaseFirestore.instance.collection('activities').add({
        'userId': currentUserId,
        'type': type.name,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('[SocialService] Post activity error: $e');
    }
  }
}

/// Activity item model.
class ActivityItem {
  final String id;
  final ActivityType type;
  final String userId;
  final String userName;
  final String message;
  final String? recipeId;
  final String? recipeName;
  final String? imageUrl;
  final DateTime timestamp;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    required this.message,
    this.recipeId,
    this.recipeName,
    this.imageUrl,
    required this.timestamp,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays}g önce';
    if (diff.inHours > 0) return '${diff.inHours}s önce';
    if (diff.inMinutes > 0) return '${diff.inMinutes}d önce';
    return 'Şimdi';
  }
}

/// Activity types.
enum ActivityType {
  newRecipe,
  favorited,
  cooked,
  badgeEarned,
  levelUp,
  followed,
  commented,
}
