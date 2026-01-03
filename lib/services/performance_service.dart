import 'logger_service.dart';

/// Service for performance monitoring and tracing.
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, DateTime> _activeTraces = {};

  /// Start a performance trace.
  void startTrace(String name) {
    _activeTraces[name] = DateTime.now();
  }

  /// Stop a trace and log duration.
  int? stopTrace(String name) {
    final startTime = _activeTraces.remove(name);
    if (startTime == null) return null;

    final duration = DateTime.now().difference(startTime).inMilliseconds;
    LoggerService.performance(name, duration);
    return duration;
  }

  /// Execute an async operation with performance tracing.
  Future<T> trace<T>(String name, Future<T> Function() operation) async {
    startTrace(name);
    try {
      final result = await operation();
      stopTrace(name);
      return result;
    } catch (e) {
      stopTrace(name);
      rethrow;
    }
  }

  /// Execute a sync operation with performance tracing.
  T traceSync<T>(String name, T Function() operation) {
    startTrace(name);
    try {
      final result = operation();
      stopTrace(name);
      return result;
    } catch (e) {
      stopTrace(name);
      rethrow;
    }
  }

  /// Measure screen load time.
  void measureScreenLoad(String screenName) {
    startTrace('screen_load_$screenName');
  }

  /// Complete screen load measurement.
  void completeScreenLoad(String screenName) {
    stopTrace('screen_load_$screenName');
  }

  /// Measure API call.
  Future<T> measureApi<T>(
    String endpoint,
    Future<T> Function() apiCall,
  ) async {
    return trace('api_$endpoint', apiCall);
  }

  /// Get current trace count (for debugging).
  int get activeTraceCount => _activeTraces.length;

  /// Clear all active traces.
  void clearTraces() {
    _activeTraces.clear();
  }
}

/// Mixin for screen performance tracking.
mixin ScreenPerformanceMixin {
  String get screenName;

  void trackScreenLoad() {
    PerformanceService().measureScreenLoad(screenName);
  }

  void trackScreenReady() {
    PerformanceService().completeScreenLoad(screenName);
  }
}
