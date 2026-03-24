import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/deadlines/data/models/deadline_item.dart';
import '../../features/notes/data/models/note.dart';
import '../../features/tasks/data/models/task.dart';

@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  print('==== widgetBackgroundCallback Triggered for URI: $uri ====');
  
  await HomeWidget.setAppGroupId('com.akburak.deadline');

  final dir = await getApplicationDocumentsDirectory();
  final isar = Isar.getInstance('deadline_db') ?? 
      await Isar.open(
        [DeadlineItemSchema, NoteSchema, TaskSchema, SubTaskItemSchema],
        directory: dir.path,
        name: 'deadline_db',
      );

  if (uri?.host == 'toggleTask') {
    final idStr = uri?.queryParameters['id'];
    if (idStr != null) {
      final taskId = int.tryParse(idStr);
      if (taskId != null) {
        final task = await isar.tasks.get(taskId);
        if (task != null) {
          task.isCompleted = !task.isCompleted;
          await isar.writeTxn(() async {
            await isar.tasks.put(task);
          });
        }
      }
    }
  } else if (uri?.host == 'toggleSubTask') {
    final subIdStr = uri?.queryParameters['subTaskId'];
    if (subIdStr != null) {
      final subId = int.tryParse(subIdStr);
      if (subId != null) {
        final sub = await isar.subTaskItems.get(subId);
        if (sub != null) {
          sub.isCompleted = !sub.isCompleted;
          await isar.writeTxn(() async {
            await isar.subTaskItems.put(sub);
          });
        }
      }
    }
  }

  // Refresh Widgets regardless of which action
  final activeTasks = await isar.tasks.filter().isCompletedEqualTo(false).findAll();
  for (final t in activeTasks) await t.subTasks.load();
  await WidgetService.updateWidgetWithTasks(activeTasks);
}

class WidgetService {
  static const String deadlineWidgetName = 'DeadlineWidgetProvider';
  static const String taskWidgetName = 'TaskWidgetProvider';
  static const String noteWidgetName = 'NoteWidgetProvider';

  static Future<void> updateWidgetWithDeadlines(List<DeadlineItem> deadlines) async {
    final active = deadlines.where((d) => !d.isCompleted).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    
    final topItems = active.take(3).toList();

    await HomeWidget.saveWidgetData<int>('deadline_count', topItems.length);

    for (int i = 0; i < topItems.length; i++) {
      final item = topItems[i];
      final index = i + 1;
      
      await HomeWidget.saveWidgetData<String>('title_$index', item.title);
      
      final days = item.dueDate.toLocal().difference(DateTime.now()).inDays;
      String timeStr;
      if (days < 0) {
        timeStr = 'GEÇTİ';
      } else if (days == 0) {
        timeStr = 'BUGÜN';
      } else if (days == 1) {
        timeStr = 'YARIN';
      } else {
        timeStr = '$days GÜN';
      }
      
      await HomeWidget.saveWidgetData<String>('time_$index', timeStr);
    }

    await HomeWidget.updateWidget(androidName: deadlineWidgetName);
  }

  static Future<void> updateWidgetWithTasks(List<Task> tasks) async {
    final active = tasks.where((t) => !t.isCompleted).toList()
      ..sort((a, b) {
        if (a.priority != b.priority) return b.priority.compareTo(a.priority);
        return a.createdAt.compareTo(b.createdAt);
      });
    
    final topItems = active.take(3).toList();

    await HomeWidget.saveWidgetData<int>('task_count', topItems.length);

    for (int i = 0; i < topItems.length; i++) {
      final item = topItems[i];
      final index = i + 1;
      
      await HomeWidget.saveWidgetData<String>('task_id_$index', item.id.toString());
      await HomeWidget.saveWidgetData<String>('task_title_$index', item.title);

      // Map subtasks (max 2)
      final subtasks = item.subTasks.toList();
      await HomeWidget.saveWidgetData<int>('task_sub_count_$index', subtasks.length);
      for(int j=0; j<subtasks.length && j<2; j++) {
        final sub = subtasks[j];
        final sidx = j+1;
        await HomeWidget.saveWidgetData<String>('task_sub_id_${index}_$sidx', sub.id.toString());
        await HomeWidget.saveWidgetData<String>('task_sub_title_${index}_$sidx', sub.title);
        await HomeWidget.saveWidgetData<bool>('task_sub_completed_${index}_$sidx', sub.isCompleted);
      }
    }

    await HomeWidget.updateWidget(androidName: taskWidgetName);
  }

  static Future<void> updateWidgetWithNotes(List<Note> notes) async {
    final active = notes.where((n) => !n.isArchived).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    final topItems = active.take(2).toList(); // Layout only supports 2 notes

    await HomeWidget.saveWidgetData<int>('note_count', topItems.length);

    for (int i = 0; i < topItems.length; i++) {
      final item = topItems[i];
      final index = i + 1;
      
      await HomeWidget.saveWidgetData<String>('note_title_$index', item.title);
      await HomeWidget.saveWidgetData<String>('note_content_$index', item.plainTextPreview);
    }

    await HomeWidget.updateWidget(androidName: noteWidgetName);
  }
}
