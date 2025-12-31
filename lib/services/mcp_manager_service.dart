import 'dart:async';
import 'package:flutter/foundation.dart';
import 'mcp_client_service.dart';
import '../models/mcp_server_config.dart';

class McpManagerService extends ChangeNotifier {
  static final McpManagerService _instance = McpManagerService._internal();
  factory McpManagerService() => _instance;
  McpManagerService._internal();

  final McpClientService _client = McpClientService();
  final List<McpServerConfig> _servers = [];
  final List<McpCallLog> _logs = [];
  final Map<String, McpServerStats> _stats = {};

  List<McpServerConfig> get servers => List.unmodifiable(_servers);
  List<McpCallLog> get logs => List.unmodifiable(_logs);

  void initialize() {
    // Connect client logs to manager
    _client.onLog = logCall;

    // Register default/mock servers
    _registerMockServers();
  }

  void _registerMockServers() {
    registerServer(McpServerConfig(name: 'Vision MCP', url: 'http://localhost:8081/vision'));
    registerServer(McpServerConfig(name: 'Recipe MCP', url: 'http://localhost:8082/recipes'));
    registerServer(McpServerConfig(name: 'Mem0 Memory', url: 'http://localhost:8083/memory'));
  }

  void registerServer(McpServerConfig config) {
    if (!_servers.any((s) => s.url == config.url)) {
      _servers.add(config);
      _stats[config.name] = McpServerStats();
      notifyListeners();
    }
  }

  Future<void> healthCheck(McpServerConfig server) async {
    server.status = McpServerStatus.testing;
    notifyListeners();

    final startTime = DateTime.now();
    try {
      final tools = await _client.listTools(server.url);
      final duration = DateTime.now().difference(startTime);
      
      server.status = McpServerStatus.active;
      server.lastResponseTimeMs = duration.inMilliseconds;
      server.availableTools = tools;
    } catch (e) {
      server.status = McpServerStatus.error;
      print('[McpManager] Health check failed for ${server.name}: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> testAllServers() async {
    for (var server in _servers) {
      if (server.isEnabled) {
        await healthCheck(server);
      }
    }
  }

  void logCall(McpCallLog log) {
    _logs.insert(0, log);
    if (_logs.length > 100) _logs.removeLast();
    
    _stats[log.serverName]?.addCall(log);
    
    // Update server metadata
    final server = _servers.firstWhere((s) => s.name == log.serverName, orElse: () => _servers[0]);
    server.lastResponseTimeMs = log.duration.inMilliseconds;
    server.successRate = _stats[log.serverName]?.successRate ?? 0;
    
    notifyListeners();
  }

  McpServerStats? getStats(String serverName) => _stats[serverName];

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}
