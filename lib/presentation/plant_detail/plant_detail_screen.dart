import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/datetime_ext.dart';
import '../../data/models/maintenance_task.dart';
import '../../domain/providers/plant_provider.dart';
import '../../domain/providers/task_provider.dart';
import '../shared/health_bar_painter.dart';
import '../shared/xp_progress_bar.dart';
import '../shared/loading_indicator.dart';

class PlantDetailScreen extends ConsumerWidget {
  final String plantId;
  const PlantDetailScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsProvider);
    final plant = plantsAsync.valueOrNull?.firstWhere(
      (p) => p.id == plantId,
      orElse: () => throw Exception('Plant not found'),
    );

    if (plant == null) {
      return const Scaffold(body: Center(child: AppLoadingIndicator()));
    }

    final healthAsync = ref.watch(plantHealthProvider(plantId));
    final tasksAsync = ref.watch(tasksForPlantProvider(plantId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(plant.displayName, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                background: plant.imageUrl.isNotEmpty
                    ? Image.network(plant.imageUrl, fit: BoxFit.cover,
                        colorBlendMode: BlendMode.darken, color: Colors.black26)
                    : Container(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        child: const Center(child: Text('🌿', style: TextStyle(fontSize: 80))),
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${plant.genus} ${plant.species}',
                        style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    healthAsync.when(
                      data: (h) => Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('❤️ HP ${h.currentHp}/100', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text(h.hpStatus, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                        color: h.currentHp >= 70 ? AppColors.hpGreen : h.currentHp >= 40 ? Colors.orange : AppColors.hpRed)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                HealthBar(current: h.currentHp),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('⭐ Level ${h.level}  •  ${h.xpForCurrentLevel}/${h.xpForNextLevel} XP',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    if (h.currentStreak > 0)
                                      Text('🔥 ${h.currentStreak}d', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.deepOrange)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                XpProgressBar(currentXp: h.xpForCurrentLevel, xpForNext: h.xpForNextLevel),
                              ],
                            ),
                          ),
                        ],
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
            const SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: [
                    Tab(text: 'Care Info'),
                    Tab(text: 'Tasks'),
                    Tab(text: 'Stats'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _CareInfoTab(plant: plant),
              _TasksTab(tasksAsync: tasksAsync),
              healthAsync.when(
                data: (h) => _StatsTab(health: h),
                loading: () => const Center(child: AppLoadingIndicator()),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareInfoTab extends StatelessWidget {
  final dynamic plant;
  const _CareInfoTab({required this.plant});

  @override
  Widget build(BuildContext context) {
    final needs = plant.careNeeds as Map<String, dynamic>;
    final items = [
      ('💧', 'Watering', 'Every ${needs['waterFrequencyDays'] ?? '?'} days'),
      ('☀️', 'Sunlight', '${needs['sunlight'] ?? 'Unknown'}'),
      ('🌫️', 'Humidity', '${needs['humidity'] ?? 'Unknown'}'),
      ('🌿', 'Fertilizing', 'Every ${needs['fertilizeFrequencyDays'] ?? '?'} days'),
      ('✂️', 'Pruning', 'Every ${needs['pruneFrequencyDays'] ?? '?'} days'),
      if (needs['notes'] != null && (needs['notes'] as String).isNotEmpty)
        ('📝', 'Notes', needs['notes'] as String),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: items.map((item) => Card(
        child: ListTile(
          leading: Text(item.$1, style: const TextStyle(fontSize: 24)),
          title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          subtitle: Text(item.$3),
        ),
      )).toList(),
    );
  }
}

class _TasksTab extends StatelessWidget {
  final AsyncValue<List<MaintenanceTask>> tasksAsync;
  const _TasksTab({required this.tasksAsync});

  @override
  Widget build(BuildContext context) {
    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(
            child: Text('No tasks scheduled yet', style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: tasks.length,
          itemBuilder: (_, i) {
            final task = tasks[i];
            return ListTile(
              leading: Text(task.type.emoji, style: const TextStyle(fontSize: 22)),
              title: Text(task.type.label, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(task.scheduledAt.shortDate),
              trailing: Icon(
                task.status.name == 'completed' ? Icons.check_circle : Icons.radio_button_unchecked,
                color: task.status.name == 'completed' ? AppColors.hpGreen : AppColors.textHint,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final dynamic health;
  const _StatsTab({required this.health});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('❤️', 'Current HP', '${health.currentHp}/100'),
      ('⭐', 'Total XP', '${health.xp}'),
      ('📊', 'Level', '${health.level}'),
      ('🔥', 'Current Streak', '${health.currentStreak} days'),
      ('🏆', 'Longest Streak', '${health.longestStreak} days'),
      ('🏅', 'Badges Earned', '${health.earnedBadges.length}'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: stats.map((s) => Card(
        child: ListTile(
          leading: Text(s.$1, style: const TextStyle(fontSize: 24)),
          title: Text(s.$2, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          trailing: Text(s.$3, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ),
      )).toList(),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: Colors.white, child: tabBar);

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) => false;
}
