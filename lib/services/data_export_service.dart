import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_service.dart';

/// Service for GDPR-compliant data export.
class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  factory DataExportService() => _instance;
  DataExportService._internal();

  /// Export all user data to JSON.
  Future<String> exportUserData() async {
    if (!FirebaseService.isAvailable) {
      return _getMockExportData();
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('Not logged in');
    }

    final data = <String, dynamic>{
      'exportDate': DateTime.now().toIso8601String(),
      'userId': userId,
    };

    final firestore = FirebaseFirestore.instance;

    try {
      // User profile
      final userDoc = await firestore.collection('users').doc(userId).get();
      data['profile'] = userDoc.data();

      // Shopping list
      final shoppingSnapshot = await firestore
          .collection('shopping_lists')
          .doc(userId)
          .collection('items')
          .get();
      data['shoppingList'] = shoppingSnapshot.docs
          .map((doc) => doc.data())
          .toList();

      // Favorites
      final favoritesSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
      data['favorites'] = favoritesSnapshot.docs
          .map((doc) => doc.data())
          .toList();

      // Meal plans
      final mealPlansSnapshot = await firestore
          .collection('meal_plans')
          .doc(userId)
          .collection('plans')
          .get();
      data['mealPlans'] = mealPlansSnapshot.docs
          .map((doc) => doc.data())
          .toList();

      // Analytics
      final analyticsSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .get();
      data['analytics'] = analyticsSnapshot.docs
          .map((doc) => doc.data())
          .toList();

      // Gamification
      data['gamification'] = userDoc.data()?['gamification'];

    } catch (e) {
      print('[DataExportService] Export error: $e');
    }

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Save export to file.
  Future<File> saveExportToFile() async {
    final jsonString = await exportUserData();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/kitcha_export_$timestamp.json');
    await file.writeAsString(jsonString);
    return file;
  }

  /// Get export file path.
  Future<String> getExportFilePath() async {
    final file = await saveExportToFile();
    return file.path;
  }

  String _getMockExportData() {
    final mockData = {
      'exportDate': DateTime.now().toIso8601String(),
      'userId': 'demo_user',
      'profile': {
        'displayName': 'Demo User',
        'email': 'demo@kitcha.app',
        'createdAt': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      },
      'shoppingList': [
        {'name': 'Domates', 'quantity': '2 kg', 'checked': false},
        {'name': 'Soğan', 'quantity': '1 kg', 'checked': true},
      ],
      'favorites': [
        {'recipeId': 'tr_001', 'title': 'İskender Kebap'},
        {'recipeId': 'tr_002', 'title': 'Menemen'},
      ],
      'gamification': {
        'totalXP': 1250,
        'level': 5,
        'currentStreak': 7,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(mockData);
  }
}
