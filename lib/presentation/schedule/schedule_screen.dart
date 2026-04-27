import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/datetime_ext.dart';
import '../../data/models/maintenance_task.dart';
import '../../domain/providers/task_provider.dart';
import '../../domain/providers/game_provider.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late final PageController _pageCtrl;
  int _weekOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  DateTime _weekStart(int offset) {
    final now = DateTime.now().startOfDay;
    return now.add(Duration(days: offset * 7));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Schedule'),
        actions: [
          if (_weekOffset != 0)
            TextButton(
              onPressed: () {
                setState(() => _weekOffset = 0);
                _pageCtrl.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
              },
              child: const Text('Today', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          _WeekNav(weekOffset: _weekOffset, onPrev: () => _navigate(-1), onNext: () => _navigate(1)),
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _weekOffset = i - 50),
              itemBuilder: (ctx, page) {
                final offset = page - 50;
                return _WeekView(weekStart: _weekStart(offset));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(int delta) {
    setState(() => _weekOffset += delta);
    _pageCtrl.animateToPage(
      50 + _weekOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class _WeekNav extends StatelessWidget {
  final int weekOffset;
  final VoidCallback onPrev, onNext;
  const _WeekNav({required this.weekOffset, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    final start = DateTime.now().startOfDay.add(Duration(days: weekOffset * 7));
    final end = start.add(const Duration(days: 6));
    return Container(
      color: AppColors.primary.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left), color: AppColors.primary),
          Expanded(
            child: Text(
              weekOffset == 0 ? 'This Week  •  ${fmt.format(start)} – ${fmt.format(end)}' : '${fmt.format(start)} – ${fmt.format(end)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right), color: AppColors.primary),
        ],
      ),
    );
  }
}

class _WeekView extends ConsumerWidget {
  final DateTime weekStart;
  const _WeekView({required this.weekStart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: 7,
      itemBuilder: (ctx, i) {
        final day = weekStart.add(Duration(days: i));
        final tasksAsync = ref.watch(tasksForDateProvider(day));
        return _DaySection(day: day, tasksAsync: tasksAsync);
      },
    );
  }
}

class _DaySection extends ConsumerWidget {
  final DateTime day;
  final AsyncValue<List<MaintenanceTask>> tasksAsync;
  const _DaySection({required this.day, required this.tasksAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isToday = day.isToday;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(day.dayName,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: isToday ? Colors.white : AppColors.textSecondary)),
                    Text('${day.day}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isToday ? Colors.white : AppColors.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) return const Text('Rest day 🌙', style: TextStyle(color: AppColors.textHint, fontSize: 13));
                  final done = tasks.where((t) => t.status == TaskStatus.completed).length;
                  return Text('$done/${tasks.length} tasks',
                      style: TextStyle(
                        fontSize: 13,
                        color: done == tasks.length ? AppColors.hpGreen : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ));
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ),
        tasksAsync.when(
          data: (tasks) => tasks.isEmpty
              ? const SizedBox()
              : Column(
                  children: tasks.map((t) => _TaskRow(task: t)).toList(),
                ),
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
        const Divider(height: 1, indent: 64),
      ],
    );
  }
}

class _TaskRow extends ConsumerWidget {
  final MaintenanceTask task;
  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.completed;
    final isSkipped = task.status == TaskStatus.skipped;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDone ? AppColors.hpGreen.withOpacity(0.15) : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(task.type.emoji, style: const TextStyle(fontSize: 20))),
      ),
      title: Text(task.type.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDone || isSkipped ? AppColors.textSecondary : AppColors.textPrimary,
            decoration: isDone ? TextDecoration.lineThrough : null,
          )),
      subtitle: task.notes != null ? Text(task.notes!, style: const TextStyle(fontSize: 12)) : null,
      trailing: isDone
          ? const Icon(Icons.check_circle, color: AppColors.hpGreen)
          : isSkipped
              ? const Icon(Icons.skip_next, color: AppColors.textHint)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('+${task.xpReward} XP', style: const TextStyle(fontSize: 11, color: AppColors.xpBlue, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppColors.textHint),
                  ],
                ),
      onTap: (!isDone && !isSkipped) ? () => _completeTask(context, ref) : null,
    );
  }

  void _completeTask(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text(task.type.emoji, style: const TextStyle(fontSize: 28)),
              title: Text(task.type.label, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: task.notes != null ? Text(task.notes!) : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.hpGreen),
              title: Text('Complete  (+${task.xpReward} XP)'),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(taskNotifierProvider.notifier).completeTask(task.id);
                await ref.read(gameNotifierProvider.notifier).completeTask(task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.skip_next, color: AppColors.textSecondary),
              title: const Text('Skip'),
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
