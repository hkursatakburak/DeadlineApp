import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/deadline_item.dart';
import '../../domain/providers/deadlines_provider.dart';
import '../../../../core/theme/app_colors.dart';

class DeadlineCreateScreen extends ConsumerStatefulWidget {
  final int? deadlineId;
  const DeadlineCreateScreen({super.key, this.deadlineId});

  @override
  ConsumerState<DeadlineCreateScreen> createState() =>
      _DeadlineCreateScreenState();
}

class _DeadlineCreateScreenState extends ConsumerState<DeadlineCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  int _priority = 1;

  @override
  void initState() {
    super.initState();
    if (widget.deadlineId != null) {
      Future.microtask(() => _loadExistingDeadline());
    }
  }

  void _loadExistingDeadline() {
    final deadlines = ref.read(deadlinesNotifierProvider).valueOrNull;
    if (deadlines != null) {
      final item = deadlines.firstWhere(
        (d) => d.id == widget.deadlineId,
        orElse: () => throw Exception('Deadline bulunamadı'),
      );
      _titleCtrl.text = item.title;
      _descCtrl.text = item.description ?? '';
      setState(() {
        _dueDate = item.dueDate.toLocal();
        _dueTime = TimeOfDay.fromDateTime(item.dueDate.toLocal());
        _priority = item.priority;
      });
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (d != null && mounted) {
      setState(() => _dueDate = d);
      final t = await showTimePicker(
        context: context,
        initialTime: _dueTime ?? const TimeOfDay(hour: 23, minute: 59),
      );
      if (t != null && mounted) setState(() => _dueTime = t);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bitiş tarihi seçin')),
      );
      return;
    }

    final due = DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _dueTime?.hour ?? 23,
      _dueTime?.minute ?? 59,
    ).toUtc();

    final existingDeadlines = ref.read(deadlinesNotifierProvider).valueOrNull;
    final item = (widget.deadlineId != null && existingDeadlines != null)
        ? existingDeadlines.firstWhere((d) => d.id == widget.deadlineId)
        : DeadlineItem();

    if (widget.deadlineId == null) {
      item.createdAt = DateTime.now().toUtc();
      item.isCompleted = false;
    }

    item
      ..title = _titleCtrl.text.trim()
      ..description =
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim()
      ..dueDate = due
      ..priority = _priority;

    await ref.read(deadlinesNotifierProvider.notifier).saveDeadline(item);
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    if (widget.deadlineId == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silinsin mi?'),
        content: const Text('Bu deadline kalıcı olarak silinecektir.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref
          .read(deadlinesNotifierProvider.notifier)
          .delete(widget.deadlineId!);
      if (mounted) {
        // Pop edit screen AND detail screen to return to list
        context.pop();
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priorityLabels = ['Düşük', 'Orta', 'Yüksek', 'Kritik'];

    String dueDateText = 'Tarih ve saat seç';
    if (_dueDate != null) {
      final d = _dueDate!;
      final t = _dueTime;
      dueDateText =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'
          '${t != null ? ' ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}' : ''}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deadlineId != null ? 'Düzenle' : 'Yeni Deadline'),
        actions: [
          if (widget.deadlineId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _delete,
            ),
          TextButton(onPressed: _save, child: const Text('Kaydet')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Başlık *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Başlık gerekli' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Açıklama'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.event),
              title: Text(dueDateText),
              onTap: _pickDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Öncelik',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: List.generate(
                4,
                (i) => ButtonSegment(
                  value: i,
                  label: Text(priorityLabels[i]),
                  icon: Icon(Icons.circle,
                       color: AppColors.priorityColor(i), size: 12),
                ),
              ),
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
