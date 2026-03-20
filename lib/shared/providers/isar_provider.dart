import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/deadlines/data/models/deadline_item.dart';
import '../../features/notes/data/models/note.dart';
import '../../features/tasks/data/models/task.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  if (Isar.instanceNames.isEmpty) {
    return await Isar.open(
      [DeadlineItemSchema, NoteSchema, TaskSchema, SubTaskItemSchema],
      directory: dir.path,
    );
  }
  return Isar.getInstance()!;
}
