import '../models/maintenance_task.dart';

abstract class TaskRepository {
  Stream<List<MaintenanceTask>> watchTasksForDate(String userId, DateTime date);
  Stream<List<MaintenanceTask>> watchTasksForPlant(String userId, String plantId);
  Future<void> addTasks(List<MaintenanceTask> tasks);
  Future<void> completeTask(String userId, String taskId);
  Future<void> skipTask(String userId, String taskId);
  Future<List<MaintenanceTask>> getOverdueTasks(String userId);
}
