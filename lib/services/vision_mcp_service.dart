import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'mcp_client_service.dart';
import '../repository/app_repository.dart';
import 'app_service.dart';

/// Service for multi-model vision analysis using MCP and local ML Kit
class VisionMcpService {
  static final VisionMcpService _instance = VisionMcpService._internal();
  factory VisionMcpService() => _instance;
  VisionMcpService._internal();

  final McpClientService _mcpClient = McpClientService();
  
  // Cache for image analysis: Map<ImagePath, MultiModelResult>
  final Map<String, MultiModelResult> _cache = {};
  
  // MCP endpoints (should be configured in .env or via config)
  String get _openaiMcpUrl => dotenv.env['OPENAI_MCP_URL'] ?? 'https://openai-mcp.example.com';
  String get _anthropicMcpUrl => dotenv.env['ANTHROPIC_MCP_URL'] ?? 'https://anthropic-mcp.example.com';
  
  bool get _isDemoMode => dotenv.env['IS_DEMO_MODE'] == 'true';
  bool get _hasApiKeys => dotenv.env['OPENAI_API_KEY'] != null || dotenv.env['ANTHROPIC_API_KEY'] != null;

  /// Analyze image using multiple models in parallel
  Future<MultiModelResult> analyzeImageMultiModel(String imagePath) async {
    // Check cache
    if (_cache.containsKey(imagePath)) {
      print('[VisionMcpService] Returning cached result for: $imagePath');
      return _cache[imagePath]!;
    }

    print('[VisionMcpService] Starting multi-model analysis for: $imagePath');
    
    // 1. Prepare parallel tasks
    final List<Future<_ModelResult>> tasks = [];
    
    // Always include ML Kit (local)
    tasks.add(_runMlKit(imagePath));
    
    // Include AI models if not in demo mode or if keys exist
    if (!_isDemoMode && _hasApiKeys) {
      tasks.add(_runGpt4Vision(imagePath));
      tasks.add(_runClaudeVision(imagePath));
    } else if (_isDemoMode) {
      // In demo mode, add mock results for GPT and Claude to show the feature
      tasks.add(_runMockAiModel('GPT-4 Vision', imagePath));
      tasks.add(_runMockAiModel('Claude 3.5 Sonnet', imagePath));
    }

    try {
      // 2. Execute in parallel with 10s timeout
      final List<_ModelResult> results = await Future.wait(tasks)
          .timeout(const Duration(seconds: 10), onTimeout: () {
            print('[VisionMcpService] ⚠️ Analysis timed out after 10s');
            // Return whatever completed so far if possible, but for simplicity:
            throw TimeoutException('Multi-model vision analysis timed out');
          });

      // 3. Select best result and merge
      final bestResult = selectBestResult(results);
      final mergedData = mergeResults(results);
      
      final finalResult = MultiModelResult(
        foods: mergedData.foods,
        uncertainFoods: mergedData.uncertainFoods,
        modelUsed: bestResult.modelName,
        success: true,
      );

      // Cache result
      _cache[imagePath] = finalResult;
      return finalResult;
      
    } catch (e) {
      print('[VisionMcpService] Analysis error: $e');
      return MultiModelResult(
        foods: [],
        uncertainFoods: [],
        modelUsed: 'N/A',
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Select the model with the highest confidence or completeness
  _ModelResult selectBestResult(List<_ModelResult> results) {
    if (results.isEmpty) return _ModelResult(modelName: 'None', foods: []);
    
    // Sort by number of items found and average confidence
    results.sort((a, b) {
      final aConf = a.foods.isEmpty ? 0.0 : a.foods.map((f) => f.confidence).reduce((a, b) => a + b) / a.foods.length;
      final bConf = b.foods.isEmpty ? 0.0 : b.foods.map((f) => f.confidence).reduce((a, b) => a + b) / b.foods.length;
      
      // Weight item count slightly more than confidence
      final aScore = (a.foods.length * 1.5) + aConf;
      final bScore = (b.foods.length * 1.5) + bConf;
      return bScore.compareTo(aScore);
    });
    
    return results.first;
  }

  /// Merge results: detect consensus and separate uncertain items
  _MergedData mergeResults(List<_ModelResult> results) {
    final List<FoodItem> finalFoods = [];
    final List<FoodItem> uncertainFoods = [];
    
    // Frequency map to find consensus
    final Map<String, List<FoodItem>> consensusMap = {};
    
    for (final result in results) {
      for (final food in result.foods) {
        final key = food.name.toLowerCase();
        consensusMap.putIfAbsent(key, () => []);
        consensusMap[key]!.add(food);
      }
    }

    consensusMap.forEach((name, occurrences) {
      // Calculate average confidence for this food item
      final avgConf = occurrences.map((f) => f.confidence).reduce((a, b) => a + b) / occurrences.length;
      final avgGrams = occurrences.map((f) => f.grams).reduce((a, b) => a + b) / occurrences.length;
      final avgCals = occurrences.map((f) => f.calories).reduce((a, b) => a + b) ~/ occurrences.length;
      
      // Consensus boost: if more than 1 model found it, boost confidence
      final consensusBoost = occurrences.length > 1 ? 0.15 : 0.0;
      final finalConf = (avgConf + consensusBoost).clamp(0.0, 1.0);
      
      final mergedFood = FoodItem(
        name: occurrences.first.name, // Keep original casing
        grams: avgGrams,
        calories: avgCals,
        protein: occurrences.fold(0.0, (s, f) => s + f.protein) / occurrences.length,
        carbs: occurrences.fold(0.0, (s, f) => s + f.carbs) / occurrences.length,
        fat: occurrences.fold(0.0, (s, f) => s + f.fat) / occurrences.length,
      )..confidence = finalConf;

      if (finalConf > 0.6) {
        finalFoods.add(mergedFood);
      } else if (finalConf >= 0.4) {
        uncertainFoods.add(mergedFood);
      }
    });

    return _MergedData(foods: finalFoods, uncertainFoods: uncertainFoods);
  }

  // --- Individual Model Runners ---

  Future<_ModelResult> _runMlKit(String imagePath) async {
    try {
      // We'll bridge to AppService's existing ML Kit logic
      final appService = AppService();
      // Since AppService.analyzeImage is high-level, we might need a lower-level access 
      // or just wrap its result. For now, let's assume we can call it.
      // Note: In real app, we'd refactor AppService to expose individual steps.
      final result = await appService.analyzeImageLocal(imagePath);
      return _ModelResult(
        modelName: 'Google ML Kit',
        foods: result.foods,
      );
    } catch (e) {
      return _ModelResult(modelName: 'Google ML Kit', foods: []);
    }
  }

  Future<_ModelResult> _runGpt4Vision(String imagePath) async {
    try {
      final base64Image = base64Encode(await File(imagePath).readAsBytes());
      final response = await _mcpClient.callTool(
        _openaiMcpUrl,
        'openai_vision',
        {
          'image': base64Image,
          'prompt': 'Analyze this food photo. Identify food items, estimate grams and calories. Provide JSON response.',
        },
      );
      
      return _parseMcpVisionResponse('GPT-4 Vision', response);
    } catch (e) {
      return _ModelResult(modelName: 'GPT-4 Vision', foods: []);
    }
  }

  Future<_ModelResult> _runClaudeVision(String imagePath) async {
    try {
      final base64Image = base64Encode(await File(imagePath).readAsBytes());
      final response = await _mcpClient.callTool(
        _anthropicMcpUrl,
        'anthropic_vision',
        {
          'image': base64Image,
          'prompt': 'Analyze this food photo. Identify food items, estimate grams and calories. Provide JSON response.',
        },
      );
      
      return _parseMcpVisionResponse('Claude 3.5 Sonnet', response);
    } catch (e) {
      return _ModelResult(modelName: 'Claude 3.5 Sonnet', foods: []);
    }
  }

  Future<_ModelResult> _runMockAiModel(String modelName, String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Context-aware mocks based on path name if possible, else generic
    if (imagePath.contains('egg') || imagePath.contains('yumurta')) {
      return _ModelResult(
        modelName: modelName,
        foods: [
          FoodItem(name: 'Haşlanmış Yumurta', grams: 50, calories: 77)..confidence = 0.95,
          FoodItem(name: 'Tam Buğday Ekmek', grams: 40, calories: 100)..confidence = 0.85,
        ],
      );
    }
    
    return _ModelResult(
      modelName: modelName,
      foods: [
        FoodItem(name: 'Mock Food ($modelName)', grams: 100, calories: 150)..confidence = 0.8,
      ],
    );
  }

  _ModelResult _parseMcpVisionResponse(String modelName, Map<String, dynamic> response) {
    // Expected MCP tool output: { "content": [{ "type": "text", "text": "JSON_STRING" }] }
    final content = response['content'] as List?;
    if (content == null || content.isEmpty) return _ModelResult(modelName: modelName, foods: []);
    
    final text = content.first['text'] as String?;
    if (text == null) return _ModelResult(modelName: modelName, foods: []);
    
    try {
      // Find JSON block in text
      final jsonStart = text.indexOf('[');
      final jsonEnd = text.lastIndexOf(']') + 1;
      if (jsonStart == -1) return _ModelResult(modelName: modelName, foods: []);
      
      final jsonStr = text.substring(jsonStart, jsonEnd);
      final data = json.decode(jsonStr) as List;
      
      final foods = data.map((item) {
        return FoodItem(
          name: item['name'] ?? 'Unknown',
          grams: (item['grams'] as num?)?.toDouble() ?? 100.0,
          calories: (item['calories'] as num?)?.toInt() ?? 0,
          protein: (item['protein'] as num?)?.toDouble() ?? 0.0,
          carbs: (item['carbs'] as num?)?.toDouble() ?? 0.0,
          fat: (item['fat'] as num?)?.toDouble() ?? 0.0,
        )..confidence = (item['confidence'] as num?)?.toDouble() ?? 0.7;
      }).toList();
      
      return _ModelResult(modelName: modelName, foods: foods);
    } catch (e) {
      return _ModelResult(modelName: modelName, foods: []);
    }
  }
}

// --- Internal Helper Classes ---

class _ModelResult {
  final String modelName;
  final List<FoodItem> foods;

  _ModelResult({required this.modelName, required this.foods});
}

class _MergedData {
  final List<FoodItem> foods;
  final List<FoodItem> uncertainFoods;

  _MergedData({required this.foods, required this.uncertainFoods});
}

/// Final result model for multi-model analysis
class MultiModelResult {
  final bool success;
  final List<FoodItem> foods;
  final List<FoodItem> uncertainFoods;
  final String modelUsed;
  final String? message;

  MultiModelResult({
    required this.success,
    required this.foods,
    required this.uncertainFoods,
    required this.modelUsed,
    this.message,
  });
}

// Extends FoodItem with confidence for internal merging logic
extension FoodItemExt on FoodItem {
  static final _confidences = Expando<double>();
  
  double get confidence => _confidences[this] ?? 0.0;
  set confidence(double value) => _confidences[this] = value;
}
