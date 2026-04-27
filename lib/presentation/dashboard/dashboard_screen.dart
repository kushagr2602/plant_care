import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/plant_provider.dart';
import '../../domain/providers/task_provider.dart';
import '../shared/loading_indicator.dart';
import '../shared/error_display.dart';
import 'widgets/plant_health_card.dart';
import 'widgets/daily_tasks_strip.dart';
import 'widgets/achievements_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final plantsAsync = ref.watch(plantsProvider);
    final todayAsync = ref.watch(todayTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back, ${user?.displayName.split(' ').first ?? 'Gardener'}! 🌿',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                todayAsync.when(
                  data: (tasks) {
                    final done = tasks.where((t) => t.status.name == 'completed').length;
                    final total = tasks.length;
                    return Text('$done / $total tasks done today',
                        style: const TextStyle(fontSize: 12, color: Colors.white70));
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.emoji_events_outlined),
                onPressed: () => _showAchievements(context, ref),
                tooltip: 'Achievements',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _sectionHeader(context, "Today's Tasks"),
                const SizedBox(height: 8),
                const DailyTasksStrip(),
                const SizedBox(height: 24),
                _sectionHeader(context, 'Your Plants'),
                const SizedBox(height: 8),
              ],
            ),
          ),
          plantsAsync.when(
            data: (plants) {
              if (plants.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Text('🪴', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 12),
                        const Text('No plants yet!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        const Text('Tap the camera tab to identify and add your first plant.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: PlantHealthCard(plant: plants[i]),
                  ),
                  childCount: plants.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: AppLoadingIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: ErrorDisplay(message: e.toString()),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      );

  void _showAchievements(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => AchievementsSheet(earnedBadges: const ['first_plant', 'week_streak']),
    );
  }
}
