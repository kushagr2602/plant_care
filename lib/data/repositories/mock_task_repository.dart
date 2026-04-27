import 'dart:async';
import '../models/maintenance_task.dart';
import '../../core/extensions/datetime_ext.dart';
import 'task_repository.dart';

class MockTaskRepository implements TaskRepository {
  final _tasks = <MaintenanceTask>[];
  final _controllers = <String, StreamController<List<MaintenanceTask>>>{};

  MockTaskRepository() {
    final now = DateTime.now();
    _tasks.addAll([
      MaintenanceTask(
        id: 'task-1',
        plantId: 'plant-1',
        userId: 'mock-uid-123',
        type: TaskType.watering,
        scheduledAt: now.startOfDay.add(const Duration(hours: 8)),
        status: TaskStatus.pending,
        xpReward: 10,
        notes: 'Water thoroughly until drainage',
      ),
      MaintenanceTask(
        id: 'task-2',
        plantId: 'plant-1',
        userId: 'mock-uid-123',
        type: TaskType.sunlight,
        scheduledAt: now.startOfDay.add(const Duration(hours: 10)),
        status: TaskStatus.completed,
        xpReward: 5,
        completedAt: now.subtract(const Duration(hours: 1)),
      ),
      MaintenanceTask(
        id: 'task-3',
        plantId: 'plant-1',
        userId: 'mock-uid-123',
        type: TaskType.fertilizing,
        scheduledAt: now.add(const Duration(days: 3)).startOfDay.add(const Duration(hours: 9)),
        status: TaskStatus.pending,
        xpReward: 25,
      ),
    ]);
  }

  void _notify() {
    for (final entry in _controllers.entries) {
      final date = DateTime.parse(entry.key);
      entry.value.add(_tasks.where((t) => t.scheduledAt.isSameDayAs(date)).toList());
    }
  }

  @override
  Stream<List<MaintenanceTask>> watchTasksForDate(String userId, DateTime date) {
    final key = date.startOfDay.toIso8601String();
    _controllers.putIfAbsent(key, () => StreamController<List<MaintenanceTask>>.broadcast());
    Future.microtask(() {
      _controllers[key]?.add(
        _tasks.where((t) => t.scheduledAt.isSameDayAs(date)).toList(),
      );
    });
    return _controllers[key]!.stream;
  }

  @override
  Stream<List<MaintenanceTask>> watchTasksForPlant(String userId, String plantId) {
    final ctrl = StreamController<List<MaintenanceTask>>.broadcast();
    Future.microtask(() => ctrl.add(_tasks.where((t) => t.plantId == plantId).toList()));
    return ctrl.stream;
  }

  @override
  Future<void> addTasks(List<MaintenanceTask> tasks) async {
    _tasks.addAll(tasks);
    _notify();
  }

  @override
  Future<void> completeTask(String userId, String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx >= 0) {
      _tasks[idx] = _tasks[idx].copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
      _notify();
    }
  }

  @override
  Future<void> skipTask(String userId, String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx >= 0) {
      _tasks[idx] = _tasks[idx].copyWith(status: TaskStatus.skipped);
      _notify();
    }
  }

  @override
  Future<List<MaintenanceTask>> getOverdueTasks(String userId) async {
    final now = DateTime.now();
    return _tasks
        .where((t) =>
            t.status == TaskStatus.pending &&
            t.scheduledAt.isBefore(now.startOfDay))
        .toList();
  }
}
