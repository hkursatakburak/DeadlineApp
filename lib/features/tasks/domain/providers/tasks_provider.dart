import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/widget_service.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';

part 'tasks_provider.g.dart';

@riverpod
class TasksNotifier extends _$TasksNotifier {
  @override
  Future<List<Task>> build() async {
    final repo = ref.watch(taskRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(Task task, List<SubTaskItem> subTasks) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(taskRepositoryProvider);
      await repo.save(task, subTasks);
      final all = await repo.getAll();
      await WidgetService.updateWidgetWithTasks(all);
      return all;
    });
  }

  Future<void> saveTask(Task task, List<SubTaskItem> subTasks) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(taskRepositoryProvider);
      await repo.save(task, subTasks);
      final all = await repo.getAll();
      await WidgetService.updateWidgetWithTasks(all);
      return all;
    });
  }

  Future<void> delete(int id) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(taskRepositoryProvider);
      await repo.delete(id);
      final all = await repo.getAll();
      await WidgetService.updateWidgetWithTasks(all);
      return all;
    });
  }

  Future<void> markCompleted(int id, bool completed) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(taskRepositoryProvider);
      await repo.markCompleted(id, completed);
      final all = await repo.getAll();
      await WidgetService.updateWidgetWithTasks(all);
      return all;
    });
  }

  Future<void> toggleSubTask(int taskId, int subTaskId) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(taskRepositoryProvider);
      await repo.toggleSubTask(taskId, subTaskId);
      final all = await repo.getAll();
      await WidgetService.updateWidgetWithTasks(all);
      return all;
    });
  }
}
