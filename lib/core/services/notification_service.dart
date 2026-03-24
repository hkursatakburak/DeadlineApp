import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/deadlines/data/models/deadline_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  static const reminders = [
    (days: 7, emoji: '📅', suffix: 'için 7 gün kaldı'),
    (days: 3, emoji: '⚠️', suffix: 'için 3 gün kaldı!'),
    (days: 1, emoji: '🚨', suffix: 'YARIN son gün!'),
    (days: 0, emoji: '☠️', suffix: 'bugün bitiyor!'),
  ];

  Future<void> scheduleDeadlineReminders(DeadlineItem deadline) async {
    await cancelDeadlineNotifications(deadline.id);

    final dueDate = deadline.dueDate.toLocal();
    final now = DateTime.now();

    for (final r in reminders) {
      final scheduleTime = r.days == 0
          ? DateTime(dueDate.year, dueDate.month, dueDate.day, 9, 0)
          : dueDate.subtract(Duration(days: r.days));

      if (scheduleTime.isAfter(now)) {
        final notifId = deadline.id * 10 + r.days;
        await _plugin.zonedSchedule(
          notifId,
          '${r.emoji} ${deadline.title}',
          '${deadline.title} ${r.suffix}',
          tz.TZDateTime.from(scheduleTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'deadlines',
              'Deadline Hatırlatıcıları',
              channelDescription: 'Deadline yaklaşım bildirimleri',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> scheduleDailySummary(int hour, int minute) async {
    await _plugin.cancel(9999);
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      9999,
      'Günlük Özet',
      'Bugünün görev ve deadline\'larını kontrol et',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Günlük Özet',
          channelDescription: 'Günlük görev özet bildirimi',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDeadlineNotifications(int deadlineId) async {
    for (final r in reminders) {
      await _plugin.cancel(deadlineId * 10 + r.days);
    }
  }

  Future<void> cancelAllDeadlineNotifications() async {
    // Flutter Local Notifications doesn't have a direct "cancel by channel"
    // but we can loop through the platform-specific calls if we really needed to.
    // However, the most robust way in this app since we know our ID scheme
    // and if we don't have a list of all IDs, is to just use cancelAll()
    // and then re-schedule the daily summary if it was enabled.
    // But since the user specifically asked for this, and we might add more notifications,
    // it's better to just cancel all and let the caller handle dependencies.
    // Wait, cancelAll() is nuclear.
    
    // Better: The caller (provider) will iterate active deadlines and cancel them.
    // Or we provide a way to cancel EVERYTHING and let the app re-init.
    
    // Let's implement it by canceling ALL and letting the user know it might affect others,
    // OR just use a very large loop if we don't have the list.
    // Actually, I'll fetch the list of pending notifications and cancel those with math logic.
    
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      // IDs for deadlines always end in 7, 3, 1, or 0.
      // IDs are (deadline.id * 10) + r.days.
      final days = p.id % 10;
      if ([0, 1, 3, 7].contains(days) && p.id != 9999) {
        await _plugin.cancel(p.id);
      }
    }
  }

  Future<void> cancelDailySummary() async {
    await _plugin.cancel(9999);
  }

  Future<void> testNotification() async {
    try {
      debugPrint('🚨 TEST: Scheduling 5-second notification...');
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(const Duration(seconds: 5));
      debugPrint('🚨 TEST: Will schedule at $scheduledDate');

      await _plugin.zonedSchedule(
        8888,
        'TEST BİLDİRİM',
        'Bu bir deneme bildirimidir!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test',
            channelDescription: 'Test notifications',
            importance: Importance.max,
            priority: Priority.max,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('🚨 TEST: Notification scheduled successfully.');
    } catch (e) {
      debugPrint('🚨 TEST NOTIFICATION ERROR: $e');
    }
  }
}
