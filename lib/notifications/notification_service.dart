import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    print('🔧 Initializing notifications...');
    print('🌍 Local timezone: ${tz.local}');
    print('🕐 Current time: ${tz.TZDateTime.now(tz.local)}');

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

    return true; // Default to true for other platforms
  }

  static Future<void> scheduleWateringNotifications({
    required String plantName,
    required List<String> wateringTimes,
    required String plantId, // Use createdAt as unique ID
  }) async {
    await initialize();

    // Cancel existing notifications for this plant
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
    print('🕐 Parsing time: $time');
    final timeComponents = _parseTime(time);
    if (timeComponents == null) {
      print('❌ Failed to parse time: $time');
      return;
    }

    print(
      '✅ Parsed time - Hour: ${timeComponents['hour']}, Minute: ${timeComponents['minute']}',
    );

    final now = tz.TZDateTime.now(tz.local);

    // Use DateTime first, then convert to TZDateTime (same as working simple method)
    var scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeComponents['hour']!,
      timeComponents['minute']!,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDateTime.isBefore(DateTime.now())) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
      print(
        '⏭️ Time has passed today, scheduling for tomorrow: $scheduledDateTime',
      );
    } else {
      print('📅 Scheduling for today: $scheduledDateTime');
    }

    // Convert to TZDateTime using the same method as simple notification
    final scheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);
    print('🌍 Final scheduled time with timezone: $scheduledDate');

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

  // Test method to schedule a notification in 5 seconds for debugging
  static Future<void> scheduleTestNotification() async {
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(seconds: 5));

    await _notifications.zonedSchedule(
      999, // Test ID
      '🧪 Test Notification',
      'This is a test notification to verify the system is working',
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print('🧪 Test notification scheduled for 5 seconds from now');
  }

  // Test method to schedule a notification in 1 minute for testing scheduled times
  static Future<void> scheduleTestNotificationInMinute() async {
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(minutes: 1));

    await _notifications.zonedSchedule(
      998, // Test ID
      '⏰ Scheduled Test Notification',
      'This notification was scheduled for 1 minute from creation time',
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print(
      '⏰ Test notification scheduled for 1 minute from now: $scheduledDate',
    );
  }

  // Method to show all pending notifications for debugging
  static Future<void> showPendingNotifications() async {
    final pending = await getPendingNotifications();
    print('📋 Pending notifications: ${pending.length}');
    for (final notification in pending) {
      print(
        '  - ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}',
      );
    }
  }

  // Method to check notification permissions and settings
  static Future<void> checkNotificationStatus() async {
    print('🔍 Checking notification status...');

    // Check if notifications are enabled
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      print('📱 Notifications enabled: $enabled');

      // Check exact alarm permission (Android 12+)
      try {
        final exactAlarmPermission = await androidPlugin
            .canScheduleExactNotifications();
        print('⏰ Exact alarm permission: $exactAlarmPermission');
      } catch (e) {
        print('⚠️ Could not check exact alarm permission: $e');
      }
    }

    final pending = await getPendingNotifications();
    print('📋 Total pending notifications: ${pending.length}');
  }

  // Method to test a specific time format
  static Future<void> testTimeFormat(String timeString) async {
    print('🧪 Testing time format: "$timeString"');
    final parsed = _parseTime(timeString);
    if (parsed != null) {
      print(
        '✅ Successfully parsed: Hour=${parsed['hour']}, Minute=${parsed['minute']}',
      );

      // Schedule a test notification with this time for tomorrow
      await initialize();
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        parsed['hour']!,
        parsed['minute']!,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      print('📅 Would schedule for: $scheduledDate');
    } else {
      print('❌ Failed to parse time format');
    }
  }

  // Comprehensive test method for custom times
  static Future<void> testCustomTimeFlow() async {
    print('🧪 === TESTING CUSTOM TIME FLOW ===');

    // Test 1: Time parsing
    final testTimes = ['7:30 AM', '2:15 PM', '11:45 PM'];
    for (final timeStr in testTimes) {
      print('🧪 Testing time: $timeStr');
      final parsed = _parseTime(timeStr);
      if (parsed != null) {
        print('  ✅ Parsed: Hour=${parsed['hour']}, Minute=${parsed['minute']}');
      } else {
        print('  ❌ Failed to parse');
      }
    }

    // Test 2: Schedule a test notification for 1 minute from now
    final now = tz.TZDateTime.now(tz.local);
    final testTime = now.add(const Duration(minutes: 1));
    final timeString =
        '${testTime.hour > 12 ? testTime.hour - 12 : (testTime.hour == 0 ? 12 : testTime.hour)}:${testTime.minute.toString().padLeft(2, '0')} ${testTime.hour >= 12 ? 'PM' : 'AM'}';

    print('🧪 Scheduling test notification for: $timeString');

    await scheduleWateringNotifications(
      plantName: 'Test Plant',
      wateringTimes: [timeString],
      plantId: 'test-custom-${DateTime.now().millisecondsSinceEpoch}',
    );

    print('🧪 === TEST COMPLETE ===');
  }

  // Simple immediate notification test
  static Future<void> showImmediateNotification() async {
    await initialize();

    print('🔔 Showing immediate notification...');

    await _notifications.show(
      997, // Test ID
      '🚨 Immediate Test Notification',
      'This notification should appear immediately',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'watering_reminders',
          'Watering Reminders',
          channelDescription:
              'Notifications to remind you to water your plants',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    print('🔔 Immediate notification sent');
  }

  // Alternative scheduling method using simple delay
  static Future<void> scheduleSimpleNotification({
    required String plantName,
    required int delayMinutes,
  }) async {
    await initialize();

    print('🔔 Scheduling simple notification in $delayMinutes minutes');

    final now = DateTime.now();
    final scheduledTime = now.add(Duration(minutes: delayMinutes));

    await _notifications.zonedSchedule(
      996, // Test ID
      '💧 Simple Test Notification',
      'Water $plantName - scheduled $delayMinutes minutes ago',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'watering_reminders',
          'Watering Reminders',
          channelDescription:
              'Notifications to remind you to water your plants',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print('🔔 Simple notification scheduled for: $scheduledTime');
  }

  // Test custom time scheduling with the fixed method
  static Future<void> testFixedCustomTime() async {
    await initialize();

    print('🧪 Testing fixed custom time scheduling...');

    // Test with a time 2 minutes from now
    final now = DateTime.now();
    final testTime = now.add(const Duration(minutes: 2));
    final timeString =
        '${testTime.hour > 12 ? testTime.hour - 12 : (testTime.hour == 0 ? 12 : testTime.hour)}:${testTime.minute.toString().padLeft(2, '0')} ${testTime.hour >= 12 ? 'PM' : 'AM'}';

    print('🧪 Testing custom time: $timeString');

    await scheduleWateringNotifications(
      plantName: 'Fixed Test Plant',
      wateringTimes: [timeString],
      plantId: 'fixed-test-${DateTime.now().millisecondsSinceEpoch}',
    );

    print('🧪 Fixed custom time test complete');
  }
}
