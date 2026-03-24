import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../calendar/domain/providers/google_auth_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../tasks/domain/providers/tasks_provider.dart';
import '../../../deadlines/domain/providers/deadlines_provider.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import '../../../deadlines/presentation/screens/deadlines_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(googleAuthNotifierProvider);
    final isSignedIn = authState.status == GoogleAuthStatus.signedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
        actions: [
          if (isSignedIn)
            authState.status == GoogleAuthStatus.loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.sync),
                    tooltip: 'Senkronize Et',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Senkronize ediliyor...')),
                      );
                    },
                  )
          else
            TextButton.icon(
              icon: const Icon(Icons.add_link),
              label: const Text('Google ile Bağlan'),
              onPressed: () =>
                  ref.read(googleAuthNotifierProvider.notifier).signIn(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Month calendar header
          _MonthCalendarWidget(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: (day) => setState(() => _selectedDay = day),
            onForward: () => setState(() => _focusedDay =
                DateTime(_focusedDay.year, _focusedDay.month + 1)),
            onBack: () => setState(() => _focusedDay =
                DateTime(_focusedDay.year, _focusedDay.month - 1)),
          ),
          const Divider(height: 1),
          // Day detail
          Expanded(
            child: _DayDetailPanel(selectedDay: _selectedDay),
          ),
        ],
      ),
    );
  }
}

class _MonthCalendarWidget extends ConsumerWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onForward;
  final VoidCallback onBack;

  const _MonthCalendarWidget({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onForward,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksData = ref.watch(tasksNotifierProvider).valueOrNull ?? [];
    final deadlinesData = ref.watch(deadlinesNotifierProvider).valueOrNull ?? [];
    
    final daysInMonth =
        DateTime(focusedDay.year, focusedDay.month + 1, 0).day;
    final firstWeekday =
        DateTime(focusedDay.year, focusedDay.month, 1).weekday % 7;

    final monthName = _monthName(focusedDay.month);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.chevron_left), onPressed: onBack),
              Expanded(
                child: Text(
                  '$monthName ${focusedDay.year}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: onForward),
            ],
          ),
        ),
        // Weekday labels
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _DayLabel('Paz'), _DayLabel('Pzt'), _DayLabel('Sal'),
              _DayLabel('Çar'), _DayLabel('Per'), _DayLabel('Cum'),
              _DayLabel('Cmt'),
            ],
          ),
        ),
        // Day grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (ctx, i) {
              if (i < firstWeekday) return const SizedBox.shrink();
              final day = i - firstWeekday + 1;
              final date =
                  DateTime(focusedDay.year, focusedDay.month, day);
              final isSelected = selectedDay.day == day &&
                  selectedDay.month == focusedDay.month &&
                  selectedDay.year == focusedDay.year;
              final isToday = DateTime.now().day == day &&
                  DateTime.now().month == focusedDay.month &&
                  DateTime.now().year == focusedDay.year;

              final hasTask = tasksData.any((t) => 
                  t.dueDate != null && 
                  t.dueDate!.year == date.year && 
                  t.dueDate!.month == date.month && 
                  t.dueDate!.day == date.day && 
                  !t.isCompleted);
                  
              final hasDeadline = deadlinesData.any((d) => 
                  d.dueDate.year == date.year && 
                  d.dueDate.month == date.month && 
                  d.dueDate.day == date.day && 
                  !d.isCompleted);

              return GestureDetector(
                onTap: () => onDaySelected(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(ctx).colorScheme.primary
                        : null,
                    border: isToday && !isSelected
                        ? Border.all(
                            color: Theme.of(ctx).colorScheme.primary)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : null,
                          fontSize: 13,
                        ),
                      ),
                      if (hasTask || hasDeadline)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasTask)
                              Container(margin: const EdgeInsets.only(top: 2, right: 1), width: 4, height: 4, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                            if (hasDeadline)
                              Container(margin: const EdgeInsets.only(top: 2, left: 1), width: 4, height: 4, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return months[month];
  }
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );
}

class _DayDetailPanel extends ConsumerWidget {
  final DateTime selectedDay;
  const _DayDetailPanel({required this.selectedDay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksData = ref.watch(tasksNotifierProvider).valueOrNull ?? [];
    final deadlinesData = ref.watch(deadlinesNotifierProvider).valueOrNull ?? [];

    final dayTasks = tasksData.where((t) => t.dueDate != null && t.dueDate!.year == selectedDay.year && t.dueDate!.month == selectedDay.month && t.dueDate!.day == selectedDay.day && !t.isCompleted).toList();
    final dayDeadlines = deadlinesData.where((d) => d.dueDate.year == selectedDay.year && d.dueDate.month == selectedDay.month && d.dueDate.day == selectedDay.day && !d.isCompleted).toList();

    if (dayTasks.isEmpty && dayDeadlines.isEmpty) {
      return Center(
        child: Text(
          'Seçili gün: ${AppDateUtils.formatDate(selectedDay)}\nBugün için etkinlik bulunmuyor.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${AppDateUtils.formatDate(selectedDay)} Etkinlikleri',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        if (dayDeadlines.isNotEmpty) ...[
          const Text('DEADLINES', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          ...dayDeadlines.map((d) => DeadlineCard(
                deadline: d,
                onTap: () => context.go('/deadlines/detail/${d.id}'),
              )),
          const SizedBox(height: 16),
        ],
        if (dayTasks.isNotEmpty) ...[
          const Text('GÖREVLER', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          ...dayTasks.map((t) => TaskTile(
                task: t,
                onComplete: (v) => ref.read(tasksNotifierProvider.notifier).markCompleted(t.id, v ?? false),
                onDelete: () => ref.read(tasksNotifierProvider.notifier).delete(t.id),
                onLongPress: () {},
              )),
        ],
      ],
    );
  }
}
