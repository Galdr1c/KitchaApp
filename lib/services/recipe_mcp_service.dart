import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/recipe.dart';
import 'mcp_client_service.dart';

/// Service specialized for Spoonacular MCP integration.
/// Handles recipe search, nutrition, and daily menu features.
class RecipeMcpService {
  static RecipeMcpService _instance = RecipeMcpService._internal();
  factory RecipeMcpService() => _instance;
  RecipeMcpService._internal();

  @visibleForTesting
  static set instance(RecipeMcpService mock) => _instance = mock;

  final McpClientService _mcpClient = McpClientService();
  static const String _spoonacularMcpUrl = 'https://spoonacular-mcp.example.com';
  
  // Cache: Map<Query, CachedResult>
  final Map<String, _CachedResult> _cache = {};
  static const int _maxCacheSize = 50;
  static const Duration _cacheDuration = Duration(hours: 24);

  bool get _isDemoMode => dotenv.env['IS_DEMO_MODE'] == 'true';
  String? get _apiKey => dotenv.env['SPOONACULAR_API_KEY'];

  /// Search recipes by ingredients using MCP
  Future<List<Recipe>> searchRecipesByIngredients(String ingredients) async {
    final cacheKey = 'search_$ingredients';
    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached;

    if (_isDemoMode || _apiKey == null || _apiKey!.isEmpty) {
      _log('💡 [Demo Mode] Returning mock recipes for: $ingredients');
      return _getMockRecipes();
    }

    try {
      final result = await _mcpClient.callTool(
        _spoonacularMcpUrl,
        'searchRecipesByIngredients',
        {'ingredients': ingredients, 'number': 10},
      );

      final recipes = (result['recipes'] as List? ?? [])
          .map((r) => Recipe.fromJson(r as Map<String, dynamic>))
          .toList();

      _saveToCache(cacheKey, recipes);
      return recipes;
    } catch (e) {
      _log('❌ MCP Search Error: $e', isError: true);
      rethrow;
    }
  }

  /// Get detailed nutrition via MCP
  Future<Map<String, dynamic>> getRecipeNutrition(int recipeId) async {
    final cacheKey = 'nutrition_$recipeId';
    final cached = _getRawFromCache(cacheKey);
    if (cached != null) return cached;

    if (_isDemoMode) return _getMockNutrition();

    try {
      final result = await _mcpClient.callTool(
        _spoonacularMcpUrl,
        'getRecipeNutrition',
        {'id': recipeId},
      );
      
      _saveRawToCache(cacheKey, result);
      return result;
    } catch (e) {
      _log('❌ MCP Nutrition Error: $e', isError: true);
      rethrow;
    }
  }

