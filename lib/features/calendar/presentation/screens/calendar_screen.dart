import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../calendar/domain/providers/google_auth_provider.dart';
import '../../../../core/utils/date_utils.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
  DateTime _firstDayOfMonth(DateTime dt) => DateTime(dt.year, dt.month, 1);

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

class _MonthCalendarWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : null,
                        fontSize: 13,
                      ),
                    ),
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
    return Center(
      child: Text(
        'Seçili gün: ${AppDateUtils.formatDate(selectedDay)}',
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
