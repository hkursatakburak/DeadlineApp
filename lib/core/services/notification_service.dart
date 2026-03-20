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

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDeadlineReminders(DeadlineItem deadline) async {
    await cancelDeadlineNotifications(deadline.id);

    final dueDate = deadline.dueDate.toLocal();
    final now = DateTime.now();

    final reminders = [
      (
        days: 7,
        emoji: '📅',
        suffix: 'için 7 gün kaldı',
      ),
      (
        days: 3,
        emoji: '⚠️',
        suffix: 'için 3 gün kaldı!',
      ),
      (
        days: 1,
        emoji: '🚨',
        suffix: 'YARIN son gün!',
      ),
      (
        days: 0,
        emoji: '☠️',
        suffix: 'bugün bitiyor!',
      ),
    ];

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
    for (final days in [7, 3, 1, 0]) {
      await _plugin.cancel(deadlineId * 10 + days);
    }
  }
}
