import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/note.dart';
import '../../data/repositories/note_repository.dart';

part 'notes_provider.g.dart';

@riverpod
class NotesNotifier extends _$NotesNotifier {
  bool _showArchived = false;

  @override
  Future<List<Note>> build() async {
    final repo = ref.watch(noteRepositoryProvider);
    return repo.getAll(includeArchived: _showArchived);
  }

  Future<void> add(Note note) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(noteRepositoryProvider);
      await repo.save(note);
      return repo.getAll(includeArchived: _showArchived);
    });
  }

  Future<void> saveNote(Note note) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(noteRepositoryProvider);
      await repo.save(note);
      return repo.getAll(includeArchived: _showArchived);
    });
  }

  Future<void> delete(int id) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(noteRepositoryProvider);
      await repo.delete(id);
      return repo.getAll(includeArchived: _showArchived);
    });
  }

  Future<void> togglePin(int id) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(noteRepositoryProvider);
      await repo.togglePin(id);
      return repo.getAll(includeArchived: _showArchived);
    });
  }

  Future<void> toggleArchive(int id) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(noteRepositoryProvider);
      await repo.toggleArchive(id);
      return repo.getAll(includeArchived: _showArchived);
    });
  }

  void toggleShowArchived() {
    _showArchived = !_showArchived;
    ref.invalidateSelf();
  }

  bool get showArchived => _showArchived;
}
