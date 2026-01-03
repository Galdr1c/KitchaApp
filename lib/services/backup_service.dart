import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_service.dart';
import 'data_export_service.dart';

/// Service for data backup and recovery.
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Backup user data to cloud storage.
  Future<void> backupToCloud() async {
    if (!FirebaseService.isAvailable) {
      print('[BackupService] Firebase not available');
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('Not logged in');
    }

    try {
      // Export data
      final jsonString = await DataExportService().exportUserData();

      // Upload to Firebase Storage
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final path = 'backups/$userId/$timestamp.json';
      final storageRef = FirebaseStorage.instance.ref().child(path);

      await storageRef.putString(jsonString);

      // Save backup metadata
      await FirebaseFirestore.instance
          .collection('backups')
          .doc(userId)
          .set({
        'lastBackup': FieldValue.serverTimestamp(),
        'backupPath': path,
        'backupCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      print('[BackupService] Backup created: $path');
    } catch (e) {
      print('[BackupService] Backup error: $e');
      rethrow;
    }
  }

  /// Restore from cloud backup.
  Future<void> restoreFromCloud() async {
    if (!FirebaseService.isAvailable) {
      throw Exception('Firebase not available');
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('Not logged in');
    }

    try {
      // Get backup metadata
      final backupDoc = await FirebaseFirestore.instance
          .collection('backups')
          .doc(userId)
          .get();

      if (!backupDoc.exists) {
        throw Exception('No backup found');
      }

      final backupPath = backupDoc.data()?['backupPath'];
      if (backupPath == null) {
        throw Exception('Invalid backup path');
      }

      // Download backup
      final storageRef = FirebaseStorage.instance.ref().child(backupPath);
      final data = await storageRef.getData();

      if (data == null) {
        throw Exception('Failed to download backup');
      }

      // Parse and restore
      final jsonData = jsonDecode(utf8.decode(data));
      await _restoreUserData(userId, jsonData);

      print('[BackupService] Restore completed');
    } catch (e) {
      print('[BackupService] Restore error: $e');
      rethrow;
    }
  }

  /// Get last backup date.
  Future<DateTime?> getLastBackupDate() async {
    if (!FirebaseService.isAvailable) return null;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('backups')
          .doc(userId)
          .get();

      final timestamp = doc.data()?['lastBackup'] as Timestamp?;
      return timestamp?.toDate();
    } catch (e) {
      return null;
    }
  }

  /// Check if backup exists.
  Future<bool> hasBackup() async {
    final lastBackup = await getLastBackupDate();
    return lastBackup != null;
  }

  Future<void> _restoreUserData(String userId, Map<String, dynamic> data) async {
    final firestore = FirebaseFirestore.instance;

    // Restore profile
    if (data['profile'] != null) {
      await firestore.collection('users').doc(userId).set(
        data['profile'],
        SetOptions(merge: true),
      );
    }

    // Restore shopping list
    if (data['shoppingList'] != null) {
      final batch = firestore.batch();
      for (final item in data['shoppingList']) {
        final docRef = firestore
            .collection('shopping_lists')
            .doc(userId)
            .collection('items')
            .doc(item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString());
        batch.set(docRef, item);
      }
      await batch.commit();
    }

    // Restore favorites
    if (data['favorites'] != null) {
      final batch = firestore.batch();
      for (final item in data['favorites']) {
        final docRef = firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(item['recipeId']);
        batch.set(docRef, item);
      }
      await batch.commit();
    }

    // Restore gamification
    if (data['gamification'] != null) {
      await firestore.collection('users').doc(userId).update({
        'gamification': data['gamification'],
      });
    }
  }

  /// Delete old backups (keep last 5).
  Future<void> cleanupOldBackups() async {
    if (!FirebaseService.isAvailable) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final storage = FirebaseStorage.instance;
      final backupsRef = storage.ref().child('backups/$userId');
      final listResult = await backupsRef.listAll();

      if (listResult.items.length > 5) {
        // Sort by name (timestamps) and delete oldest
        final items = listResult.items.toList();
        items.sort((a, b) => a.name.compareTo(b.name));

        for (int i = 0; i < items.length - 5; i++) {
          await items[i].delete();
          print('[BackupService] Deleted old backup: ${items[i].name}');
        }
      }
    } catch (e) {
      print('[BackupService] Cleanup error: $e');
    }
  }
}
