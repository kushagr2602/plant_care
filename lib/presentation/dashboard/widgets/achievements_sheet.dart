import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/providers/game_provider.dart';

class AchievementsSheet extends StatelessWidget {
  final List<String> earnedBadges;
  const AchievementsSheet({super.key, required this.earnedBadges});

  @override
  Widget build(BuildContext context) {
    final badges = allBadges;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Achievements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ),
          Expanded(
            child: GridView.builder(
              controller: controller,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: badges.length,
              itemBuilder: (_, i) {
                final badge = badges[i];
                final earned = earnedBadges.contains(badge['id']);
                return Container(
                  decoration: BoxDecoration(
                    color: earned ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: earned ? AppColors.primary.withOpacity(0.3) : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(badge['emoji'] as String,
                          style: TextStyle(
                            fontSize: 32,
                            color: earned ? null : Colors.grey,
                          )),
                      const SizedBox(height: 6),
                      Text(badge['name'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: earned ? AppColors.textPrimary : AppColors.textHint,
                          ),
                          textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
