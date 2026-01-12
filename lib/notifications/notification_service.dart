import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();


    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final initialized = await _notifications.initialize(initSettings);
    print('🔧 Notification initialization result: $initialized');

    _initialized = true;
  }

  static Future<bool> requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  static Future<void> scheduleWateringNotifications({
    required String plantName,
    required List<String> wateringTimes,
    required String plantId,
  }) async {
    await initialize();

    await cancelPlantNotifications(plantId);

    for (int i = 0; i < wateringTimes.length; i++) {
      final time = wateringTimes[i];
      final notificationId = _generateNotificationId(plantId, i);

      await _scheduleRepeatingNotification(
        id: notificationId,
        title: '💧 Time to water your plant!',
        body: 'Don\'t forget to water $plantName',
        time: time,
      );
    }
  }

  static Future<void> _scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required String time, // Format: "7:00 AM"
  }) async {
    final timeComponents = _parseTime(time);
    if (timeComponents == null) {
      return;
    }

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeComponents['hour']!,
      timeComponents['minute']!,
    );

    if (scheduledDateTime.isBefore(DateTime.now())) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    } else {
      print('📅 Scheduling for today: $scheduledDateTime');
    }

    final scheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'watering_reminders',
          'Watering Reminders',
          channelDescription:
              'Notifications to remind you to water your plants',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print('✅ Notification scheduled successfully with ID: $id for time: $time');
  }

  static Map<String, int>? _parseTime(String timeString) {
    try {
      // Parse time like "7:00 AM" or "1:00 PM"
      final parts = timeString.split(' ');
      if (parts.length != 2) return null;

      final timePart = parts[0];
      final amPm = parts[1].toUpperCase();

      final timeComponents = timePart.split(':');
      if (timeComponents.length != 2) return null;

      int hour = int.parse(timeComponents[0]);
      final minute = int.parse(timeComponents[1]);

      if (amPm == 'PM' && hour != 12) {
        hour += 12;
      } else if (amPm == 'AM' && hour == 12) {
        hour = 0;
      }

      return {'hour': hour, 'minute': minute};
    } catch (e) {
      return null;
    }
  }

  static int _generateNotificationId(String plantId, int timeIndex) {
    // Generate a unique ID based on plant ID and time index
    return (plantId.hashCode + timeIndex).abs() % 2147483647;
  }

  static Future<void> cancelPlantNotifications(String plantId) async {
    // Cancel up to 3 notifications per plant (max times per day)
    for (int i = 0; i < 3; i++) {
      final notificationId = _generateNotificationId(plantId, i);
      await _notifications.cancel(notificationId);
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
