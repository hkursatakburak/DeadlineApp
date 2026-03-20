import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/note.dart';
import '../../../../shared/providers/isar_provider.dart';

part 'note_repository.g.dart';

@Riverpod(keepAlive: true)
NoteRepository noteRepository(NoteRepositoryRef ref) {
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) throw StateError('Isar not ready');
  return NoteRepository(isar);
}

class NoteRepository {
  final Isar _isar;
  const NoteRepository(this._isar);

  Future<List<Note>> getAll({bool includeArchived = false}) {
    if (includeArchived) {
      return _isar.notes.where().findAll();
    }
    return _isar.notes
        .filter()
        .isArchivedEqualTo(false)
        .findAll();
  }

  Stream<List<Note>> watchAll() =>
      _isar.notes.where().watch(fireImmediately: true);

  Future<Note?> getById(int id) => _isar.notes.get(id);

  Future<int> save(Note note) =>
      _isar.writeTxn(() => _isar.notes.put(note));

  Future<bool> delete(int id) =>
      _isar.writeTxn(() => _isar.notes.delete(id));

  Future<void> togglePin(int id) async {
    final note = await _isar.notes.get(id);
    if (note != null) {
      note.isPinned = !note.isPinned;
      await _isar.writeTxn(() => _isar.notes.put(note));
    }
  }

  Future<void> toggleArchive(int id) async {
    final note = await _isar.notes.get(id);
    if (note != null) {
      note.isArchived = !note.isArchived;
      await _isar.writeTxn(() => _isar.notes.put(note));
    }
  }
}
