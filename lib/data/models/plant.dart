import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String id;
  final String userId;
  final String commonName;
  final String genus;
  final String species;
  final String imageUrl;
  final String nickname;
  final DateTime addedAt;
  final Map<String, dynamic> careNeeds;

  const Plant({
    required this.id,
    required this.userId,
    required this.commonName,
    required this.genus,
    required this.species,
    required this.imageUrl,
    required this.nickname,
    required this.addedAt,
    required this.careNeeds,
  });

  factory Plant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Plant(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      commonName: data['commonName'] as String? ?? '',
      genus: data['genus'] as String? ?? '',
      species: data['species'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      nickname: data['nickname'] as String? ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      careNeeds: Map<String, dynamic>.from(data['careNeeds'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'commonName': commonName,
        'genus': genus,
        'species': species,
        'imageUrl': imageUrl,
        'nickname': nickname,
        'addedAt': Timestamp.fromDate(addedAt),
        'careNeeds': careNeeds,
      };

  Plant copyWith({String? nickname, String? imageUrl, Map<String, dynamic>? careNeeds}) =>
      Plant(
        id: id,
        userId: userId,
        commonName: commonName,
        genus: genus,
        species: species,
        imageUrl: imageUrl ?? this.imageUrl,
        nickname: nickname ?? this.nickname,
        addedAt: addedAt,
        careNeeds: careNeeds ?? this.careNeeds,
      );

  String get displayName => nickname.isNotEmpty ? nickname : commonName;
}
