import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/services/widget_service.dart';
import '../../../settings/presentation/providers/deadline_reminders_provider.dart';
import '../../data/models/deadline_item.dart';
import '../../data/repositories/deadline_repository.dart';

part 'deadlines_provider.g.dart';

@riverpod
class DeadlinesNotifier extends _$DeadlinesNotifier {
  @override
  Future<List<DeadlineItem>> build() async {
    final repo = ref.watch(deadlineRepositoryProvider);
    return repo.getAll();
  }

  Future<void> saveDeadline(DeadlineItem item) async {
    state = const AsyncLoading(); // Use loading during save
    state = await AsyncValue.guard(() async {
      final repo = ref.read(deadlineRepositoryProvider);
      final id = await repo.save(item);
      item.id = id; // Ensure we have the saved ID

      final remindersEnabled = ref.read(deadlineRemindersProvider);
      if (remindersEnabled && !item.isCompleted) {
        await NotificationService().scheduleDeadlineReminders(item);
      } else {
        await NotificationService().cancelDeadlineNotifications(item.id);
      }

      final all = await repo.getAll();
      await WidgetService.updateWidgetWithDeadlines(all);
      return all;
    });
  }

  Future<void> delete(int id) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(deadlineRepositoryProvider);
      await repo.delete(id);
      await NotificationService().cancelDeadlineNotifications(id);
      
      final all = await repo.getAll();
      await WidgetService.updateWidgetWithDeadlines(all);
      return all;
    });
  }

  Future<void> markCompleted(int id) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(deadlineRepositoryProvider);
      await repo.markCompleted(id);
      await NotificationService().cancelDeadlineNotifications(id);
      
      final all = await repo.getAll();
      await WidgetService.updateWidgetWithDeadlines(all);
      return all;
    });
  }
}
