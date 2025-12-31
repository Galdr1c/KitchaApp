import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_config.dart';
import 'memory_mcp_service.dart';

class NotificationMcpService {
  static NotificationMcpService _instance = NotificationMcpService._internal();
  factory NotificationMcpService() => _instance;
  NotificationMcpService._internal();

  @visibleForTesting
  static set instance(NotificationMcpService mock) => _instance = mock;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final MemoryMcpService _memoryMcp = MemoryMcpService();
  
  UserNotificationPreferences _prefs = UserNotificationPreferences();

  Future<void> initialize() async {
    // Load preferences
    await _loadPreferences();

    // 1. Request FCM permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('[NotificationService] User granted permission: ${settings.authorizationStatus}');

    // 2. Initialize Local Notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _localNotifications.initialize(initSettings);

    // 3. Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[NotificationService] Message received in foreground');
      _showLocalNotification(message);
    });
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('[NotificationService] Handling background message: ${message.messageId}');
  }

  Future<void> _loadPreferences() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final String? prefsJson = sharedPrefs.getString('user_notification_preferences');
    if (prefsJson != null) {
      _prefs = UserNotificationPreferences.fromJson(json.decode(prefsJson));
    }
  }

  Future<void> savePreferences(UserNotificationPreferences newPrefs) async {
    _prefs = newPrefs;
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString('user_notification_preferences', json.encode(_prefs.toJson()));
  }

  UserNotificationPreferences get preferences => _prefs;

  // --- Core Methods ---

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (_isInQuietHours()) return;

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'kitcha_smart_alerts',
        'Smart Alerts',
        channelDescription: 'Intelligent cooking and meal reminders',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
      );
    }
  }

  bool _isInQuietHours() {
    final now = DateTime.now();
    final start = _timeToDateTime(_prefs.quietHoursStart);
    final end = _timeToDateTime(_prefs.quietHoursEnd);

    if (start.isBefore(end)) {
      return now.isAfter(start) && now.isBefore(end);
    } else {
      // Overnight (e.g. 22:00 to 08:00)
      return now.isAfter(start) || now.isBefore(end);
    }
  }

  DateTime _timeToDateTime(String timeStr) {
    final parts = timeStr.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Schedule a personalized suggestion using Mem0 data
  Future<void> sendPersonalizedSuggestion() async {
    if (!_prefs.mealSuggestionsEnabled || _isInQuietHours()) return;

    // Get context from memory
    final context = await _memoryMcp.searchContext('yemek tercihi');
    
    // Draft personalized message
    String title = "Kitcha'dan Özel Öneri";
    String body = "Mutfakta vakit geçirme zamanı!";
    
    if (context.toLowerCase().contains('sebze')) {
      body = "Taze sebzelerle bugün hafif bir öğün hazırlamaya ne dersin?";
    } else if (context.toLowerCase().contains('makarna')) {
      body = "Makarna severlere özel yeni bir sos tarifimiz var!";
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'kitcha_personal_tips',
      'Personalized Tips',
      importance: Importance.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      99,
      title,
      body,
      platformDetails,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<String?> getPushToken() async {
    return await _fcm.getToken();
  }
}
