import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/deadline_item.dart';
import '../../../../shared/providers/isar_provider.dart';

part 'deadline_repository.g.dart';

@Riverpod(keepAlive: true)
DeadlineRepository deadlineRepository(DeadlineRepositoryRef ref) {
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) throw StateError('Isar not ready');
  return DeadlineRepository(isar);
}

class DeadlineRepository {
  final Isar _isar;
  const DeadlineRepository(this._isar);

  Future<List<DeadlineItem>> getAll() =>
      _isar.deadlineItems.where().findAll();

  Stream<List<DeadlineItem>> watchAll() =>
      _isar.deadlineItems.where().watch(fireImmediately: true);

  Future<DeadlineItem?> getById(int id) =>
      _isar.deadlineItems.get(id);

  Future<int> save(DeadlineItem item) =>
      _isar.writeTxn(() => _isar.deadlineItems.put(item));

  Future<bool> delete(int id) =>
      _isar.writeTxn(() => _isar.deadlineItems.delete(id));

  Future<void> markCompleted(int id) async {
    final item = await _isar.deadlineItems.get(id);
    if (item != null) {
      item.isCompleted = true;
      await _isar.writeTxn(() => _isar.deadlineItems.put(item));
    }
  }
}
