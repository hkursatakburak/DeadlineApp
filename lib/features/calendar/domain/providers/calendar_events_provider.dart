import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/calendar_event.dart';
import '../../data/repositories/google_calendar_repository.dart';
import '../../data/services/calendar_sync_service.dart';
import '../../../deadlines/data/repositories/deadline_repository.dart';
import '../../../tasks/data/repositories/task_repository.dart';
import 'google_auth_provider.dart';

part 'calendar_events_provider.g.dart';

@riverpod
Future<List<CalendarEvent>> calendarEvents(CalendarEventsRef ref) async {
  final authState = ref.watch(googleAuthNotifierProvider);
  if (authState.status != GoogleAuthStatus.signedIn) return [];

  final repo = ref.watch(googleCalendarRepositoryProvider);
  final now = DateTime.now();
  return repo.fetchEvents(
    now.subtract(const Duration(days: 30)),
    now.add(const Duration(days: 30)),
  );
}

@riverpod
CalendarSyncService calendarSyncService(CalendarSyncServiceRef ref) {
  final calRepo = ref.watch(googleCalendarRepositoryProvider);
  final deadlineRepo = ref.watch(deadlineRepositoryProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);
  return CalendarSyncService(
    calendarRepo: calRepo,
    deadlineRepo: deadlineRepo,
    taskRepo: taskRepo,
  );
}
