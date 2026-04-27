import 'package:cloud_firestore/cloud_firestore.dart';

class DiagnosisResult {
  final String id;
  final String plantId;
  final String issue;
  final String severity;
  final String description;
  final List<String> symptoms;
  final List<String> recoverySteps;
  final List<String> preventionTips;
  final int estimatedRecoveryDays;
  final DateTime diagnosedAt;
  final String imageUrl;

  const DiagnosisResult({
    required this.id,
    required this.plantId,
    required this.issue,
    required this.severity,
    required this.description,
    required this.symptoms,
    required this.recoverySteps,
    required this.preventionTips,
    required this.estimatedRecoveryDays,
    required this.diagnosedAt,
    required this.imageUrl,
  });

  bool get isHealthy => issue.toLowerCase() == 'healthy';

  factory DiagnosisResult.fromJson(Map<String, dynamic> json, {
    String id = '',
    String plantId = '',
    String imageUrl = '',
  }) =>
      DiagnosisResult(
        id: id,
        plantId: plantId,
        issue: json['issue'] as String? ?? 'Unknown',
        severity: json['severity'] as String? ?? 'mild',
        description: json['description'] as String? ?? '',
        symptoms: List<String>.from(json['symptoms'] as List? ?? []),
        recoverySteps: List<String>.from(json['recoverySteps'] as List? ?? []),
        preventionTips: List<String>.from(json['preventionTips'] as List? ?? []),
        estimatedRecoveryDays: json['estimatedRecoveryDays'] as int? ?? 7,
        diagnosedAt: DateTime.now(),
        imageUrl: imageUrl,
      );

  factory DiagnosisResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiagnosisResult(
      id: doc.id,
      plantId: data['plantId'] as String? ?? '',
      issue: data['issue'] as String? ?? '',
      severity: data['severity'] as String? ?? 'mild',
      description: data['description'] as String? ?? '',
      symptoms: List<String>.from(data['symptoms'] as List? ?? []),
      recoverySteps: List<String>.from(data['recoverySteps'] as List? ?? []),
      preventionTips: List<String>.from(data['preventionTips'] as List? ?? []),
      estimatedRecoveryDays: data['estimatedRecoveryDays'] as int? ?? 7,
      diagnosedAt: (data['diagnosedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'plantId': plantId,
        'issue': issue,
        'severity': severity,
        'description': description,
        'symptoms': symptoms,
        'recoverySteps': recoverySteps,
        'preventionTips': preventionTips,
        'estimatedRecoveryDays': estimatedRecoveryDays,
        'diagnosedAt': Timestamp.fromDate(diagnosedAt),
        'imageUrl': imageUrl,
      };

  String get severityEmoji {
    switch (severity.toLowerCase()) {
      case 'severe': return '🔴';
      case 'moderate': return '🟡';
      default: return '🟢';
    }
  }
}
