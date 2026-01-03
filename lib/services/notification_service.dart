import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing push notifications and local notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _prefsKey = 'notification_prefs';

  /// Initialize notification channels and permissions.
  Future<void> initialize() async {
    // In production, initialize firebase_messaging and flutter_local_notifications
    print('[NotificationService] Initialized');
  }

  /// Show a local notification.
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // In production, use flutter_local_notifications package
    print('[NotificationService] Notification: $title - $body');
  }

  /// Schedule a notification.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    print('[NotificationService] Scheduled: $title at $scheduledTime');
  }

  /// Cancel a scheduled notification.
  Future<void> cancelNotification(int id) async {
    print('[NotificationService] Cancelled notification: $id');
  }

  /// Cancel all notifications.
  Future<void> cancelAllNotifications() async {
    print('[NotificationService] Cancelled all notifications');
  }

  /// Get notification preferences.
  Future<NotificationPreferences> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    return NotificationPreferences(
      dailyReminder: prefs.getBool('notif_daily_reminder') ?? true,
      mealReminder: prefs.getBool('notif_meal_reminder') ?? true,
      weeklyDigest: prefs.getBool('notif_weekly_digest') ?? true,
      challengeUpdates: prefs.getBool('notif_challenges') ?? true,
      newRecipes: prefs.getBool('notif_new_recipes') ?? false,
      promotions: prefs.getBool('notif_promotions') ?? false,
      dailyReminderTime: prefs.getString('notif_reminder_time') ?? '09:00',
    );
  }

  /// Save notification preferences.
  Future<void> savePreferences(NotificationPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('notif_daily_reminder', preferences.dailyReminder);
    await prefs.setBool('notif_meal_reminder', preferences.mealReminder);
    await prefs.setBool('notif_weekly_digest', preferences.weeklyDigest);
    await prefs.setBool('notif_challenges', preferences.challengeUpdates);
    await prefs.setBool('notif_new_recipes', preferences.newRecipes);
    await prefs.setBool('notif_promotions', preferences.promotions);
    await prefs.setString('notif_reminder_time', preferences.dailyReminderTime);

    await _updateScheduledNotifications(preferences);
  }

  /// Update scheduled notifications based on preferences.
  Future<void> _updateScheduledNotifications(NotificationPreferences prefs) async {
    if (prefs.dailyReminder) {
      // Schedule daily reminder
      final parts = prefs.dailyReminderTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final now = DateTime.now();
      var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await scheduleNotification(
        id: 1,
        title: '🍽️ Bugün ne pişirelim?',
        body: 'Yeni tarifler seni bekliyor!',
        scheduledTime: scheduledTime,
        payload: '/home',
      );
    } else {
      await cancelNotification(1);
    }
  }

  /// Send meal reminder notification.
  Future<void> sendMealReminder(String mealType, String recipeName) async {
    await showLocalNotification(
      title: '⏰ Öğün Hatırlatması',
      body: '$mealType: $recipeName hazırlamayı unutma!',
      payload: '/meal_plan',
    );
  }

  /// Send badge unlocked notification.
  Future<void> sendBadgeNotification(String badgeName, int xpReward) async {
    await showLocalNotification(
      title: '🏆 Yeni Rozet Kazandın!',
      body: '$badgeName - +$xpReward XP',
      payload: '/achievements',
    );
  }

  /// Send level up notification.
  Future<void> sendLevelUpNotification(int level, String title) async {
    await showLocalNotification(
      title: '🎉 Seviye Atladın!',
      body: 'Artık Seviye $level - $title!',
      payload: '/profile',
    );
  }

  /// Send streak reminder.
  Future<void> sendStreakReminder(int currentStreak) async {
    await showLocalNotification(
      title: '🔥 Seriyi Koruma Zamanı!',
      body: '$currentStreak günlük seriyi kaybetme!',
      payload: '/home',
    );
  }
}

/// User notification preferences.
class NotificationPreferences {
  final bool dailyReminder;
  final bool mealReminder;
  final bool weeklyDigest;
  final bool challengeUpdates;
  final bool newRecipes;
  final bool promotions;
  final String dailyReminderTime;

  const NotificationPreferences({
    this.dailyReminder = true,
    this.mealReminder = true,
    this.weeklyDigest = true,
    this.challengeUpdates = true,
    this.newRecipes = false,
    this.promotions = false,
    this.dailyReminderTime = '09:00',
  });

  NotificationPreferences copyWith({
    bool? dailyReminder,
    bool? mealReminder,
    bool? weeklyDigest,
    bool? challengeUpdates,
    bool? newRecipes,
    bool? promotions,
    String? dailyReminderTime,
  }) {
    return NotificationPreferences(
      dailyReminder: dailyReminder ?? this.dailyReminder,
      mealReminder: mealReminder ?? this.mealReminder,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      challengeUpdates: challengeUpdates ?? this.challengeUpdates,
      newRecipes: newRecipes ?? this.newRecipes,
      promotions: promotions ?? this.promotions,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }
}
