import 'dart:typed_data';
import '../models/plant_analysis.dart';
import '../models/diagnosis_result.dart';
import '../models/maintenance_task.dart';
import '../models/plant.dart';
import '../services/openai_service.dart';
import '../../core/extensions/datetime_ext.dart';
import 'ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final OpenAiService _openAi;

  AiRepositoryImpl({required OpenAiService openAi}) : _openAi = openAi;

  @override
  Future<PlantAnalysis> identifyPlant(Uint8List imageBytes) async {
    final json = await _openAi.identifyPlant(imageBytes);
    if (json.containsKey('error')) {
      throw Exception(json['error']);
    }
    return PlantAnalysis.fromJson(json);
  }

  @override
  Future<List<MaintenanceTask>> generateSchedule(Plant plant, String userId) async {
    final json = await _openAi.generateSchedule(
      plant.commonName,
      plant.genus,
      plant.species,
      plant.careNeeds,
    );

    final rawTasks = json['weeklyTasks'] as List? ?? [];
    final now = DateTime.now().startOfDay;

    return rawTasks.map((t) {
      final map = t as Map<String, dynamic>;
      final dayOffset = map['dayOffset'] as int? ?? 0;
      final timeOfDay = map['timeOfDay'] as String? ?? 'morning';
      final hour = timeOfDay == 'morning' ? 8 : timeOfDay == 'afternoon' ? 14 : 19;
      final typeStr = map['type'] as String? ?? 'watering';
      final type = TaskTypeExt.fromString(typeStr);

      return MaintenanceTask(
        id: '${plant.id}_${typeStr}_$dayOffset',
        plantId: plant.id,
        userId: userId,
        type: type,
        scheduledAt: now.add(Duration(days: dayOffset, hours: hour)),
        status: TaskStatus.pending,
        xpReward: map['xpReward'] as int? ?? type.defaultXp,
        notes: map['notes'] as String?,
      );
    }).toList();
  }

  @override
  Future<DiagnosisResult> diagnosePlant(Uint8List imageBytes, {Plant? plant}) async {
    final json = await _openAi.diagnosePlant(imageBytes, plantName: plant?.commonName);
    return DiagnosisResult.fromJson(json, plantId: plant?.id ?? '');
  }
}
