import 'dart:typed_data';
import '../models/plant_analysis.dart';
import '../models/diagnosis_result.dart';
import '../models/maintenance_task.dart';
import '../models/plant.dart';

abstract class AiRepository {
  Future<PlantAnalysis> identifyPlant(Uint8List imageBytes);
  Future<List<MaintenanceTask>> generateSchedule(Plant plant, String userId);
  Future<DiagnosisResult> diagnosePlant(Uint8List imageBytes, {Plant? plant});
}
