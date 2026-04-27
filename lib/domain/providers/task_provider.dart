import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/maintenance_task.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/mock_task_repository.dart';
import 'auth_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) => MockTaskRepository());

final todayTasksProvider = StreamProvider<List<MaintenanceTask>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(taskRepositoryProvider).watchTasksForDate(uid, DateTime.now());
});

final tasksForDateProvider = StreamProvider.family<List<MaintenanceTask>, DateTime>((ref, date) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(taskRepositoryProvider).watchTasksForDate(uid, date);
});

final tasksForPlantProvider = StreamProvider.family<List<MaintenanceTask>, String>((ref, plantId) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(taskRepositoryProvider).watchTasksForPlant(uid, plantId);
});

class TaskNotifier extends Notifier<void> {
  @override
  void build() {}

  TaskRepository get _repo => ref.read(taskRepositoryProvider);
  String get _uid => ref.read(authStateProvider).valueOrNull?.uid ?? '';

  Future<void> addTasks(List<MaintenanceTask> tasks) => _repo.addTasks(tasks);

  Future<void> completeTask(String taskId) => _repo.completeTask(_uid, taskId);

  Future<void> skipTask(String taskId) => _repo.skipTask(_uid, taskId);
}

final taskNotifierProvider = NotifierProvider<TaskNotifier, void>(TaskNotifier.new);
