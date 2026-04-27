import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final int totalXp;
  final int globalStreak;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.totalXp = 0,
    this.globalStreak = 0,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      totalXp: data['totalXp'] as int? ?? 0,
      globalStreak: data['globalStreak'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'totalXp': totalXp,
        'globalStreak': globalStreak,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  AppUser copyWith({int? totalXp, int? globalStreak, String? displayName}) =>
      AppUser(
        uid: uid,
        email: email,
        displayName: displayName ?? this.displayName,
        totalXp: totalXp ?? this.totalXp,
        globalStreak: globalStreak ?? this.globalStreak,
        createdAt: createdAt,
      );
}
