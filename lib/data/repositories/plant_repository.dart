import '../models/plant.dart';
import '../models/plant_health.dart';

abstract class PlantRepository {
  Stream<List<Plant>> watchPlants(String userId);
  Future<Plant> addPlant(Plant plant);
  Future<void> updatePlant(Plant plant);
  Future<void> deletePlant(String userId, String plantId);
  Future<PlantHealth> getHealth(String userId, String plantId);
  Future<void> saveHealth(String userId, PlantHealth health);
  Stream<PlantHealth> watchHealth(String userId, String plantId);
}
