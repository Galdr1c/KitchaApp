import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'logger_service.dart';

/// Service for monitoring network connectivity.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivityController = StreamController<bool>.broadcast();
  bool _isOnline = true;
  Timer? _checkTimer;

  /// Stream of connectivity changes.
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status.
  bool get isOnline => _isOnline;

  /// Initialize connectivity monitoring.
  void initialize() {
    _checkConnectivity();
    _checkTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );
  }

  /// Check connectivity now.
  Future<bool> checkConnectivity() async {
    return _checkConnectivity();
  }

  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (online != _isOnline) {
        _isOnline = online;
        _connectivityController.add(online);
        LoggerService.info('Connectivity changed: ${online ? "online" : "offline"}');
      }

      return online;
    } catch (e) {
      if (_isOnline) {
        _isOnline = false;
        _connectivityController.add(false);
        LoggerService.info('Connectivity changed: offline');
      }
      return false;
    }
  }

  /// Dispose resources.
  void dispose() {
    _checkTimer?.cancel();
    _connectivityController.close();
  }
}
