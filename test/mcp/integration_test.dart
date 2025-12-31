import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kitcha_app/services/vision_mcp_service.dart';
import 'package:kitcha_app/services/memory_mcp_service.dart';
import 'package:kitcha_app/services/recipe_mcp_service.dart';
import 'package:kitcha_app/services/notification_mcp_service.dart';
import 'package:kitcha_app/services/mcp_client_service.dart';
import 'package:kitcha_app/services/app_service.dart';
import 'package:kitcha_app/repository/app_repository.dart';
import 'package:kitcha_app/models/food_analysis.dart';
import 'mcp_test_utils.dart';

void main() {
  late MockMcpClient mockClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockClient = MockMcpClient();
    McpClientService.instance = mockClient;
    
    dotenv.testLoad(fileInput: 'MEM0_API_KEY=key\nSPOONACULAR_API_KEY=key\nOPENAI_API_KEY=key');
  });

  test('End-to-End MCP Integration Flow', () async {
    // 1. Arrange: Setup mock responses for all services in the chain
    mockClient.mockResponses['https://openai-mcp.example.com:openai_vision'] = {
      'content': [{'text': '[{"name": "Makarna", "grams": 200, "calories": 300, "confidence": 0.9}]'}]
    };
    mockClient.mockResponses['mem0:add_memory'] = {'status': 'ok'};
    mockClient.mockResponses['mem0:search_memory'] = 'Kullanıcı makarna seviyor';
    mockClient.mockResponses['https://spoonacular-mcp.example.com:searchRecipesByIngredients'] = {
      'recipes': [{'id': 1, 'title': 'Ev Yapımı Makarna'}]
    };

    // 2. Act: Execute the flow
    
    // a. Analyze Image
    final visionService = VisionMcpService();
    final analysis = await visionService.analyzeImageMultiModel('/test/images/pasta.jpg');
    expect(analysis.foods.isNotEmpty, true);
    expect(analysis.foods.first.name, 'Makarna');

    // b. Update Memory from Analysis
    final memoryService = MemoryMcpService();
    // We need an AnalysisModel here, creating mock one
    final analysisModel = McpTestDataFactory.createMockAnalysis();
    await memoryService.updateMemoryFromAnalysis(analysisModel);
    
    // c. Get Personalized Recipe via Assistant logic
    final context = await memoryService.searchContext('ne pişirsem');
    final recipeService = RecipeMcpService();
    final recipes = await recipeService.searchRecipesByIngredients(context);
    
    // d. Schedule Notification
    final notificationService = NotificationMcpService();
    await notificationService.sendPersonalizedSuggestion();

    // 3. Assert: Verify the interaction chain
    expect(recipes.any((r) => r.title.contains('Makarna')), true);
    expect(mockClient.recordedCalls.length, greaterThanOrEqualTo(4));
    print('✅ End-to-End Integration Flow Verified Successfully');
  });
}
