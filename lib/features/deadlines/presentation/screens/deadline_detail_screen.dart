import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/deadline_item.dart';
import '../../domain/providers/deadlines_provider.dart';
import '../../../../shared/widgets/deadline_animation/deadline_animation_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';

class DeadlineDetailScreen extends ConsumerStatefulWidget {
  final int deadlineId;
  const DeadlineDetailScreen({super.key, required this.deadlineId});

  @override
  ConsumerState<DeadlineDetailScreen> createState() =>
      _DeadlineDetailScreenState();
}

class _DeadlineDetailScreenState extends ConsumerState<DeadlineDetailScreen> {
  late Timer _timer;
  late String _countdown;
  DeadlineItem? _deadline;

  @override
  void initState() {
    super.initState();
    _countdown = '';
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_deadline != null && mounted) {
        setState(
            () => _countdown = AppDateUtils.countdownText(_deadline!.dueDate));
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deadlinesAsync = ref.watch(deadlinesNotifierProvider);

    return deadlinesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (deadlines) {
        final d = deadlines.firstWhere(
          (dl) => dl.id == widget.deadlineId,
          orElse: () => DeadlineItem()
            ..title = 'Bulunamadı'
            ..dueDate = DateTime.now()
            ..isCompleted = false
            ..priority = 0
            ..createdAt = DateTime.now(),
        );
        _deadline = d;
        final urgencyColor = AppColors.urgencyColor(d.daysRemaining);
        final progress = AppDateUtils.deadlineProgress(d.createdAt, d.dueDate);

        if (_countdown.isEmpty) {
          _countdown = AppDateUtils.countdownText(d.dueDate);
        }

        const priorityLabels = ['Düşük', 'Orta', 'Yüksek', 'Kritik'];

        return Scaffold(
          appBar: AppBar(
            title: Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/deadlines/edit/${d.id}'),
              ),
              if (!d.isCompleted)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: Colors.green,
                  onPressed: () => ref
                      .read(deadlinesNotifierProvider.notifier)
                      .markCompleted(d.id),
                ),
            ],
          ),
          body: ListView(
            children: [
              // Full animation — transparent, theme-aware
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: DeadlineAnimationWidget(
                  dueDate: d.dueDate,
                  isMini: false,
                  cycleDuration: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // Countdown
                    Text(
                      _countdown,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: urgencyColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: urgencyColor.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(urgencyColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(
                      label: 'Son Tarih',
                      value: AppDateUtils.formatDateTime(d.dueDate),
                    ),
                    _InfoRow(
                      label: 'Öncelik',
                      value: priorityLabels[d.priority.clamp(0, 3)],
                      valueColor: AppColors.priorityColor(d.priority),
                    ),
                    _InfoRow(
                      label: 'Durum',
                      value: d.isCompleted ? 'Tamamlandı' : 'Devam ediyor',
                      valueColor:
                          d.isCompleted ? Colors.green : urgencyColor,
                    ),
                    if (d.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 16),
                      const Text('Açıklama',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(d.description!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(color: valueColor),
          ),
        ],
      ),
    );
  }
}
