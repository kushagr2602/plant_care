import 'maintenance_task.dart';
import '../../core/extensions/datetime_ext.dart';

class CareSchedule {
  final String plantId;
  final List<MaintenanceTask> tasks;
  final DateTime generatedAt;

  const CareSchedule({
    required this.plantId,
    required this.tasks,
    required this.generatedAt,
  });

  Map<DateTime, List<MaintenanceTask>> get tasksByDay {
    final map = <DateTime, List<MaintenanceTask>>{};
    for (final task in tasks) {
      final day = task.scheduledAt.startOfDay;
      map.putIfAbsent(day, () => []).add(task);
    }
    return map;
  }

  List<MaintenanceTask> tasksForDay(DateTime day) =>
      tasks.where((t) => t.scheduledAt.isSameDayAs(day)).toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
}
