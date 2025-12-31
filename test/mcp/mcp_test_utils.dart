import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitcha_app/services/mcp_client_service.dart';
import 'package:kitcha_app/models/mcp_server_config.dart';
import 'package:kitcha_app/repository/app_repository.dart';
import 'package:kitcha_app/models/recipe.dart';
import 'package:kitcha_app/models/food_analysis.dart';
import 'package:kitcha_app/services/vision_mcp_service.dart';

/// A mock implementation of McpClientService for testing purposes.
class MockMcpClient implements McpClientService {
  Map<String, dynamic> mockResponses = {};
  List<Map<String, dynamic>> recordedCalls = [];
  bool simulateTimeout = false;
  bool simulateError = false;

  @override
  void Function(McpCallLog)? onLog;

  @override
  Future<Map<String, dynamic>> callTool(String serverUrl, String toolName, Map<String, dynamic> parameters) async {
    recordedCalls.add({
      'url': serverUrl,
      'tool': toolName,
      'params': parameters,
    });

    if (simulateTimeout) {
      await Future.delayed(const Duration(seconds: 31)); // Exceed default 30s timeout
      throw McpException('Mock Timeout', code: 408);
    }

    if (simulateError) {
      throw McpException('Mock API Error', code: 500);
    }

    final key = '$serverUrl:$toolName';
    if (mockResponses.containsKey(key)) {
      return mockResponses[key];
    }

    // Default mock response
    return {'status': 'ok', 'message': 'Mock response for $toolName'};
  }

  @override
  Future<List<dynamic>> listTools(String serverUrl) async {
    if (simulateError) throw McpException('Mock List Error');
    return [
      {'name': 'test_tool', 'description': 'A mock tool for testing'}
    ];
  }

  @override
  Map<String, dynamic> handleResponse(Map<String, dynamic> response) => response;

  @override
  void dispose() {}
}

/// Helper to generate mock data for tests
class McpTestDataFactory {
  static RecipeModel createMockRecipe({int id = 1, String name = 'Mock Pasta'}) {
    return RecipeModel(
      id: id,
      name: name,
      ingredients: ['Pasta', 'Tomato', 'Basil'],
      steps: ['Boil water', 'Cook pasta', 'Add sauce'],
      imageUrl: 'https://example.com/pasta.jpg',
      calories: 450,
      prepTime: 10,
      cookTime: 15,
      servings: 2,
      category: 'Italian',
    );
  }

  static AnalysisModel createMockAnalysis() {
    return AnalysisModel(
      date: '2025-12-30',
      totalCalories: 600,
      foods: [
        FoodItem(name: 'Pizza', calories: 500, grams: 200)..confidence = 0.9,
        FoodItem(name: 'Salad', calories: 100, grams: 150)..confidence = 0.8,
      ],
      photoPath: '/mock/path/photo.jpg',
    );
  }
}
