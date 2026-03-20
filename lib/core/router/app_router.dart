import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/deadlines/presentation/screens/deadline_create_screen.dart';
import '../../features/deadlines/presentation/screens/deadline_detail_screen.dart';
import '../../features/deadlines/presentation/screens/deadlines_screen.dart';
import '../../features/notes/presentation/screens/note_editor_screen.dart';
import '../../features/notes/presentation/screens/notes_screen.dart';
import '../../features/tasks/presentation/screens/task_create_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notes',
              builder: (context, state) => const NotesScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final noteId = state.uri.queryParameters['id'];
                    return NoteEditorScreen(
                        noteId: noteId != null ? int.tryParse(noteId) : null);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const TaskCreateScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/deadlines',
              builder: (context, state) => const DeadlinesScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const DeadlineCreateScreen(),
                ),
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return DeadlineDetailScreen(deadlineId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
