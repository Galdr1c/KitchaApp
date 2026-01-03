import 'dart:io';
import '../models/detected_ingredient.dart';
import '../models/kitcha_recipe.dart';
import 'recipe_repository.dart';
import 'logger_service.dart';

/// Service for AI-based ingredient detection and recipe matching.
class IngredientDetectionService {
  static final IngredientDetectionService _instance = IngredientDetectionService._internal();
  factory IngredientDetectionService() => _instance;
  IngredientDetectionService._internal();

  final RecipeRepository _recipeRepo = RecipeRepository();

  /// Detect ingredients from image.
  /// In production, this would use ML Kit's ImageLabeler.
  Future<List<DetectedIngredient>> detectIngredients(File imageFile) async {
    LoggerService.info('Detecting ingredients from image: ${imageFile.path}');

    // In production, use ML Kit:
    // final inputImage = InputImage.fromFile(imageFile);
    // final labels = await _labeler.processImage(inputImage);
    // return labels.map((l) => DetectedIngredient.fromLabel(l.label, l.confidence)).toList();

    // Mock detection for demo
    await Future.delayed(const Duration(seconds: 1));
    
    return _getMockDetectedIngredients();
  }

  /// Find recipes that match the detected ingredients.
  Future<List<RecipeMatch>> findMatchingRecipes(
    List<DetectedIngredient> ingredients,
  ) async {
    final selectedIngredients = ingredients
        .where((i) => i.isSelected)
        .map((i) => i.displayName.toLowerCase())
        .toList();

    if (selectedIngredients.isEmpty) {
      return [];
    }

    LoggerService.info('Finding recipes for: $selectedIngredients');

    // Get all recipes
    final allRecipes = await _recipeRepo.getAllRecipes(limit: 100);

    // Score each recipe by ingredient match
    final matches = <RecipeMatch>[];

    for (final recipe in allRecipes) {
      final recipeIngredients = recipe.ingredients
          .map((i) => i.name.toLowerCase())
          .toList();

      int matchCount = 0;
      int missingCount = 0;
      final matchedIngredients = <String>[];
      final missingIngredients = <String>[];

      // Count matches
      for (final ingredient in selectedIngredients) {
        bool found = false;
        for (final recipeIng in recipeIngredients) {
          if (recipeIng.contains(ingredient) || ingredient.contains(recipeIng)) {
            matchCount++;
            matchedIngredients.add(recipeIng);
            found = true;
            break;
          }
        }
        if (!found) {
          missingCount++;
        }
      }

      // Find what's missing from recipe
      for (final recipeIng in recipeIngredients) {
        bool found = false;
        for (final ingredient in selectedIngredients) {
          if (recipeIng.contains(ingredient) || ingredient.contains(recipeIng)) {
            found = true;
            break;
          }
        }
        if (!found) {
          missingIngredients.add(recipeIng);
        }
      }

      if (matchCount > 0) {
        final matchPercent = matchCount / recipeIngredients.length;
        matches.add(RecipeMatch(
          recipe: recipe,
          matchedIngredients: matchedIngredients,
          missingIngredients: missingIngredients,
          matchPercentage: matchPercent,
        ));
      }
    }

    // Sort by match percentage
    matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

    return matches.take(10).toList();
  }

  /// Add custom ingredient from user input.
  DetectedIngredient addManualIngredient(String name) {
    return DetectedIngredient(
      name: name,
      nameTR: name,
      confidence: 1.0,
      isSelected: true,
    );
  }

  /// Get common ingredients for quick add.
  List<String> getCommonIngredients() {
    return [
      'Domates', 'Soğan', 'Sarımsak', 'Biber',
      'Patates', 'Havuç', 'Yumurta', 'Süt',
      'Peynir', 'Tavuk', 'Et', 'Makarna',
      'Pirinç', 'Tereyağı', 'Zeytinyağı',
    ];
  }

  List<DetectedIngredient> _getMockDetectedIngredients() {
    return [
      DetectedIngredient(
        name: 'tomato',
        nameTR: 'domates',
        confidence: 0.92,
      ),
      DetectedIngredient(
        name: 'onion',
        nameTR: 'soğan',
        confidence: 0.88,
      ),
      DetectedIngredient(
        name: 'egg',
        nameTR: 'yumurta',
        confidence: 0.85,
      ),
      DetectedIngredient(
        name: 'pepper',
        nameTR: 'biber',
        confidence: 0.75,
      ),
      DetectedIngredient(
        name: 'cheese',
        nameTR: 'peynir',
        confidence: 0.70,
      ),
    ];
  }
}

/// Recipe match result.
class RecipeMatch {
  final KitchaRecipe recipe;
  final List<String> matchedIngredients;
  final List<String> missingIngredients;
  final double matchPercentage;

  RecipeMatch({
    required this.recipe,
    required this.matchedIngredients,
    required this.missingIngredients,
    required this.matchPercentage,
  });

  String get matchPercentDisplay => '${(matchPercentage * 100).toStringAsFixed(0)}%';

  int get missingCount => missingIngredients.length;
  bool get hasAllIngredients => missingIngredients.isEmpty;
}
