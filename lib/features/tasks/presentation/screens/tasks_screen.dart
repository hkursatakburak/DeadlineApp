import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/task.dart';
import '../../domain/providers/tasks_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/theme/app_colors.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final notifier = ref.read(tasksNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Görevler')),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('Hata: ${e.toString()}'),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: () => ref.invalidate(tasksNotifierProvider),
                  child: const Text('Tekrar Dene')),
            ],
          ),
        ),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.checklist, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Henüz görev yok', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final now = DateTime.now();
          final today = tasks.where((t) =>
              !t.isCompleted &&
              t.dueDate != null &&
              t.dueDate!.toLocal().day == now.day &&
              t.dueDate!.toLocal().month == now.month).toList();
          final thisWeek = tasks.where((t) =>
              !t.isCompleted &&
              t.dueDate != null &&
              t.dueDate!.toLocal().isAfter(now) &&
              t.dueDate!.toLocal().difference(now).inDays <= 7 &&
              !today.contains(t)).toList();
          final later = tasks.where((t) =>
              !t.isCompleted &&
              (t.dueDate == null ||
                  t.dueDate!.toLocal().difference(now).inDays > 7)).toList();
          final done = tasks.where((t) => t.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (today.isNotEmpty)
                ..._section(context, 'Bugün', today, notifier, ref),
              if (thisWeek.isNotEmpty)
                ..._section(context, 'Bu Hafta', thisWeek, notifier, ref),
              if (later.isNotEmpty)
                ..._section(context, 'Daha Sonra', later, notifier, ref),
              if (done.isNotEmpty)
                ..._section(context, 'Tamamlanan', done, notifier, ref),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/tasks/create'),
        icon: const Icon(Icons.add),
        label: const Text('Görev Ekle'),
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    String title,
    List<Task> tasks,
    TasksNotifier notifier,
    WidgetRef ref,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      ...tasks.asMap().entries.map((entry) {
        final i = entry.key;
        final task = entry.value;
        return _TaskTile(
          task: task,
          onComplete: (v) => notifier.markCompleted(task.id, v ?? false),
          onDelete: () async {
            await notifier.delete(task.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${task.title} silindi'),
                  action: SnackBarAction(
                    label: 'Geri Al',
                    onPressed: () {
                      // Undo not implemented in this version
                    },
                  ),
                ),
              );
            }
          },
        ).animate().fadeIn(delay: (i * 30).ms).slideX(begin: -0.1);
      }),
    ];
  }
}

class _TaskTile extends StatefulWidget {
  final Task task;
  final ValueChanged<bool?> onComplete;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final priority = widget.task.priority;
    final color = AppColors.priorityColor(priority);

    return Dismissible(
      key: Key('task_${widget.task.id}'),
      background: Container(
        color: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          widget.onComplete(true);
        } else {
          widget.onDelete();
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            ListTile(
              leading: Checkbox(
                value: widget.task.isCompleted,
                onChanged: widget.onComplete,
                activeColor: AppColors.deadlineRed,
              ),
              title: Text(
                widget.task.title,
                style: TextStyle(
                  decoration: widget.task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: widget.task.isCompleted ? Colors.grey : null,
                ),
              ),
              subtitle: widget.task.dueDate != null
                  ? Text(
                      AppDateUtils.countdownText(widget.task.dueDate!),
                      style: TextStyle(fontSize: 11, color: color),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  if (widget.task.subTasks.isNotEmpty)
                    IconButton(
                      icon: Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more),
                      onPressed: () =>
                          setState(() => _expanded = !_expanded),
                    ),
                ],
              ),
            ),
            if (_expanded && widget.task.subTasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 32, right: 16, bottom: 8),
                child: Column(
                  children: widget.task.subTasks
                      .map((sub) => CheckboxListTile(
                            title: Text(sub.title,
                                style: TextStyle(
                                    fontSize: 13,
                                    decoration: sub.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null)),
                            value: sub.isCompleted,
                            onChanged: (_) {},
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const _priorityLabels = ['Düşük', 'Orta', 'Yüksek', 'Kritik'];
