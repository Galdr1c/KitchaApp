import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'connectivity_service.dart';
import 'logger_service.dart';

/// Service for offline-first data synchronization.
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _queueKey = 'sync_queue';
  final ConnectivityService _connectivity = ConnectivityService();

  /// Add action to sync queue.
  Future<void> addToQueue(String action, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = _getQueue(prefs);

    queue.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'retries': 0,
    });

    await prefs.setString(_queueKey, jsonEncode(queue));
    LoggerService.debug('Added to sync queue: $action');

    // Try to sync immediately if online
    if (_connectivity.isOnline) {
      await syncNow();
    }
  }

  /// Sync all queued actions.
  Future<SyncResult> syncNow() async {
    if (!await _connectivity.checkConnectivity()) {
      return SyncResult(synced: 0, failed: 0, remaining: await _queueLength());
    }

    final prefs = await SharedPreferences.getInstance();
    final queue = _getQueue(prefs);

    if (queue.isEmpty) {
      return SyncResult(synced: 0, failed: 0, remaining: 0);
    }

    LoggerService.info('Starting sync: ${queue.length} items');

    int synced = 0;
    int failed = 0;
    final remaining = <Map<String, dynamic>>[];

    for (final item in queue) {
      try {
        await _processItem(item);
        synced++;
        LoggerService.debug('Synced: ${item['action']}');
      } catch (e) {
        final retries = (item['retries'] as int? ?? 0) + 1;
        if (retries < 3) {
          item['retries'] = retries;
          remaining.add(item);
        }
        failed++;
        LoggerService.warning('Sync failed: ${item['action']}', e);
      }
    }

    await prefs.setString(_queueKey, jsonEncode(remaining));

    LoggerService.info('Sync complete: $synced synced, $failed failed, ${remaining.length} remaining');

    return SyncResult(synced: synced, failed: failed, remaining: remaining.length);
  }

  Future<void> _processItem(Map<String, dynamic> item) async {
    if (!FirebaseService.isAvailable) {
      throw Exception('Firebase not available');
    }

    final action = item['action'] as String;
    final data = item['data'] as Map<String, dynamic>;
    final firestore = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception('Not logged in');
    }

    switch (action) {
      case 'add_favorite':
        await firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(data['recipeId'])
            .set(data);
        break;

      case 'remove_favorite':
        await firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(data['recipeId'])
            .delete();
        break;

      case 'add_shopping_item':
        await firestore
            .collection('shopping_lists')
            .doc(userId)
            .collection('items')
            .doc(data['id'])
            .set(data);
        break;

      case 'update_shopping_item':
        await firestore
            .collection('shopping_lists')
            .doc(userId)
            .collection('items')
            .doc(data['id'])
            .update(data);
        break;

      case 'delete_shopping_item':
        await firestore
            .collection('shopping_lists')
            .doc(userId)
            .collection('items')
            .doc(data['id'])
            .delete();
        break;

      case 'add_meal_plan':
        await firestore
            .collection('meal_plans')
            .doc(userId)
            .collection('plans')
            .doc(data['id'])
            .set(data);
        break;

      case 'update_gamification':
        await firestore.collection('users').doc(userId).update({
          'gamification': data,
        });
        break;

      default:
        LoggerService.warning('Unknown sync action: $action');
    }
  }

  List<Map<String, dynamic>> _getQueue(SharedPreferences prefs) {
    final queueJson = prefs.getString(_queueKey);
    if (queueJson == null) return [];

    try {
      return List<Map<String, dynamic>>.from(
        (jsonDecode(queueJson) as List).map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      return [];
    }
  }

  Future<int> _queueLength() async {
    final prefs = await SharedPreferences.getInstance();
    return _getQueue(prefs).length;
  }

  /// Get queue status.
  Future<int> getPendingCount() async {
    return _queueLength();
  }

  /// Clear the sync queue.
  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
    LoggerService.info('Sync queue cleared');
  }
}

/// Result of a sync operation.
class SyncResult {
  final int synced;
  final int failed;
  final int remaining;

  SyncResult({
    required this.synced,
    required this.failed,
    required this.remaining,
  });

  bool get hasErrors => failed > 0;
  bool get hasPending => remaining > 0;
  bool get isComplete => remaining == 0 && failed == 0;
}
