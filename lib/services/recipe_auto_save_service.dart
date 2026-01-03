import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kitcha_recipe.dart';
import 'firebase_service.dart';
import 'logger_service.dart';

/// Service for automatically saving searched/fetched recipes to our database.
class RecipeAutoSaveService {
  static final RecipeAutoSaveService _instance = RecipeAutoSaveService._internal();
  factory RecipeAutoSaveService() => _instance;
  RecipeAutoSaveService._internal();

  static const String _collection = 'kitcha_recipes';

  /// Save a recipe from external API to our database.
  Future<void> saveFromAPI(Map<String, dynamic> apiRecipe, String source) async {
    if (!FirebaseService.isAvailable) return;

    try {
      final recipeId = 'ext_${source}_${apiRecipe['id'] ?? apiRecipe['idMeal'] ?? DateTime.now().millisecondsSinceEpoch}';

      // Check if already exists
      final existing = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(recipeId)
          .get();

      if (existing.exists) {
        LoggerService.debug('Recipe already in database: $recipeId');
        return;
      }

      // Convert API format to our format
      final recipe = _convertFromAPI(apiRecipe, source, recipeId);

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(recipeId)
          .set(recipe.toJson());

      LoggerService.info('Recipe saved to database: ${recipe.titleTR}');
    } catch (e) {
      LoggerService.warning('Failed to save recipe: $e');
    }
  }

  /// Save multiple recipes from API.
  Future<void> saveMultipleFromAPI(List<Map<String, dynamic>> recipes, String source) async {
    for (final recipe in recipes) {
      await saveFromAPI(recipe, source);
    }
  }

  /// Convert TheMealDB format to KitchaRecipe.
  KitchaRecipe _convertFromAPI(Map<String, dynamic> api, String source, String recipeId) {
    if (source == 'themealdb') {
      return _convertFromTheMealDB(api, recipeId);
    } else if (source == 'spoonacular') {
      return _convertFromSpoonacular(api, recipeId);
    }
    return _convertGeneric(api, recipeId);
  }

  KitchaRecipe _convertFromTheMealDB(Map<String, dynamic> meal, String recipeId) {
    // Extract ingredients
    final ingredients = <RecipeIngredient>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(RecipeIngredient(
          name: ingredient.toString().trim(),
          quantity: measure?.toString().trim(),
        ));
      }
    }

    // Extract instructions
    final instructionsText = meal['strInstructions'] ?? '';
    final instructions = instructionsText
        .toString()
        .split(RegExp(r'\r?\n'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return KitchaRecipe(
      id: recipeId,
      titleTR: meal['strMeal'] ?? 'Bilinmeyen Tarif',
      titleEN: meal['strMeal'],
      descriptionTR: 'TheMealDB\'den alınan tarif',
      category: _mapCategory(meal['strCategory']),
      difficulty: 'Orta',
      prepTime: 20,
      cookTime: 30,
      servings: 4,
      calories: _estimateCalories(ingredients.length),
      ingredients: ingredients,
      instructionsTR: instructions,
      instructionsEN: instructions,
      imageUrl: meal['strMealThumb'],
      tags: [
        meal['strCategory'] ?? '',
        meal['strArea'] ?? '',
      ].where((s) => s.isNotEmpty).toList(),
      createdAt: DateTime.now(),
    );
  }

  KitchaRecipe _convertFromSpoonacular(Map<String, dynamic> api, String recipeId) {
    final ingredients = (api['extendedIngredients'] as List<dynamic>?)
            ?.map((i) => RecipeIngredient(
                  name: i['name'] ?? '',
                  quantity: i['amount']?.toString(),
                  unit: i['unit'],
                ))
            .toList() ??
        [];

    return KitchaRecipe(
      id: recipeId,
      titleTR: api['title'] ?? 'Bilinmeyen Tarif',
      titleEN: api['title'],
      descriptionTR: api['summary']?.replaceAll(RegExp(r'<[^>]*>'), ''),
      category: 'Ana Yemek',
      difficulty: 'Orta',
      prepTime: api['preparationMinutes'] ?? 15,
      cookTime: api['cookingMinutes'] ?? 30,
      servings: api['servings'] ?? 4,
      calories: (api['nutrition']?['nutrients'] as List<dynamic>?)
              ?.firstWhere((n) => n['name'] == 'Calories', orElse: () => {'amount': 0})['amount']
              ?.toInt() ??
          0,
      ingredients: ingredients,
      instructionsTR: (api['analyzedInstructions'] as List<dynamic>?)
              ?.expand((i) => (i['steps'] as List<dynamic>?)?.map((s) => s['step'].toString()) ?? [])
              .toList() ??
          [],
      imageUrl: api['image'],
      tags: (api['dishTypes'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.now(),
    );
  }

  KitchaRecipe _convertGeneric(Map<String, dynamic> api, String recipeId) {
    return KitchaRecipe(
      id: recipeId,
      titleTR: api['title'] ?? api['name'] ?? 'Bilinmeyen Tarif',
      category: 'Ana Yemek',
      difficulty: 'Orta',
      prepTime: 20,
      cookTime: 30,
      servings: 4,
      calories: 0,
      ingredients: [],
      instructionsTR: [],
      tags: [],
      createdAt: DateTime.now(),
    );
  }

  String _mapCategory(String? apiCategory) {
    final categoryMap = {
      'Beef': 'Et Yemekleri',
      'Chicken': 'Tavuk Yemekleri',
      'Seafood': 'Deniz Ürünleri',
      'Vegetarian': 'Sebze Yemekleri',
      'Vegan': 'Vegan',
      'Pasta': 'Makarna',
      'Dessert': 'Tatlı',
      'Breakfast': 'Kahvaltı',
      'Side': 'Aperatif',
      'Starter': 'Aperatif',
      'Soup': 'Çorba',
    };
    return categoryMap[apiCategory] ?? 'Ana Yemek';
  }

  int _estimateCalories(int ingredientCount) {
    // Rough estimate based on ingredient count
    return 200 + (ingredientCount * 30);
  }
}
