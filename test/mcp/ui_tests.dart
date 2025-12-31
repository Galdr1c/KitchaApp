import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kitcha_app/screens/ai_assistant_screen.dart';
import 'package:kitcha_app/screens/developer_screen.dart';
import 'package:kitcha_app/services/mcp_manager_service.dart';
import 'package:kitcha_app/services/memory_mcp_service.dart';
import 'package:kitcha_app/services/recipe_mcp_service.dart';
import 'package:kitcha_app/services/mcp_client_service.dart';
import 'mcp_test_utils.dart';

void main() {
  late MockMcpClient mockClient;

  setUp(() {
    mockClient = MockMcpClient();
    McpClientService.instance = mockClient;
    
    // Setup providers
    MemoryMcpService.instance = MemoryMcpService();
    RecipeMcpService.instance = RecipeMcpService();
  });

  group('AI/Developer Widget Tests', () {
    testWidgets('DeveloperScreen should show server list', (WidgetTester tester) async {
      final manager = McpManagerService()..initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<McpManagerService>.value(
            value: manager,
            child: const DeveloperScreen(),
          ),
        ),
      );

      expect(find.text('Geliştirici Seçenekleri'), findsOneWidget);
      expect(find.text('Sunucular'), findsOneWidget);
      // Check for mock servers defined in manager
      expect(find.text('Vision MCP'), findsOneWidget);
    });

    testWidgets('AIAssistantScreen should show chat bubbles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AIAssistantScreen(),
        ),
      );

      expect(find.text('Nasıl yardımcı olabilirim?'), findsOneWidget);
      
      // Type a message
      await tester.enterText(find.byType(TextField), 'Merhaba');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(find.text('Merhaba'), findsOneWidget);
    });
  });
}
