import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/plant_health.dart';
import '../../data/models/maintenance_task.dart';
import '../../data/repositories/plant_repository.dart';
import 'plant_provider.dart';
import 'auth_provider.dart';

const _badges = {
  'first_plant': {'name': 'Green Thumb', 'trigger': 'Add first plant', 'emoji': '🌱'},
  'plant_collector': {'name': 'Collector', 'trigger': '5 plants added', 'emoji': '🪴'},
  'week_streak': {'name': 'Week Warrior', 'trigger': '7-day streak', 'emoji': '🔥'},
  'month_streak': {'name': 'Iron Gardener', 'trigger': '30-day streak', 'emoji': '💪'},
  'healer': {'name': 'Plant Doctor', 'trigger': 'Complete first diagnosis recovery', 'emoji': '💚'},
  'botanist': {'name': 'Botanist', 'trigger': 'Identify 10 species', 'emoji': '🔬'},
  'level_5': {'name': 'Rising Gardener', 'trigger': 'Reach level 5', 'emoji': '⭐'},
  'level_10': {'name': 'Master Gardener', 'trigger': 'Reach level 10', 'emoji': '👑'},
};

Map<String, dynamic> getBadgeInfo(String badgeId) =>
    _badges[badgeId] ?? {'name': badgeId, 'trigger': '', 'emoji': '🏅'};

List<Map<String, dynamic>> get allBadges =>
    _badges.entries.map((e) => {'id': e.key, ...e.value}).toList();

class GameNotifier extends Notifier<void> {
  @override
  void build() {}

  String get _uid => ref.read(authStateProvider).valueOrNull?.uid ?? '';
  PlantRepository get _repo => ref.read(plantRepositoryProvider);

  Future<void> completeTask(MaintenanceTask task) async {
    final health = await _repo.getHealth(_uid, task.plantId);
    var updated = health.copyWith(
      xp: health.xp + task.xpReward,
      currentHp: health.currentHp + 2,
      lastTaskCompletedAt: DateTime.now(),
    );
    updated = _checkBadges(updated);
    await _repo.saveHealth(_uid, updated);
  }

  Future<void> applyHpDecay(String plantId, int overdueCount) async {
    if (overdueCount == 0) return;
    final health = await _repo.getHealth(_uid, plantId);
    final decay = (overdueCount * 5).clamp(0, 20);
    await _repo.saveHealth(_uid, health.copyWith(currentHp: health.currentHp - decay));
  }

  Future<void> applyDiagnosisBoost(String plantId) async {
    final health = await _repo.getHealth(_uid, plantId);
    final updated = _checkBadges(
      health.copyWith(
        currentHp: health.currentHp + 10,
        xp: health.xp + 30,
        earnedBadges: health.earnedBadges.contains('healer')
            ? health.earnedBadges
            : [...health.earnedBadges, 'healer'],
      ),
    );
    await _repo.saveHealth(_uid, updated);
  }

  PlantHealth _checkBadges(PlantHealth health) {
    final badges = List<String>.from(health.earnedBadges);
    void add(String id) {
      if (!badges.contains(id)) badges.add(id);
    }

    if (health.level >= 5) add('level_5');
    if (health.level >= 10) add('level_10');
    if (health.currentStreak >= 7) add('week_streak');
    if (health.currentStreak >= 30) add('month_streak');

    return health.copyWith(earnedBadges: badges);
  }

  Future<void> onPlantAdded(String plantId, int totalPlants) async {
    final health = await _repo.getHealth(_uid, plantId);
    final badges = List<String>.from(health.earnedBadges);
    if (totalPlants == 1 && !badges.contains('first_plant')) badges.add('first_plant');
    if (totalPlants >= 5 && !badges.contains('plant_collector')) badges.add('plant_collector');
    await _repo.saveHealth(
      _uid,
      health.copyWith(xp: health.xp + 50, earnedBadges: badges),
    );
  }
}

final gameNotifierProvider = NotifierProvider<GameNotifier, void>(GameNotifier.new);
