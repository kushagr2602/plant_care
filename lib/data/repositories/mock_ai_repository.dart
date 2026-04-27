import 'dart:typed_data';
import '../models/plant_analysis.dart';
import '../models/diagnosis_result.dart';
import '../models/maintenance_task.dart';
import '../models/plant.dart';
import 'ai_repository.dart';
import '../../core/extensions/datetime_ext.dart';

class MockAiRepository implements AiRepository {
  @override
  Future<PlantAnalysis> identifyPlant(Uint8List imageBytes) async {
    await Future.delayed(const Duration(seconds: 2));
    return PlantAnalysis(
      commonName: 'Monstera',
      genus: 'Monstera',
      species: 'deliciosa',
      confidence: 0.97,
      description:
          'Monstera deliciosa, known as the Swiss cheese plant, is a species of flowering plant native to tropical forests of southern Mexico. Its large, perforated leaves make it a popular houseplant worldwide.',
      careNeeds: {
        'waterFrequencyDays': 7,
        'sunlight': 'partial shade',
        'fertilizeFrequencyDays': 30,
        'pruneFrequencyDays': 90,
        'humidity': 'high',
        'notes': 'Wipe leaves monthly to remove dust',
      },
      funFacts: [
        'Monstera means "abnormal" in Latin, referring to its unusual leaves.',
        'In the wild, Monsteras can grow up to 20 meters tall.',
        'The fruit of Monstera deliciosa is edible and tastes like a mix of pineapple and banana.',
      ],
    );
  }

  @override
  Future<List<MaintenanceTask>> generateSchedule(Plant plant, String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    final tasks = <MaintenanceTask>[];
    const taskId = 'gen';

    for (int i = 0; i < 28; i++) {
      final day = now.startOfDay.add(Duration(days: i));
      final waterDays = (plant.careNeeds['waterFrequencyDays'] as int?) ?? 7;
      final fertDays = (plant.careNeeds['fertilizeFrequencyDays'] as int?) ?? 30;

      if (i % waterDays == 0) {
        tasks.add(MaintenanceTask(
          id: '${taskId}_water_$i',
          plantId: plant.id,
          userId: userId,
          type: TaskType.watering,
          scheduledAt: day.add(const Duration(hours: 8)),
          status: TaskStatus.pending,
          xpReward: 10,
          notes: 'Water until it drains from the bottom',
        ));
      }
      if (i % 2 == 0) {
        tasks.add(MaintenanceTask(
          id: '${taskId}_sun_$i',
          plantId: plant.id,
          userId: userId,
          type: TaskType.sunlight,
          scheduledAt: day.add(const Duration(hours: 10)),
          status: TaskStatus.pending,
          xpReward: 5,
        ));
      }
      if (i % fertDays == 0 && i > 0) {
        tasks.add(MaintenanceTask(
          id: '${taskId}_fert_$i',
          plantId: plant.id,
          userId: userId,
          type: TaskType.fertilizing,
          scheduledAt: day.add(const Duration(hours: 9)),
          status: TaskStatus.pending,
          xpReward: 25,
          notes: 'Use balanced liquid fertilizer, diluted to half strength',
        ));
      }
    }

    return tasks;
  }

  @override
  Future<DiagnosisResult> diagnosePlant(Uint8List imageBytes, {Plant? plant}) async {
    await Future.delayed(const Duration(seconds: 2));
    return DiagnosisResult(
      id: 'diag-mock',
      plantId: plant?.id ?? '',
      issue: 'Overwatering',
      severity: 'moderate',
      description:
          'The plant shows signs of overwatering — yellowing lower leaves and soft, mushy stem near the base suggest root stress from excess moisture.',
      symptoms: [
        'Yellowing lower leaves',
        'Soft stem near soil line',
        'Soggy soil that stays wet',
      ],
      recoverySteps: [
        'Stop watering immediately for 2 weeks',
        'Check roots — trim any black/mushy roots',
        'Repot in fresh, well-draining soil',
        'Ensure pot has drainage holes',
        'Resume watering only when top 2 inches of soil are dry',
      ],
      preventionTips: [
        'Always check soil moisture before watering',
        'Use a pot with drainage holes',
      ],
      estimatedRecoveryDays: 14,
      diagnosedAt: DateTime.now(),
      imageUrl: '',
    );
  }
}
