import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/diagnosis_result.dart';

class RecoveryPlanCard extends StatelessWidget {
  final DiagnosisResult result;
  const RecoveryPlanCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('💊', style: TextStyle(fontSize: 24)),
                SizedBox(width: 10),
                Text('Recovery Plan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),
            ...result.recoverySteps.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${e.key + 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(e.value,
                            style: const TextStyle(color: AppColors.textPrimary, height: 1.4)),
                      ),
                    ],
                  ),
                )),
            if (result.preventionTips.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text('Prevention Tips', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              ...result.preventionTips.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡 ', style: TextStyle(fontSize: 14)),
                        Expanded(child: Text(t, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
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