  /// Suggest daily menu via MCP
  Future<List<Recipe>> suggestDailyMenu(int calorieGoal, Map<String, dynamic> preferences) async {
    try {
      final result = await _mcpClient.callTool(
        _spoonacularMcpUrl,
        'suggestDailyMenu',
        {'targetCalories': calorieGoal, 'diet': preferences['diet'], 'exclude': preferences['exclude']},
      );
      return (result['meals'] as List? ?? [])
          .map((r) => Recipe.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log('❌ MCP Suggest Error: $e', isError: true);
      rethrow;
    }
  }

  /// Find similar recipes via MCP
  Future<List<Recipe>> findSimilarRecipes(int recipeId) async {
    try {
      final result = await _mcpClient.callTool(
        _spoonacularMcpUrl,
        'findSimilarRecipes',
        {'id': recipeId, 'number': 5},
      );
      
      return (result['recipes'] as List? ?? [])
          .map((r) => Recipe.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log('❌ MCP Similar Error: $e', isError: true);
      rethrow;
    }
  }

  // --- Caching Logic ---

  List<Recipe>? _getFromCache(String key) {
    final item = _cache[key];
    if (item != null && !item.isExpired) {
      return List<Recipe>.from(item.data as List<Recipe>);
    }
    _cache.remove(key);
    return null;
  }

  Map<String, dynamic>? _getRawFromCache(String key) {
    final item = _cache[key];
    if (item != null && !item.isExpired) {
      return Map<String, dynamic>.from(item.data as Map<String, dynamic>);
    }
    _cache.remove(key);
    return null;
  }

  void _saveToCache(String key, List<Recipe> data) {
    _cleanupCache();
    _cache[key] = _CachedResult(data, DateTime.now().add(_cacheDuration));
  }

  void _saveRawToCache(String key, Map<String, dynamic> data) {
    _cleanupCache();
    _cache[key] = _CachedResult(data, DateTime.now().add(_cacheDuration));
  }

  void _cleanupCache() {
    if (_cache.length >= _maxCacheSize) {
      // Remove oldest or expired
      final keysToRemove = _cache.entries
          .where((e) => e.value.isExpired)
          .map((e) => e.key)
          .toList();
      
      if (keysToRemove.isEmpty) {
        keysToRemove.add(_cache.keys.first);
      }
      
      for (var key in keysToRemove) {
        _cache.remove(key);
      }
    }
  }

  // --- Mock Data ---

  List<Recipe> _getMockRecipes() {
    return [
      Recipe(
        id: 1,
        title: 'Izgara Somon ve Kuşkonmaz',
        description: 'Sağlıklı ve hızlı bir akşam yemeği.',
        imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288',
        ingredients: ['Somon filesi', 'Kuşkonmaz', 'Zeytinyağı', 'Limon'],
        instructions: ['Somonu baharatlayın', 'Izgarada 12 dakika pişirin', 'Servis edin'],
        calories: 350,
        protein: 34.0,
        carbs: 4.0,
        fat: 22.0,
        category: 'Akşam Yemeği',
      ),
      Recipe(
        id: 2,
        title: 'Kinoa Salatası',
        description: 'Protein deposu ferahlatıcı salata.',
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
        ingredients: ['Kinoa', 'Nohut', 'Maydanoz', 'Domates'],
        instructions: ['Kinoayı haşlayın', 'Sebzeleri doğrayın', 'Hepsini karıştırın'],
        calories: 280,
        protein: 12.0,
        carbs: 45.0,
        fat: 7.0,
        category: 'Öğle Yemeği',
      ),
      Recipe(
        id: 3,
        title: 'Avokadolu Yumurta',
        description: 'Harika bir kahvaltı başlangıcı.',
        imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8',
        ingredients: ['Tam buğday ekmeği', 'Avokado', 'Yumurta', 'Pul biber'],
        instructions: ['Ekmeği kızartın', 'Avokadoyu ezin', 'Yumurtayı haşlayıp ekleyin'],
        calories: 310,
        protein: 14.0,
        carbs: 22.0,
        fat: 18.0,
        category: 'Kahvaltı',
      ),
      Recipe(
        id: 4,
        title: 'Mercimek Köftesi',
        description: 'Geleneksel ve doyurucu bir lezzet.',
        imageUrl: 'https://images.unsplash.com/photo-1604328698692-f76ea9498e76',
        ingredients: ['Kırmızı mercimek', 'Bulgur', 'Soğan', 'Salça'],
        instructions: ['Mercimeği haşlayın', 'Bulguru ekleyip bekletin', 'Yoğurup şekil verin'],
        calories: 180,
        protein: 8.0,
        carbs: 32.0,
        fat: 2.0,
        category: 'Atıştırmalık',
      ),
      Recipe(
        id: 5,
        title: 'Fırınlanmış Sebze Tabağı',
        description: 'Hafif ve besleyici.',
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        ingredients: ['Balkabağı', 'Brokoli', 'Havuç', 'Biberiye'],
        instructions: ['Sebzeleri doğrayın', 'Zeytinyağı ile soslayın', 'Fırında 25 dakika pişirin'],
        calories: 200,
        protein: 5.0,
        carbs: 28.0,
        fat: 9.0,
        category: 'Diyet',
      ),
    ];
  }

  Map<String, dynamic> _getMockNutrition() {
    return {
      'calories': 450,
      'nutrients': [
        {'name': 'Protein', 'amount': 25.0, 'unit': 'g'},
        {'name': 'Fat', 'amount': 15.0, 'unit': 'g'},
        {'name': 'Carbohydrates', 'amount': 55.0, 'unit': 'g'},
      ]
    };
  }

  void _log(String message, {bool isError = false}) {
    if (kDebugMode) {
      print('[RecipeMcpService] ${isError ? '🛑' : 'ℹ️'} $message');
    }
  }
}

class _CachedResult {
  final dynamic data;
  final DateTime expiry;
  _CachedResult(this.data, this.expiry);
  bool get isExpired => DateTime.now().isAfter(expiry);
}
