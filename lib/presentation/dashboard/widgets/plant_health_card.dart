import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/plant.dart';
import '../../../domain/providers/plant_provider.dart';
import '../../shared/health_bar_painter.dart';
import '../../shared/xp_progress_bar.dart';

class PlantHealthCard extends ConsumerWidget {
  final Plant plant;
  const PlantHealthCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(plantHealthProvider(plant.id));

    return GestureDetector(
      onTap: () => context.push('/plant/${plant.id}'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: plant.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(plant.imageUrl, fit: BoxFit.cover),
                          )
                        : const Center(child: Text('🌿', style: TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plant.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                        Text('${plant.genus} ${plant.species}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  healthAsync.when(
                    data: (h) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Lv ${h.level}',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 12)),
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              healthAsync.when(
                data: (health) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Text('❤️', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text('HP ${health.currentHp}/100',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ]),
                        Text(health.hpStatus,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: health.currentHp >= 70 ? AppColors.hpGreen : health.currentHp >= 40 ? Colors.orange : AppColors.hpRed,
                            )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    HealthBar(current: health.currentHp),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Text('⭐', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text('${health.xpForCurrentLevel} / ${health.xpForNextLevel} XP',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ]),
                        if (health.currentStreak > 0)
                          Row(children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text('${health.currentStreak}d streak',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.deepOrange)),
                          ]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    XpProgressBar(currentXp: health.xpForCurrentLevel, xpForNext: health.xpForNextLevel),
                  ],
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Could not load health data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
