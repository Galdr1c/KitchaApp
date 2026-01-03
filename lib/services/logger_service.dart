import 'package:flutter/foundation.dart';

/// Logging service for app-wide logging with levels.
class LoggerService {
  static const String _tag = 'Kitcha';

  /// Log debug message (only in debug mode).
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$_tag] 🔍 DEBUG: $message');
      if (error != null) print('  Error: $error');
      if (stackTrace != null) print('  Stack: $stackTrace');
    }
  }

  /// Log info message.
  static void info(String message, [Map<String, dynamic>? data]) {
    print('[$_tag] ℹ️ INFO: $message');
    if (data != null && kDebugMode) {
      print('  Data: $data');
    }
  }

  /// Log warning message.
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    print('[$_tag] ⚠️ WARNING: $message');
    if (error != null) print('  Error: $error');
    if (stackTrace != null && kDebugMode) print('  Stack: $stackTrace');
  }

  /// Log error message.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('[$_tag] ❌ ERROR: $message');
    if (error != null) print('  Error: $error');
    if (stackTrace != null) print('  Stack: $stackTrace');

    // In production, send to error tracking service
    if (!kDebugMode) {
      _reportToErrorTracking(message, error, stackTrace);
    }
  }

  /// Log fatal error.
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    print('[$_tag] 💀 FATAL: $message');
    if (error != null) print('  Error: $error');
    if (stackTrace != null) print('  Stack: $stackTrace');

    // Always report fatal errors
    _reportToErrorTracking(message, error, stackTrace);
  }

  /// Log API call.
  static void api(String method, String url, {int? statusCode, int? durationMs}) {
    final status = statusCode != null ? ' [$statusCode]' : '';
    final duration = durationMs != null ? ' (${durationMs}ms)' : '';
    print('[$_tag] 🌐 API: $method $url$status$duration');
  }

  /// Log user action.
  static void action(String action, [Map<String, dynamic>? params]) {
    print('[$_tag] 👤 ACTION: $action');
    if (params != null && kDebugMode) {
      print('  Params: $params');
    }
  }

  /// Log performance metric.
  static void performance(String operation, int durationMs) {
    final emoji = durationMs < 100 ? '🚀' : durationMs < 500 ? '⚡' : '🐌';
    print('[$_tag] $emoji PERF: $operation took ${durationMs}ms');
  }

  static void _reportToErrorTracking(
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    // In production, use Sentry or similar:
    // Sentry.captureException(error ?? Exception(message), stackTrace: stackTrace);
    print('[$_tag] 📤 Reported to error tracking');
  }
}
