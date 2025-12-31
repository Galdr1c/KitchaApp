import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/error/app_exception.dart';

class MealPlannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _baseUrl = 'https://api.spoonacular.com/mealplanner/generate';

  Future<void> generateAndSaveMealPlan({
    required int targetCalories,
    String diet = '',
    String exclusions = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Kullanıcı girişi gerekli');

    try {
      final apiKey = dotenv.env['SPOONACULAR_API_KEY'];
      final uri = Uri.parse('$_baseUrl?timeFrame=week&targetCalories=$targetCalories&diet=$diet&exclude=$exclusions&apiKey=$apiKey');
      
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw AppException('Plan oluşturulamadı API: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      
      // Save to Firestore
      await _firestore.collection('meal_plans').doc(user.uid).set({
        'week': data['week'],
        'createdAt': FieldValue.serverTimestamp(),
        'settings': {
          'targetCalories': targetCalories,
          'diet': diet,
          'exclusions': exclusions,
        }
      });
      
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Yemek planı hatası: $e');
    }
  }

  Stream<DocumentSnapshot> getMyMealPlan() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore.collection('meal_plans').doc(user.uid).snapshots();
  }
}
