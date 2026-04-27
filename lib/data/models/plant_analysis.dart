class PlantAnalysis {
  final String commonName;
  final String genus;
  final String species;
  final double confidence;
  final String description;
  final Map<String, dynamic> careNeeds;
  final List<String> funFacts;

  const PlantAnalysis({
    required this.commonName,
    required this.genus,
    required this.species,
    required this.confidence,
    required this.description,
    required this.careNeeds,
    required this.funFacts,
  });

  factory PlantAnalysis.fromJson(Map<String, dynamic> json) => PlantAnalysis(
        commonName: json['commonName'] as String? ?? 'Unknown Plant',
        genus: json['genus'] as String? ?? '',
        species: json['species'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] as String? ?? '',
        careNeeds: Map<String, dynamic>.from(json['careNeeds'] as Map? ?? {}),
        funFacts: List<String>.from(json['funFacts'] as List? ?? []),
      );
}
