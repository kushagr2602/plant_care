import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskType { watering, sunlight, fertilizing, pruning, misting, repotting }

extension TaskTypeExt on TaskType {
  String get label {
    switch (this) {
      case TaskType.watering: return 'Watering';
      case TaskType.sunlight: return 'Sunlight';
      case TaskType.fertilizing: return 'Fertilizing';
      case TaskType.pruning: return 'Pruning';
      case TaskType.misting: return 'Misting';
      case TaskType.repotting: return 'Repotting';
    }
  }

  String get emoji {
    switch (this) {
      case TaskType.watering: return '💧';
      case TaskType.sunlight: return '☀️';
      case TaskType.fertilizing: return '🌿';
      case TaskType.pruning: return '✂️';
      case TaskType.misting: return '🌫️';
      case TaskType.repotting: return '🪴';
    }
  }

  int get defaultXp {
    switch (this) {
      case TaskType.watering: return 10;
      case TaskType.sunlight: return 5;
      case TaskType.fertilizing: return 25;
      case TaskType.pruning: return 30;
      case TaskType.misting: return 8;
      case TaskType.repotting: return 50;
    }
  }

  static TaskType fromString(String value) =>
      TaskType.values.firstWhere((e) => e.name == value, orElse: () => TaskType.watering);
}

enum TaskStatus { pending, completed, skipped, overdue }

extension TaskStatusExt on TaskStatus {
  static TaskStatus fromString(String value) =>
      TaskStatus.values.firstWhere((e) => e.name == value, orElse: () => TaskStatus.pending);
}

class MaintenanceTask {
  final String id;
  final String plantId;
  final String userId;
  final TaskType type;
  final DateTime scheduledAt;
  final TaskStatus status;
  final int xpReward;
  final String? notes;
  final DateTime? completedAt;

  const MaintenanceTask({
    required this.id,
    required this.plantId,
    required this.userId,
    required this.type,
    required this.scheduledAt,
    required this.status,
    required this.xpReward,
    this.notes,
    this.completedAt,
  });

  factory MaintenanceTask.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MaintenanceTask(
      id: doc.id,
      plantId: data['plantId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      type: TaskTypeExt.fromString(data['type'] as String? ?? 'watering'),
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: TaskStatusExt.fromString(data['status'] as String? ?? 'pending'),
      xpReward: data['xpReward'] as int? ?? 10,
      notes: data['notes'] as String?,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'plantId': plantId,
        'userId': userId,
        'type': type.name,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'status': status.name,
        'xpReward': xpReward,
        if (notes != null) 'notes': notes,
        if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      };

  MaintenanceTask copyWith({TaskStatus? status, DateTime? completedAt}) =>
      MaintenanceTask(
        id: id,
        plantId: plantId,
        userId: userId,
        type: type,
        scheduledAt: scheduledAt,
        status: status ?? this.status,
        xpReward: xpReward,
        notes: notes,
        completedAt: completedAt ?? this.completedAt,
      );
}
