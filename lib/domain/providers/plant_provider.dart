import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/plant.dart';
import '../../data/models/plant_health.dart';
import '../../data/repositories/plant_repository.dart';
import '../../data/repositories/mock_plant_repository.dart';
import 'auth_provider.dart';

final plantRepositoryProvider = Provider<PlantRepository>((ref) => MockPlantRepository());

final plantsProvider = StreamProvider<List<Plant>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(plantRepositoryProvider).watchPlants(uid);
});

final plantHealthProvider = StreamProvider.family<PlantHealth, String>((ref, plantId) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(plantRepositoryProvider).watchHealth(uid, plantId);
});

class PlantNotifier extends Notifier<void> {
  @override
  void build() {}

  PlantRepository get _repo => ref.read(plantRepositoryProvider);
  String get _uid => ref.read(authStateProvider).valueOrNull?.uid ?? '';

  Future<Plant> addPlant(Plant plant) => _repo.addPlant(plant);
  Future<void> updatePlant(Plant plant) => _repo.updatePlant(plant);
  Future<void> deletePlant(String plantId) => _repo.deletePlant(_uid, plantId);
}

final plantNotifierProvider = NotifierProvider<PlantNotifier, void>(PlantNotifier.new);
