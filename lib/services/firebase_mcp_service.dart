import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/recipe.dart';
import '../repository/app_repository.dart';

/// Advanced Firebase service for sync, auth, storage and remote config
class FirebaseMcpService {
  static FirebaseMcpService _instance = FirebaseMcpService._internal();
  factory FirebaseMcpService() => _instance;
  FirebaseMcpService._internal();

  @visibleForTesting
  static set instance(FirebaseMcpService mock) => _instance = mock;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // --- Authentication ---

  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('[FirebaseMcpService] Anonymous sign in error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('[FirebaseMcpService] Email sign in error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('[FirebaseMcpService] Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- Firestore Sync Logic ---

  /// Sync all user data (Recipes, Analyses, Favorites)
  Future<void> syncUserData({Function(int current, int total)? onProgress}) async {
    if (!isAuthenticated) return;

    final userId = currentUser!.uid;
    final repository = AppRepository();

    // 1. Sync Favorites
    final localFavorites = await repository.getFavoriteRecipes();
    final remoteFavsSnapshot = await _firestore
        .collection('favorites')
        .doc(userId)
        .collection('recipes')
        .get();

    // Pull remote favorites not in local
    for (var doc in remoteFavsSnapshot.docs) {
      final data = doc.data();
      final recipeName = data['name'];
      final existsLocally = localFavorites.any((r) => r.name == recipeName);
      
      if (!existsLocally) {
        // Find existing recipe in local DB or placeholder
        final matches = await repository.searchRecipes(recipeName);
        if (matches.isNotEmpty) {
          await repository.toggleRecipeFavorite(matches.first.id!);
        }
      }
    }

    // 2. Sync Analyses
    final localAnalyses = await repository.getAllAnalyses();
    final remoteAnalysesSnapshot = await _firestore
        .collection('analyses')
        .where('userId', isEqualTo: userId)
        .get();

    final remoteAnalysesIds = remoteAnalysesSnapshot.docs.map((d) => d.id).toSet();
    
    // Upload local analyses missing from remote
    int count = 0;
    for (var analysis in localAnalyses) {
      // Logic to check if this specific analysis was uploaded (using a custom ID or timestamp)
      // For simplicity, we'll use a tag in metadata or just check paths
      final isRemote = remoteAnalysesSnapshot.docs.any((d) => d.data()['photo_path'] == analysis.photoPath);
      
      if (!isRemote) {
        await uploadAnalysis(analysis, analysis.photoPath);
        count++;
        if (onProgress != null) onProgress(count, localAnalyses.length);
      }
    }
    
    print('[FirebaseMcpService] Sync complete for user: $userId');
  }

  /// Upload a recipe to global collection
  Future<void> uploadRecipe(RecipeModel recipe) async {
    try {
      await _firestore.collection('recipes').add({
        ...recipe.toMap(),
        'userId': currentUser?.uid,
        'isPublic': true, // Models can be curated as public
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('[FirebaseMcpService] Recipe upload error: $e');
    }
  }

  /// Download new recipes since last sync
  Future<List<RecipeModel>> downloadRecipes(DateTime lastSyncTime) async {
    final snapshot = await _firestore
        .collection('recipes')
        .where('updatedAt', isGreaterThan: lastSyncTime)
        .get();

    return snapshot.docs.map((doc) => RecipeModel.fromMap({...doc.data(), 'id': null})).toList();
  }

  /// Upload analysis with photo to Storage
  Future<void> uploadAnalysis(AnalysisModel analysis, String imagePath) async {
    if (!isAuthenticated) return;
    
    try {
      String? downloadUrl;
      
      // 1. Upload file if it exists
      if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = _storage.ref().child('analyses/${currentUser!.uid}/$fileName');
        
        final uploadTask = await storageRef.putFile(File(imagePath));
        downloadUrl = await uploadTask.ref.getDownloadURL();
      }

      // 2. Save to Firestore
      await _firestore.collection('analyses').add({
        'userId': currentUser!.uid,
        'date': analysis.date,
        'photo_path': downloadUrl ?? imagePath,
        'foods': analysis.foods.map((f) => f.toMap()).toList(),
        'total_calories': analysis.totalCalories,
        'total_protein': analysis.totalProtein,
        'total_carbs': analysis.totalCarbs,
        'total_fat': analysis.totalFat,
        'notes': analysis.notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('[FirebaseMcpService] Analysis uploaded successfully');
    } catch (e) {
      print('[FirebaseMcpService] Analysis upload error: $e');
    }
  }

  // --- Remote Config ---

  Future<void> initRemoteConfig() async {
    try {
      await _remoteConfig.setDefaults({
        'enable_multi_model_vision': true,
        'ai_timeout_seconds': 10,
        'maintenance_mode': false,
      });
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('[FirebaseMcpService] Remote Config error: $e');
    }
  }

  bool get isMultiModelEnabled => _remoteConfig.getBool('enable_multi_model_vision');
  int get aiTimeoutSeconds => _remoteConfig.getInt('ai_timeout_seconds');

  // --- Global Settings ---

  Future<void> enableOfflineMode() async {
    try {
      await _firestore.enablePersistence();
      print('[FirebaseMcpService] Firestore offline persistence enabled');
    } catch (e) {
       print('[FirebaseMcpService] Persistence error: $e');
    }
  }

  // --- Analytics ---

  Future<void> logMcpCallSuccess(String serverName, String method) async {
    await _analytics.logEvent(
      name: 'mcp_call_success',
      parameters: {
        'server_name': serverName,
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logMcpCallFailure(String serverName, String method, String error) async {
    await _analytics.logEvent(
      name: 'mcp_call_failure',
      parameters: {
        'server_name': serverName,
        'method': method,
        'error': error.substring(0, error.length > 100 ? 100 : error.length),
      },
    );
  }

  Future<void> logFeatureUsed(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {'feature_name': featureName},
    );
  }

  Future<void> logAiModelUsed(String modelName) async {
    await _analytics.logEvent(
      name: 'ai_model_used',
      parameters: {'model_name': modelName},
    );
  }
}
