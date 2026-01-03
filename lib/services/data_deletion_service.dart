import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_service.dart';
import 'analytics_service.dart';

/// Service for GDPR-compliant data deletion.
class DataDeletionService {
  static final DataDeletionService _instance = DataDeletionService._internal();
  factory DataDeletionService() => _instance;
  DataDeletionService._internal();

  /// Delete all user data (GDPR compliance).
  Future<void> deleteAllUserData() async {
    if (!FirebaseService.isAvailable) {
      throw Exception('Firebase not available');
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('Not logged in');
    }

    try {
      // 1. Delete Firestore data
      await _deleteFirestoreData(userId);

      // 2. Delete Storage files
      await _deleteStorageFiles(userId);

      // 3. Anonymize analytics
      await _anonymizeAnalytics();

      // 4. Delete auth account
      await FirebaseAuth.instance.currentUser?.delete();

      print('[DataDeletionService] All user data deleted successfully');
    } catch (e) {
      print('[DataDeletionService] Error: $e');
      rethrow;
    }
  }

  Future<void> _deleteFirestoreData(String userId) async {
    final firestore = FirebaseFirestore.instance;

    // Delete main user document
    await firestore.collection('users').doc(userId).delete();

    // Delete shopping list items
    await _deleteCollection(
      firestore.collection('shopping_lists').doc(userId).collection('items'),
    );

    // Delete daily activity
    await _deleteCollection(
      firestore.collection('users').doc(userId).collection('daily_activity'),
    );

    // Delete analytics
    await _deleteCollection(
      firestore.collection('users').doc(userId).collection('analytics'),
    );

    // Delete meal plans
    await _deleteCollection(
      firestore.collection('meal_plans').doc(userId).collection('plans'),
    );

    // Delete user's comments
    final commentsSnapshot = await firestore
        .collectionGroup('comments')
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _deleteCollection(CollectionReference collection) async {
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _deleteStorageFiles(String userId) async {
    try {
      final storage = FirebaseStorage.instance;
      
      // Delete user images
      final userImagesRef = storage.ref().child('user_images/$userId');
      await _deleteStorageFolder(userImagesRef);

      // Delete comment images
      final commentImagesRef = storage.ref().child('comment_images/$userId');
      await _deleteStorageFolder(commentImagesRef);

      // Delete backups
      final backupsRef = storage.ref().child('backups/$userId');
      await _deleteStorageFolder(backupsRef);
    } catch (e) {
      print('[DataDeletionService] Error deleting storage: $e');
    }
  }

  Future<void> _deleteStorageFolder(Reference ref) async {
    try {
      final listResult = await ref.listAll();
      for (final item in listResult.items) {
        await item.delete();
      }
      for (final prefix in listResult.prefixes) {
        await _deleteStorageFolder(prefix);
      }
    } catch (e) {
      // Folder might not exist
    }
  }

  Future<void> _anonymizeAnalytics() async {
    await AnalyticsService().setUserId(null);
  }
}
