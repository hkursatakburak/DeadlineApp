import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models/deadline_item.dart';
import '../../domain/providers/deadlines_provider.dart';
import '../../../../shared/widgets/deadline_animation/deadline_animation_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';

class DeadlinesScreen extends ConsumerWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlinesAsync = ref.watch(deadlinesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Deadlines')),
      body: deadlinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (deadlines) {
          final active = deadlines.where((d) => !d.isCompleted).toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

          // Nearest deadline drives the top animation
          final nearest = active.isNotEmpty ? active.first : null;
          // Fallback: 7 days from now when no deadlines exist
          final animDueDate =
              nearest?.dueDate ?? DateTime.now().add(const Duration(days: 7));

          return Column(
            children: [
              // Signature animation — transparent, theme-aware
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: DeadlineAnimationWidget(
                  dueDate: animDueDate,
                  isMini: false,
                  cycleDuration: 20.0,
                ),
              ),
              // List
              Expanded(
                child: deadlines.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Henüz deadline yok',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: deadlines.length,
                        itemBuilder: (ctx, i) => DeadlineCard(
                          deadline: deadlines[i],
                          onTap: () =>
                              context.go('/deadlines/detail/${deadlines[i].id}'),
                        )
                            .animate()
                            .fadeIn(delay: (i * 40).ms)
                            .slideY(begin: 0.2),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/deadlines/create'),
        icon: const Icon(Icons.add),
        label: const Text('Deadline Ekle'),
      ),
    );
  }
}

class DeadlineCard extends StatefulWidget {
  final DeadlineItem deadline;
  final VoidCallback? onTap;

  const DeadlineCard({super.key, required this.deadline, this.onTap});

  @override
  State<DeadlineCard> createState() => _DeadlineCardState();
}

class _DeadlineCardState extends State<DeadlineCard> {
  late Timer _timer;
  late String _countdown;

  @override
  void initState() {
    super.initState();
    _countdown = AppDateUtils.countdownText(widget.deadline.dueDate);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _countdown = AppDateUtils.countdownText(widget.deadline.dueDate);
        });
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
    final d = widget.deadline;
    final days = d.daysRemaining;
    final urgencyColor = AppColors.urgencyColor(days);
    final progress = AppDateUtils.deadlineProgress(d.createdAt, d.dueDate);

    final priorityLabels = ['Düşük', 'Orta', 'Yüksek', 'Kritik'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      d.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.priorityColor(d.priority)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priorityLabels[d.priority.clamp(0, 3)],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.priorityColor(d.priority),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 500),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: urgencyColor,
                ),
                child: Text(_countdown),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: urgencyColor.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(urgencyColor),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              if (d.description?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  d.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
