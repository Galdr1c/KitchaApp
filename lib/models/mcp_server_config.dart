import 'dart:convert';

enum McpServerStatus { active, inactive, testing, error }

class McpServerConfig {
  final String name;
  final String url;
  bool isEnabled;
  McpServerStatus status;
  int lastResponseTimeMs;
  double successRate;
  List<dynamic>? availableTools;

  McpServerConfig({
    required this.name,
    required this.url,
    this.isEnabled = true,
    this.status = McpServerStatus.inactive,
    this.lastResponseTimeMs = 0,
    this.successRate = 0.0,
    this.availableTools,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'isEnabled': isEnabled,
  };

  factory McpServerConfig.fromJson(Map<String, dynamic> json) => McpServerConfig(
    name: json['name'],
    url: json['url'],
    isEnabled: json['isEnabled'] ?? true,
  );
}

class McpCallLog {
  final DateTime timestamp;
  final String serverName;
  final String toolName;
  final Duration duration;
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, dynamic>? parameters;
  final Map<String, dynamic>? response;

  McpCallLog({
    required this.timestamp,
    required this.serverName,
    required this.toolName,
    required this.duration,
    required this.isSuccess,
    this.errorMessage,
    this.parameters,
    this.response,
  });
}

class McpServerStats {
  int totalCalls = 0;
  int successCount = 0;
  int totalDurationMs = 0;

  double get successRate => totalCalls == 0 ? 0 : (successCount / totalCalls) * 100;
  int get avgDurationMs => totalCalls == 0 ? 0 : (totalDurationMs ~/ totalCalls);

  void addCall(McpCallLog log) {
    totalCalls++;
    if (log.isSuccess) successCount++;
    totalDurationMs += log.duration.inMilliseconds;
  }
}
