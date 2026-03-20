import '../models/calendar_event.dart';
import '../repositories/google_calendar_repository.dart';
import '../../../deadlines/data/repositories/deadline_repository.dart';
import '../../../tasks/data/repositories/task_repository.dart';

/// Bidirectional Google Calendar sync as specified in Section 6.
class CalendarSyncService {
  final GoogleCalendarRepository calendarRepo;
  final DeadlineRepository deadlineRepo;
  final TaskRepository taskRepo;

  CalendarSyncService({
    required this.calendarRepo,
    required this.deadlineRepo,
    required this.taskRepo,
  });

  /// Returns a user-facing result message.
  Future<String> sync() async {
    if (!calendarRepo.isSignedIn) {
      return 'Google oturumu açık değil';
    }

    int updatedCount = 0;

    try {
      final now = DateTime.now();
      final googleEvents = await calendarRepo.fetchEvents(
        now.subtract(const Duration(days: 30)),
        now.add(const Duration(days: 30)),
      );
      final googleEventMap = {for (final e in googleEvents) e.id: e};

      // Step 2: Update local deadlines linked to Google events
      final deadlines = await deadlineRepo.getAll();
      for (final d in deadlines) {
        final gId = d.googleCalendarEventId;
        if (gId == null) continue;

        if (googleEventMap.containsKey(gId)) {
          final gEvent = googleEventMap[gId]!;
          d.title = gEvent.title;
          d.dueDate = gEvent.end ?? gEvent.start;
          d.description = gEvent.description;
          await deadlineRepo.save(d);
          updatedCount++;
        }
      }

      // Step 3: Push local deadlines without eventId to Google
      for (final d in deadlines) {
        if (d.googleCalendarEventId != null) continue;
        // Only push if user had marked "addToGoogle" — we check via null eventId heuristic
        // (In full version, a separate flag would be used)
      }

      // Step 2b: Update local tasks linked to Google events
      final tasks = await taskRepo.getAll();
      for (final t in tasks) {
        final gId = t.googleCalendarEventId;
        if (gId == null) continue;

        if (googleEventMap.containsKey(gId)) {
          final gEvent = googleEventMap[gId]!;
          t.title = gEvent.title;
          t.dueDate = gEvent.end ?? gEvent.start;
          await taskRepo.save(t, []);
          updatedCount++;
        }
      }

      return '$updatedCount etkinlik güncellendi';
    } catch (e) {
      return 'Senkronizasyon hatası: $e';
    }
  }

  /// Create a Google Calendar event for a deadline and store the eventId.
  Future<void> pushDeadlineToGoogle(
      int deadlineId, CalendarEvent event) async {
    if (!calendarRepo.isSignedIn) return;
    final eventId = await calendarRepo.createEvent(event);
    final d = await deadlineRepo.getById(deadlineId);
    if (d != null) {
      d.googleCalendarEventId = eventId;
      await deadlineRepo.save(d);
    }
  }

  /// Create a Google Calendar event for a task and store the eventId.
  Future<void> pushTaskToGoogle(int taskId, CalendarEvent event) async {
    if (!calendarRepo.isSignedIn) return;
    final eventId = await calendarRepo.createEvent(event);
    final t = await taskRepo.getById(taskId);
    if (t != null) {
      t.googleCalendarEventId = eventId;
      await taskRepo.save(t, []);
    }
  }
}
