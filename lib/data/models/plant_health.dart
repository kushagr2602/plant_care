import 'package:cloud_firestore/cloud_firestore.dart';

class PlantHealth {
  final String plantId;
  final int currentHp;
  final int xp;
  final int currentStreak;
  final int longestStreak;
  final List<String> earnedBadges;
  final DateTime lastTaskCompletedAt;

  const PlantHealth({
    required this.plantId,
    required this.currentHp,
    required this.xp,
    required this.currentStreak,
    required this.longestStreak,
    required this.earnedBadges,
    required this.lastTaskCompletedAt,
  });

  int get level => xp ~/ 200;
  int get xpForCurrentLevel => xp % 200;
  int get xpForNextLevel => 200;
  double get levelProgress => xpForCurrentLevel / xpForNextLevel;

  String get hpStatus {
    if (currentHp >= 70) return 'Thriving';
    if (currentHp >= 40) return 'Okay';
    return 'Struggling';
  }

  factory PlantHealth.initial(String plantId) => PlantHealth(
        plantId: plantId,
        currentHp: 100,
        xp: 0,
        currentStreak: 0,
        longestStreak: 0,
        earnedBadges: const [],
        lastTaskCompletedAt: DateTime.now(),
      );

  factory PlantHealth.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlantHealth(
      plantId: data['plantId'] as String? ?? doc.id,
      currentHp: data['currentHp'] as int? ?? 100,
      xp: data['xp'] as int? ?? 0,
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      earnedBadges: List<String>.from(data['earnedBadges'] as List? ?? []),
      lastTaskCompletedAt:
          (data['lastTaskCompletedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'plantId': plantId,
        'currentHp': currentHp,
        'xp': xp,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'earnedBadges': earnedBadges,
        'lastTaskCompletedAt': Timestamp.fromDate(lastTaskCompletedAt),
      };

  PlantHealth copyWith({
    int? currentHp,
    int? xp,
    int? currentStreak,
    int? longestStreak,
    List<String>? earnedBadges,
    DateTime? lastTaskCompletedAt,
  }) =>
      PlantHealth(
        plantId: plantId,
        currentHp: (currentHp ?? this.currentHp).clamp(0, 100),
        xp: xp ?? this.xp,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        earnedBadges: earnedBadges ?? this.earnedBadges,
        lastTaskCompletedAt: lastTaskCompletedAt ?? this.lastTaskCompletedAt,
      );
}
