import 'dart:async';
import '../models/plant.dart';
import '../models/plant_health.dart';
import 'plant_repository.dart';

class MockPlantRepository implements PlantRepository {
  final _plants = <Plant>[];
  final _health = <String, PlantHealth>{};
  final _plantsController = StreamController<List<Plant>>.broadcast();
  final _healthControllers = <String, StreamController<PlantHealth>>{};

  MockPlantRepository() {
    final samplePlant = Plant(
      id: 'plant-1',
      userId: 'mock-uid-123',
      commonName: 'Monstera',
      genus: 'Monstera',
      species: 'deliciosa',
      imageUrl: '',
      nickname: 'Monty',
      addedAt: DateTime.now().subtract(const Duration(days: 10)),
      careNeeds: {
        'waterFrequencyDays': 7,
        'sunlight': 'partial shade',
        'fertilizeFrequencyDays': 30,
        'pruneFrequencyDays': 90,
        'humidity': 'high',
        'notes': 'Wipe leaves monthly',
      },
    );
    _plants.add(samplePlant);
    _health['plant-1'] = PlantHealth(
      plantId: 'plant-1',
      currentHp: 85,
      xp: 240,
      currentStreak: 3,
      longestStreak: 7,
      earnedBadges: ['first_plant', 'week_streak'],
      lastTaskCompletedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  @override
  Stream<List<Plant>> watchPlants(String userId) {
    Future.microtask(() => _plantsController.add(List.from(_plants)));
    return _plantsController.stream;
  }

  @override
  Future<Plant> addPlant(Plant plant) async {
    _plants.add(plant);
    _health[plant.id] = PlantHealth.initial(plant.id);
    _plantsController.add(List.from(_plants));
    return plant;
  }

  @override
  Future<void> updatePlant(Plant plant) async {
    final idx = _plants.indexWhere((p) => p.id == plant.id);
    if (idx >= 0) {
      _plants[idx] = plant;
      _plantsController.add(List.from(_plants));
    }
  }

  @override
  Future<void> deletePlant(String userId, String plantId) async {
    _plants.removeWhere((p) => p.id == plantId);
    _health.remove(plantId);
    _plantsController.add(List.from(_plants));
  }

  @override
  Future<PlantHealth> getHealth(String userId, String plantId) async =>
      _health[plantId] ?? PlantHealth.initial(plantId);

  @override
  Future<void> saveHealth(String userId, PlantHealth health) async {
    _health[health.plantId] = health;
    _healthControllers[health.plantId]?.add(health);
  }

  @override
  Stream<PlantHealth> watchHealth(String userId, String plantId) {
    _healthControllers.putIfAbsent(
        plantId, () => StreamController<PlantHealth>.broadcast());
    Future.microtask(() {
      final h = _health[plantId] ?? PlantHealth.initial(plantId);
      _healthControllers[plantId]?.add(h);
    });
    return _healthControllers[plantId]!.stream;
  }
}
