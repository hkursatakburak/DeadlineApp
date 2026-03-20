import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/task.dart';
import '../../domain/providers/tasks_provider.dart';
import '../../../../core/theme/app_colors.dart';

const _priorityLabels = ['Düşük', 'Orta', 'Yüksek', 'Kritik'];

class TaskCreateScreen extends ConsumerStatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  ConsumerState<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends ConsumerState<TaskCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _subTaskCtrl = TextEditingController();

  DateTime? _dueDate;
  int _priority = 0;
  bool _isRepeating = false;
  String? _repeatRule;
  final bool _addToGoogle = false;
  final List<String> _tags = [];
  final List<String> _subTaskTitles = [];

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (d != null) setState(() => _dueDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final task = Task()
      ..title = _titleCtrl.text.trim()
      ..dueDate = _dueDate?.toUtc()
      ..isCompleted = false
      ..priority = _priority
      ..tags = List.from(_tags)
      ..isRepeating = _isRepeating
      ..repeatRule = _isRepeating ? _repeatRule : null
      ..createdAt = DateTime.now().toUtc();

    final subItems = _subTaskTitles
        .map((t) => SubTaskItem()
          ..title = t
          ..isCompleted = false)
        .toList();

    await ref.read(tasksNotifierProvider.notifier).add(task, subItems);
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _tagCtrl.dispose();
    _subTaskCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Görev'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Kaydet')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Başlık *',
                hintText: 'Görev başlığı girin',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Başlık gerekli' : null,
            ),
            const SizedBox(height: 16),

            // Due date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_dueDate == null
                  ? 'Bitiş tarihi seç'
                  : 'Bitiş: ${_dueDate!.toLocal().toString().substring(0, 10)}'),
              onTap: _pickDate,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300)),
            ),
            const SizedBox(height: 16),

            // Priority
            const Text('Öncelik',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: List.generate(
                4,
                (i) => ButtonSegment(
                  value: i,
                  label: Text(_priorityLabels[i]),
                  icon: Icon(Icons.circle,
                      color: AppColors.priorityColor(i), size: 12),
                ),
              ),
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
            const SizedBox(height: 16),

            // Tags
            const Text('Etiketler',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                ..._tags.map((t) => Chip(
                      label: Text(t),
                      onDeleted: () => setState(() => _tags.remove(t)),
                    )),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Etiket ekle', isDense: true),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() {
                          _tags.add(v.trim());
                          _tagCtrl.clear();
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_tagCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _tags.add(_tagCtrl.text.trim());
                        _tagCtrl.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Repeating
            SwitchListTile(
              title: const Text('Tekrarlayan'),
              value: _isRepeating,
              onChanged: (v) => setState(() => _isRepeating = v),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            if (_isRepeating) ...[
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'daily', label: Text('Günlük')),
                  ButtonSegment(value: 'weekly', label: Text('Haftalık')),
                  ButtonSegment(value: 'monthly', label: Text('Aylık')),
                ],
                selected: {_repeatRule ?? 'daily'},
                onSelectionChanged: (s) =>
                    setState(() => _repeatRule = s.first),
              ),
            ],
            const SizedBox(height: 16),

            // Sub-tasks
            const Text('Alt Görevler',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._subTaskTitles.asMap().entries.map((e) => ListTile(
                  leading: const Icon(Icons.subdirectory_arrow_right),
                  title: Text(e.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () =>
                        setState(() => _subTaskTitles.removeAt(e.key)),
                  ),
                  dense: true,
                )),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subTaskCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Alt görev ekle', isDense: true),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() {
                          _subTaskTitles.add(v.trim());
                          _subTaskCtrl.clear();
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_subTaskCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _subTaskTitles.add(_subTaskCtrl.text.trim());
                        _subTaskCtrl.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
