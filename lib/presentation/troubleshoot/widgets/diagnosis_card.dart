import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/diagnosis_result.dart';

class DiagnosisCard extends StatelessWidget {
  final DiagnosisResult result;
  const DiagnosisCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final severityColor = result.severity == 'severe'
        ? AppColors.hpRed
        : result.severity == 'moderate'
            ? AppColors.warning
            : AppColors.hpGreen;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(result.severityEmoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.isHealthy ? '✅ Healthy Plant!' : result.issue,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      if (!result.isHealthy)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(result.severity.toUpperCase(),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: severityColor)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(result.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
            if (result.symptoms.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('Detected Symptoms', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              ...result.symptoms.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber, size: 16, color: severityColor),
                        const SizedBox(width: 6),
                        Expanded(child: Text(s, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                      ],
                    ),
                  )),
            ],
            if (!result.isHealthy)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Estimated recovery: ${result.estimatedRecoveryDays} days',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
