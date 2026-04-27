import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/maintenance_task.dart';
import '../../../domain/providers/task_provider.dart';
import '../../../domain/providers/game_provider.dart';

class DailyTasksStrip extends ConsumerWidget {
  const DailyTasksStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No tasks today — your plants are happy! 🌿',
                style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _TaskChip(task: tasks[i]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Could not load tasks'),
    );
  }
}

class _TaskChip extends ConsumerWidget {
  final MaintenanceTask task;
  const _TaskChip({required this.task});

  Color get _bgColor {
    switch (task.status) {
      case TaskStatus.completed: return AppColors.hpGreen.withOpacity(0.15);
      case TaskStatus.skipped: return Colors.grey.shade100;
      case TaskStatus.overdue: return AppColors.hpRed.withOpacity(0.15);
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.completed || task.status == TaskStatus.skipped;
    return GestureDetector(
      onTap: isDone ? null : () => _showActions(context, ref),
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone ? Colors.grey.shade200 : AppColors.primary.withOpacity(0.3),
          ),
          boxShadow: isDone ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(task.type.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(task.type.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                  decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                ),
                textAlign: TextAlign.center),
            if (!isDone) ...[
              const SizedBox(height: 2),
              Text('+${task.xpReward} XP',
                  style: const TextStyle(fontSize: 9, color: AppColors.xpBlue, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text(task.type.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(task.type.label),
              subtitle: task.notes != null ? Text(task.notes!) : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.hpGreen),
              title: Text('Complete (+${task.xpReward} XP)'),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(taskNotifierProvider.notifier).completeTask(task.id);
                await ref.read(gameNotifierProvider.notifier).completeTask(task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.skip_next, color: AppColors.textSecondary),
              title: const Text('Skip for today'),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(taskNotifierProvider.notifier).skipTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
