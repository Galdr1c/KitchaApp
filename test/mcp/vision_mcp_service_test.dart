import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kitcha_app/services/vision_mcp_service.dart';
import 'package:kitcha_app/services/app_service.dart';
import 'package:kitcha_app/services/mcp_client_service.dart';
import 'package:kitcha_app/repository/app_repository.dart';
import 'package:kitcha_app/models/food_analysis.dart';
import 'mcp_test_utils.dart';
import 'dart:io';

class MockAppService implements AppService {
  @override
  Future<ImageAnalysisResult> analyzeImageLocal(String photoPath) async {
    return ImageAnalysisResult(
      success: true,
      foods: [FoodItem(name: 'ML Kit Apple', grams: 150, calories: 75)],
      uncertainFoods: [],
      modelUsed: 'Google ML Kit',
      message: 'Mock ML Kit success',
    );
  }

  // Other overrides as needed or use a real Mockito/Mocktail if allowed
  @override 
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late VisionMcpService visionService;
  late MockMcpClient mockClient;
  late MockAppService mockApp;

  setUp(() async {
    mockClient = MockMcpClient();
    McpClientService.instance = mockClient;
    
    mockApp = MockAppService();
    AppService.instance = mockApp;
    
    visionService = VisionMcpService();
    dotenv.testLoad(fileInput: 'OPENAI_API_KEY=sk-test\nANTHROPIC_API_KEY=sk-ant-test');
  });

  group('VisionMcpService Tests', () {
    test('analyzeImageMultiModel should parallelize calls and merge results', () async {
      // Setup mock responses for GPT and Claude
      mockClient.mockResponses['https://openai-mcp.example.com:openai_vision'] = {
        'content': [{'text': '[{"name": "GPT Apple", "grams": 150, "calories": 80, "confidence": 0.9}]'}]
      };
      mockClient.mockResponses['https://anthropic-mcp.example.com:anthropic_vision'] = {
        'content': [{'text': '[{"name": "Claude Apple", "grams": 150, "calories": 78, "confidence": 0.95}]'}]
      };

      final result = await visionService.analyzeImageMultiModel('/test/path/apple.jpg');
      
      expect(result.success, true);
      expect(result.foods.length, 1);
      // Merged result should have consensus
      expect(result.foods.first.name.toLowerCase().contains('apple'), true);
      expect(mockClient.recordedCalls.length, 2); // OpenAI + Anthropic
    });

    test('should use cache for subsequent calls', () async {
      final path = '/test/cache/food.jpg';
      await visionService.analyzeImageMultiModel(path);
      final callCount = mockClient.recordedCalls.length;
      
      await visionService.analyzeImageMultiModel(path);
      
      expect(mockClient.recordedCalls.length, callCount); // No new calls
    });

    test('should handle timeout gracefully', () async {
      mockClient.simulateTimeout = true;
      
      final result = await visionService.analyzeImageMultiModel('/test/timeout.jpg');
      
      expect(result.success, false);
      expect(result.message!.contains('timeout'), true);
    });
  });
}
