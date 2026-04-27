import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/plant_analysis.dart';

class AnalysisResultCard extends StatelessWidget {
  final PlantAnalysis analysis;
  const AnalysisResultCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final confidence = (analysis.confidence * 100).round();
    final careNeeds = analysis.careNeeds;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(analysis.commonName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text('${analysis.genus} ${analysis.species}',
                          style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: confidence >= 80 ? AppColors.hpGreen.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$confidence% match',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: confidence >= 80 ? AppColors.hpGreen : AppColors.warning,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(analysis.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 16),
            const Text('Care Requirements', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CareChip(icon: '💧', label: 'Water every ${careNeeds['waterFrequencyDays'] ?? '?'} days'),
                _CareChip(icon: '☀️', label: '${careNeeds['sunlight'] ?? 'Unknown'}'),
                _CareChip(icon: '🌫️', label: '${careNeeds['humidity'] ?? '?'} humidity'),
                _CareChip(icon: '🌿', label: 'Fertilize every ${careNeeds['fertilizeFrequencyDays'] ?? '?'} days'),
              ],
            ),
            if (analysis.funFacts.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Fun Facts', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              ...analysis.funFacts.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🌱 ', style: TextStyle(fontSize: 14)),
                        Expanded(child: Text(f, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4))),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _CareChip extends StatelessWidget {
  final String icon, label;
  const _CareChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
