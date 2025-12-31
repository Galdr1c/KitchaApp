import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kitcha_app/services/recipe_mcp_service.dart';
import 'package:kitcha_app/services/mcp_client_service.dart';
import 'package:kitcha_app/models/recipe.dart';
import 'package:kitcha_app/repository/app_repository.dart';
import 'mcp_test_utils.dart';

void main() {
  late RecipeMcpService recipeService;
  late MockMcpClient mockClient;

  setUp(() async {
    mockClient = MockMcpClient();
    McpClientService.instance = mockClient;
    
    recipeService = RecipeMcpService();
    dotenv.testLoad(fileInput: 'SPOONACULAR_API_KEY=test_key\nIS_DEMO_MODE=false');
  });

  group('RecipeMcpService Tests', () {
    test('searchRecipesByIngredients should call MCP and return recipes', () async {
      mockClient.mockResponses['https://spoonacular-mcp.example.com:searchRecipesByIngredients'] = {
        'recipes': [
          {
            'id': 101,
            'title': 'Test Pasta',
            'image': 'test.jpg',
            'preparationMinutes': 10,
            'cookingMinutes': 15,
            'servings': 2,
            'extendedIngredients': [{'original': 'Test ingredient'}],
            'analyzedInstructions': [{'steps': [{'step': 'Test step'}]}],
            'nutrition': {'nutrients': [{'name': 'Calories', 'amount': 400}]}
          }
        ]
      };

      final recipes = await recipeService.searchRecipesByIngredients('domates');
      
      expect(recipes.length, 1);
      expect(recipes.first.title, 'Test Pasta');
      expect(mockClient.recordedCalls.length, 1);
    });

    test('should use cache for identical searches', () async {
      final ingredients = 'makarna';
      await recipeService.searchRecipesByIngredients(ingredients);
      final count = mockClient.recordedCalls.length;
      
      await recipeService.searchRecipesByIngredients(ingredients);
      
      expect(mockClient.recordedCalls.length, count);
    });

    test('getRecipeNutrition should return nutrition data', () async {
      mockClient.mockResponses['https://spoonacular-mcp.example.com:getRecipeNutrition'] = {
        'calories': 500,
        'nutrients': [{'name': 'Protein', 'amount': 20}]
      };

      final nutrition = await recipeService.getRecipeNutrition(101);
      
      expect(nutrition['calories'], 500);
      expect(mockClient.recordedCalls.any((c) => c['tool'] == 'getRecipeNutrition'), true);
    });

    test('should return mock data in demo mode', () async {
      dotenv.testLoad(fileInput: 'IS_DEMO_MODE=true');
      
      final recipes = await recipeService.searchRecipesByIngredients('any');
      
      expect(recipes.isNotEmpty, true);
      expect(mockClient.recordedCalls.isEmpty, true);
    });
  });
}
