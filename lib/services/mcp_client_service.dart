import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/mcp_server_config.dart';
import 'sentry_service.dart';
import 'firebase_mcp_service.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

import '../config/env.dart';

/// A custom, high-performance MCP Client Service for KitchaApp.
/// Implements MCP protocol over HTTP with robust error handling and logging.
class McpClientService {
  static McpClientService _instance = McpClientService._internal();
  factory McpClientService() => _instance;
  McpClientService._internal();

  @visibleForTesting
  static set instance(McpClientService mock) => _instance = mock;

  final http.Client _httpClient = http.Client();
  static const Duration _defaultTimeout = Duration(seconds: 30);

  // Simple In-Memory Cache
  final Map<String, dynamic> _cache = {};
  final Duration _cacheDuration = const Duration(minutes: 5);
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Callback for logging MCP calls (used by McpManagerService)
  void Function(McpCallLog)? onLog;

  /// calls a specific tool on an MCP server.
  Future<Map<String, dynamic>> callTool(
    String serverUrl,
    String toolName,
    Map<String, dynamic> parameters,
  ) async {
    final startTime = DateTime.now();
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final cacheKey = 'tool_${serverUrl}_${toolName}_${jsonEncode(parameters)}';

    // Check Cache
    if (_cache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null && DateTime.now().difference(timestamp) < _cacheDuration) {
        _log('♻️ [MCP Cache Hit] Tool: $toolName', level: _LogLevel.info);
        return _cache[cacheKey];
      }
    }

    _log('🚀 [MCP Call] Tool: $toolName | RequestId: $requestId', level: _LogLevel.info);
    _log('📦 Params: $parameters', level: _LogLevel.debug);

    final body = {
      'jsonrpc': '2.0',
      'id': requestId,
      'method': 'tools/call',
      'params': {
        'name': toolName,
        'arguments': parameters,
      },
    };

    try {
      final responseData = await _postRequest(serverUrl, body);
      final duration = DateTime.now().difference(startTime);
      
      _log('✅ [MCP Success] Tool: $toolName | Id: $requestId | Time: ${duration.inMilliseconds}ms', level: _LogLevel.info);
      
      final result = handleResponse(responseData);
      
      // Update Cache
      _cache[cacheKey] = result;
      _cacheTimestamps[cacheKey] = DateTime.now();

      // Log to Firebase Analytics
      FirebaseMcpService().logMcpCallSuccess(_getServerName(serverUrl), toolName);

      onLog?.call(McpCallLog(
        timestamp: startTime,
        serverName: _getServerName(serverUrl),
        toolName: toolName,
        duration: duration,
        isSuccess: true,
        parameters: parameters,
        response: result,
      ));

      return result;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _log('❌ [MCP Error] Tool: $toolName | Error: $e', level: _LogLevel.error);
      
      // Log to Sentry and Firebase
      SentryService.captureException(e, stackTrace: StackTrace.current, reason: 'MCP call failed: $toolName');
      FirebaseMcpService().logMcpCallFailure(_getServerName(serverUrl), toolName, e.toString());

      onLog?.call(McpCallLog(
        timestamp: startTime,
        serverName: _getServerName(serverUrl),
        toolName: toolName,
        duration: duration,
        isSuccess: false,
        errorMessage: e.toString(),
        parameters: parameters,
      ));
      
      rethrow;
    }
  }

  String _getServerName(String url) {
    if (url.contains('vision')) return 'Vision MCP';
    if (url.contains('recipe')) return 'Recipe MCP';
    if (url.contains('memory')) return 'Mem0 Memory';
    return url;
  }

  /// Lists all available tools from an MCP server.
  Future<List<dynamic>> listTools(String serverUrl) async {
    final startTime = DateTime.now();
    _log('🔍 [MCP List] Fetching tools from: $serverUrl', level: _LogLevel.info);

    final body = {
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'method': 'tools/list',
      'params': {},
    };

    try {
      final responseData = await _postRequest(serverUrl, body);
      final duration = DateTime.now().difference(startTime);
      
      final result = handleResponse(responseData);
      final tools = result['tools'] as List? ?? [];
      
      _log('📋 [MCP List] Found ${tools.length} tools | Time: ${duration.inMilliseconds}ms', level: _LogLevel.info);
      return tools;
    } catch (e) {
      _log('❌ [MCP List Error] $e', level: _LogLevel.error);
      rethrow;
    }
  }

  /// Handles and parses JSON-RPC responses.
  Map<String, dynamic> handleResponse(Map<String, dynamic> response) {
    if (response.containsKey('error')) {
      final error = response['error'];
      final code = error['code'];
      final message = error['message'];
      final data = error['data'];
      
      throw McpException(
        'MCP Protocol Error ($code): $message',
        code: code,
        data: data,
      );
    }

    if (!response.containsKey('result')) {
      throw McpException('Invalid MCP Response: Missing result field');
    }

    return response['result'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _postRequest(String url, Map<String, dynamic> body) async {
    try {
      // Production Certificate Pinning check
      if (Env.isProduction) {
        final fingerprints = [
          'SHA-256-FINGERPRINT-1', // Placeholder: Actual fingerprint should be provided
        ];
        try {
          await HttpCertificatePinning.check(
            serverURL: url,
            headerHttp: {'Content-Type': 'application/json'},
            sha: SHA.SHA256,
            allowedSHAFingerprints: fingerprints,
            timeout: 10,
          );
        } catch (e) {
          throw McpException('Certificate Pinning Error: SSL handshake failed for $url');
        }
      }

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(_defaultTimeout);

      if (response.statusCode != 200) {
        throw McpException(
          'HTTP Error ${response.statusCode}: ${response.reasonPhrase}',
          code: response.statusCode,
        );
      }

      return json.decode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw McpException('MCP Request Timeout after ${_defaultTimeout.inSeconds}s', code: 408);
    } on http.ClientException catch (e) {
      throw McpException('Network Error: ${e.message}');
    } catch (e) {
      throw McpException('Unexpected Error: $e');
    }
  }

  void _log(String message, {required _LogLevel level}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String().split('T').last.substring(0, 12);
      print('[$timestamp] $message');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

enum _LogLevel { debug, info, error }

class McpException implements Exception {
  final String message;
  final int? code;
  final dynamic data;

  McpException(this.message, {this.code, this.data});

  @override
  String toString() => message;
}
