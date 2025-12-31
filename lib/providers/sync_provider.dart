import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_mcp_service.dart';

enum SyncStatus { idle, syncing, error, success }

/// Provider to manage and track Firebase synchronization state
class SyncProvider extends ChangeNotifier {
  final FirebaseMcpService _firebaseMcp = FirebaseMcpService();
  
  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;
  
  double _progress = 0.0;
  double get progress => _progress;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;
  
  bool _autoSync = true;
  bool get autoSync => _autoSync;

  SyncProvider() {
    _loadSyncSettings();
  }

  Future<void> _loadSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString('last_sync_time');
    if (lastSyncStr != null) {
      _lastSyncTime = DateTime.parse(lastSyncStr);
    }
    _autoSync = prefs.getBool('auto_sync') ?? true;
    notifyListeners();
  }

  Future<void> _saveSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lastSyncTime != null) {
      await prefs.setString('last_sync_time', _lastSyncTime!.toIso8601String());
    }
    await prefs.setBool('auto_sync', _autoSync);
  }

  void setAutoSync(bool value) {
    _autoSync = value;
    _saveSyncSettings();
    notifyListeners();
  }

  /// Perform a full user data sync
  Future<void> syncNow() async {
    if (!_firebaseMcp.isAuthenticated) {
      _errorMessage = 'Oturum açılmamış. Lütfen giriş yapın.';
      _status = SyncStatus.error;
      notifyListeners();
      return;
    }

    _status = SyncStatus.syncing;
    _progress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseMcp.syncUserData(
        onProgress: (current, total) {
          _progress = total > 0 ? current / total : 1.0;
          notifyListeners();
        },
      );

      _status = SyncStatus.success;
      _lastSyncTime = DateTime.now();
      await _saveSyncSettings();
      
      // Reset to idle after a few seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (_status == SyncStatus.success) {
          _status = SyncStatus.idle;
          notifyListeners();
        }
      });
      
    } catch (e) {
      _status = SyncStatus.error;
      _errorMessage = 'Senkronizasyon hatası: $e';
      print('[SyncProvider] Sync failed: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Reset sync status
  void clearError() {
    _errorMessage = null;
    _status = SyncStatus.idle;
    notifyListeners();
  }
}
