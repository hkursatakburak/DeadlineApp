import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/deadline_item.dart';
import '../../data/repositories/deadline_repository.dart';

part 'deadlines_provider.g.dart';

@riverpod
class DeadlinesNotifier extends _$DeadlinesNotifier {
  @override
  Future<List<DeadlineItem>> build() async {
    final repo = ref.watch(deadlineRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(DeadlineItem item) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(deadlineRepositoryProvider);
      await repo.save(item);
      return repo.getAll();
    });
  }

  Future<void> saveDeadline(DeadlineItem item) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(deadlineRepositoryProvider);
      await repo.save(item);
      return repo.getAll();
    });
  }

  Future<void> delete(int id) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(deadlineRepositoryProvider);
      await repo.delete(id);
      return repo.getAll();
    });
  }

  Future<void> markCompleted(int id) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(deadlineRepositoryProvider);
      await repo.markCompleted(id);
      return repo.getAll();
    });
  }
}
