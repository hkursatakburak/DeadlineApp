import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/task.dart';
import '../../../../shared/providers/isar_provider.dart';

part 'task_repository.g.dart';

@Riverpod(keepAlive: true)
TaskRepository taskRepository(TaskRepositoryRef ref) {
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) throw StateError('Isar not ready');
  return TaskRepository(isar);
}

class TaskRepository {
  final Isar _isar;
  const TaskRepository(this._isar);

  Future<List<Task>> getAll() async {
    final tasks = await _isar.tasks.where().findAll();
    for (final t in tasks) {
      await t.subTasks.load();
    }
    return tasks;
  }

  Stream<List<Task>> watchAll() =>
      _isar.tasks.where().watch(fireImmediately: true);

  Future<Task?> getById(int id) async {
    final task = await _isar.tasks.get(id);
    if (task != null) await task.subTasks.load();
    return task;
  }

  Future<int> save(Task task, List<SubTaskItem> subItems) async {
    return _isar.writeTxn(() async {
      // Save subtasks first
      for (final s in subItems) {
        await _isar.subTaskItems.put(s);
      }
      task.subTasks.addAll(subItems);
      final id = await _isar.tasks.put(task);
      await task.subTasks.save();
      return id;
    });
  }

  Future<bool> delete(int id) async {
    return _isar.writeTxn(() async {
      final task = await _isar.tasks.get(id);
      if (task != null) {
        await task.subTasks.load();
        await _isar.subTaskItems.deleteAll(
          task.subTasks.map((s) => s.id).toList(),
        );
      }
      return _isar.tasks.delete(id);
    });
  }

  Future<void> markCompleted(int id, bool completed) async {
    final task = await _isar.tasks.get(id);
    if (task != null) {
      task.isCompleted = completed;
      await _isar.writeTxn(() => _isar.tasks.put(task));
    }
  }

  Future<void> toggleSubTask(int taskId, int subTaskId) async {
    final sub = await _isar.subTaskItems.get(subTaskId);
    if (sub != null) {
      sub.isCompleted = !sub.isCompleted;
      await _isar.writeTxn(() => _isar.subTaskItems.put(sub));
    }
  }
}
