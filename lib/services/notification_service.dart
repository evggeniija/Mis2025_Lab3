import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // Platforms where zonedSchedule is actually supported
  static bool get _isSchedulingSupported {
    if (kIsWeb) return false; // plugin not really for web scheduling
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;

      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      // Windows initialization can be added if needed,
      // but this minimal config already works.
    );

    await _plugin.initialize(initSettings);

    // Timezone data only needed if we're going to schedule
    if (_isSchedulingSupported) {
      tz.initializeTimeZones();
    }
  }

  static Future<void> scheduleDailyRandomMealReminder(
      TimeOfDay timeOfDay) async {
    if (!_isSchedulingSupported) {
      debugPrint(
          '⛔ scheduleDailyRandomMealReminder: scheduling not supported on this platform.');
      return;
    }

    // Use TZDateTime directly in local timezone
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    // If the time today has already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_random_meal_channel',
      'Daily Random Meal',
      channelDescription: 'Daily reminder to open app and see random meal',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.zonedSchedule(
      0,
      'Random recipe of the day',
      'Open the app to discover today\'s random meal!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
