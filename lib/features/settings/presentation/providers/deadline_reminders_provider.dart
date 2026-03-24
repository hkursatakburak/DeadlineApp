import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/notification_service.dart';
import '../../../deadlines/data/repositories/deadline_repository.dart';

class DeadlineRemindersNotifier extends Notifier<bool> {
  static const _key = 'deadline_reminders_enabled';

  @override
  bool build() {
    return true; // Default state
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true;
  }

  Future<void> toggle(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
    state = enabled;

    if (enabled) {
      // Re-arm all active deadlines
      final repo = ref.read(deadlineRepositoryProvider);
      final deadlines = await repo.getAll();
      for (final d in deadlines) {
        if (!d.isCompleted) {
          await NotificationService().scheduleDeadlineReminders(d);
        }
      }
    } else {
      // Cancel all deadline notifications
      await NotificationService().cancelAllDeadlineNotifications();
    }
  }
}

final deadlineRemindersProvider = NotifierProvider<DeadlineRemindersNotifier, bool>(
  () => DeadlineRemindersNotifier(),
);
