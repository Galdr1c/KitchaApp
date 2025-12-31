import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kitcha_app/services/memory_mcp_service.dart';
import 'package:kitcha_app/services/mcp_client_service.dart';
import 'package:kitcha_app/repository/app_repository.dart';
import 'mcp_test_utils.dart';

void main() {
  late MemoryMcpService memoryService;
  late MockMcpClient mockClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockClient = MockMcpClient();
    McpClientService.instance = mockClient;
    memoryService = MemoryMcpService();
    
    // Mock API key presence
    DotEnv().testLoad(fileInput: 'MEM0_API_KEY=test_key');
  });

  group('MemoryMcpService Tests', () {
    test('addMemory should call MCP tool when API key is present', () async {
      await memoryService.addMemory('Kullanıcı tuzu az seviyor');
      
      expect(mockClient.recordedCalls.length, 1);
      expect(mockClient.recordedCalls[0]['tool'], 'add_memory');
      expect(mockClient.recordedCalls[0]['params']['text'], 'Kullanıcı tuzu az seviyor');
    });

    test('searchContext should return results from MCP', () async {
      mockClient.mockResponses['mem0:search_memory'] = 'Kullanıcı deniz ürünlerini seviyor';
      
      final result = await memoryService.searchContext('balık');
      
      expect(result, 'Kullanıcı deniz ürünlerini seviyor');
      expect(mockClient.recordedCalls.any((c) => c['tool'] == 'search_memory'), true);
    });

    test('updateMemoryFromAnalysis should extract correct information', () async {
      final analysis = McpTestDataFactory.createMockAnalysis();
      await memoryService.updateMemoryFromAnalysis(analysis);
      
      // Should call add_memory with meal info
      expect(mockClient.recordedCalls.any((c) => 
        c['tool'] == 'add_memory' && 
        c['params']['text'].contains('Pizza, Salad')
      ), true);
    });

    test('local fallback should work when API key is missing', () async {
      dotenv.testLoad(fileInput: ''); // No API key
      
      await memoryService.addMemory('Yerli meyveleri tercih ediyor');
      
      final memories = await memoryService.getMemories();
      expect(memories.contains('Yerli meyveleri tercih ediyor'), true);
      // Should NOT have called MCP
      expect(mockClient.recordedCalls.isEmpty, true);
    });

    test('clearMemory should wipe both local and remote data', () async {
      await memoryService.addMemory('Silinecek bilgi');
      await memoryService.clearMemory();
      
      final memories = await memoryService.getMemories();
      expect(memories.isEmpty, true);
      expect(mockClient.recordedCalls.any((c) => c['tool'] == 'clear_memory'), true);
    });
  });
}
