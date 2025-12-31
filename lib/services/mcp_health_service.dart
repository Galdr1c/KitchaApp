import 'dart:async';
import 'package:http/http.dart' as http;
import 'sentry_service.dart';
import 'firebase_mcp_service.dart';

class McpHealthService {
  static final McpHealthService _instance = McpHealthService._internal();
  factory McpHealthService() => _instance;
  McpHealthService._internal();

  /// Check connectivity to all configured MCP servers
  Future<Map<String, bool>> checkAllServers(List<String> serverUrls) async {
    final results = <String, bool>{};
    
    for (final url in serverUrls) {
      try {
        final startTime = DateTime.now();
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
        
        // Simple health check: if we get any HTTP response, consider it reachable
        // For actual MCP, we could call tools/list as a deeper check
        final isHealthy = response.statusCode == 200 || response.statusCode == 405; // 405 because GET might be disallowed
        results[url] = isHealthy;
        
        if (!isHealthy) {
          SentryService.logMessage('MCP Server Health Check Failed: $url (Status: ${response.statusCode})');
        }
      } catch (e) {
        results[url] = false;
        SentryService.captureException(e, reason: 'Health check failed for $url');
      }
    }
    
    return results;
  }
}
