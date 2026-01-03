import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mcp_client_service.dart';
import '../models/recipe.dart';
import '../repository/app_repository.dart';

/// Service to manage user memory and personalization using Mem0 MCP
class MemoryMcpService {
  static final MemoryMcpService _instance = MemoryMcpService._internal();
  factory MemoryMcpService() => _instance;
  MemoryMcpService._internal();

  final McpClientService _mcpClient = McpClientService();
  bool _isLearningEnabled = true;

  bool get isLearningEnabled => _isLearningEnabled;
  bool get _hasApiKey => dotenv.env['MEM0_API_KEY']?.isNotEmpty ?? false;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isLearningEnabled = prefs.getBool('memory_learning_enabled') ?? true;
  }

  Future<void> setLearningEnabled(bool enabled) async {
    _isLearningEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('memory_learning_enabled', enabled);
  }

  // --- Core Memory Methods ---

  /// Add a memory for the user
  Future<bool> addMemory(String text) async {
    if (!_isLearningEnabled) return false;

    if (_hasApiKey) {
      try {
        await _mcpClient.callTool('mem0', 'add_memory', {
          'text': text,
        });
        print('[MemoryMcpService] Added memory: $text');
        return true;
      } catch (e) {
        print('[MemoryMcpService] Tool call error: $e');
      }
    }
    
    // Local fallback/mock
    return await _addLocalMemory(text);
  }

  /// Get all or top memories
  Future<List<String>> getMemories() async {
    if (_hasApiKey) {
      try {
        final response = await _mcpClient.callTool('mem0', 'get_memories', {});
        // Response is Map from callTool, extract memories list
        if (response.containsKey('memories') && response['memories'] is List) {
          return (response['memories'] as List).map((e) => e.toString()).toList();
        }
        // Fallback: return content if available
        if (response.containsKey('content')) {
          return [response['content'].toString()];
        }
      } catch (e) {
        print('[MemoryMcpService] Get memories error: $e');
      }
    }
    return _getLocalMemories();
  }

  /// Search memory for relevant context
  Future<String> searchContext(String query) async {
    if (_hasApiKey) {
      try {
        final response = await _mcpClient.callTool('mem0', 'search_memory', {
          'query': query,
        });
        return response.toString();
      } catch (e) {
        print('[MemoryMcpService] Search memory error: $e');
      }
    }
    
    final memories = await _getLocalMemories();
    return memories.where((m) => m.toLowerCase().contains(query.toLowerCase())).join('\n');
  }

  /// Clear all user memory
  Future<void> clearMemory() async {
    if (_hasApiKey) {
      try {
        await _mcpClient.callTool('mem0', 'clear_memory', {});
      } catch (e) {
        print('[MemoryMcpService] Clear memory error: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('local_memories');
  }

  // --- Domain Specific Learning ---

  /// Learn from food analysis
  Future<void> updateMemoryFromAnalysis(AnalysisModel analysis) async {
    if (!_isLearningEnabled) return;

    final foodNames = analysis.foods.map((f) => f.name).join(', ');
    final totalCals = analysis.totalCalories;
    
    final memoryText = 'Kullanıcı $foodNames içeren bir öğün tüketti. Toplam kalori: $totalCals. Tarih: ${analysis.date}';
    await addMemory(memoryText);
    
    if (totalCals > 800) {
      await addMemory('Kullanıcı bazen yoğun ve yüksek kalorili öğünleri tercih edebiliyor.');
    }
  }

  /// Learn from recipe interaction
  Future<void> updateMemoryFromRecipeView(RecipeModel recipe) async {
    if (!_isLearningEnabled) return;

    final memoryText = 'Kullanıcı "${recipe.name}" tarifini görüntüledi. Kategori: ${recipe.category}. Süre: ${recipe.prepTime + recipe.cookTime} dk.';
    await addMemory(memoryText);
    
    if (recipe.isFavorite) {
      await addMemory('Kullanıcı ${recipe.name} yemeğini favorilere ekledi, bu tarz lezzetleri seviyor.');
    }
  }

  // --- Local Fallback ---

  Future<bool> _addLocalMemory(String text) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> memories = prefs.getStringList('local_memories') ?? [];
    memories.insert(0, text);
    if (memories.length > 50) memories = memories.sublist(0, 50); // Retention
    return await prefs.setStringList('local_memories', memories);
  }

  Future<List<String>> _getLocalMemories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('local_memories') ?? [];
  }
}
