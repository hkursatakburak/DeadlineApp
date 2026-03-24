import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'features/deadlines/data/models/deadline_item.dart';
import 'features/notes/data/models/note.dart';
import 'features/tasks/data/models/task.dart';
import 'shared/providers/isar_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'features/calendar/domain/providers/google_auth_provider.dart';
import 'features/settings/presentation/providers/daily_summary_provider.dart';
import 'features/settings/presentation/providers/deadline_reminders_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Turkish locale
  await initializeDateFormatting('tr', null);

  // Isar DB
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [DeadlineItemSchema, NoteSchema, TaskSchema, SubTaskItemSchema],
    directory: dir.path,
    name: 'deadline_db',
  );

  // Notifications
  await NotificationService().init();
  await NotificationService().requestPermissions();

  final container = ProviderContainer(
    overrides: [
      isarProvider.overrideWith((ref) async => isar),
    ],
  );

  // Init settings providers
  await container.read(themeModeNotifierProvider.notifier).init();
  await container.read(dailySummaryProvider.notifier).init();
  await container.read(deadlineRemindersProvider.notifier).init();

  // Silent Google sign-in
  container.read(googleAuthNotifierProvider.notifier).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DeadlineApp(),
    ),
  );
}
