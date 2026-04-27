import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/plant.dart';
import '../../data/models/plant_analysis.dart';
import '../../domain/providers/plant_provider.dart';
import '../../domain/providers/task_provider.dart';
import '../../domain/providers/ai_provider.dart';
import '../../domain/providers/game_provider.dart';

class AddPlantSheet extends ConsumerStatefulWidget {
  final PlantAnalysis analysis;
  final Uint8List imageBytes;

  const AddPlantSheet({super.key, required this.analysis, required this.imageBytes});

  @override
  ConsumerState<AddPlantSheet> createState() => _AddPlantSheetState();
}

class _AddPlantSheetState extends ConsumerState<AddPlantSheet> {
  late final TextEditingController _nicknameCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nicknameCtrl = TextEditingController(text: widget.analysis.commonName);
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final uid = 'mock-uid-123'; // from authStateProvider in real impl
      final plantId = 'plant_${DateTime.now().millisecondsSinceEpoch}';

      final plant = Plant(
        id: plantId,
        userId: uid,
        commonName: widget.analysis.commonName,
        genus: widget.analysis.genus,
        species: widget.analysis.species,
        imageUrl: '',
        nickname: _nicknameCtrl.text.trim().isNotEmpty
            ? _nicknameCtrl.text.trim()
            : widget.analysis.commonName,
        addedAt: DateTime.now(),
        careNeeds: widget.analysis.careNeeds,
      );

      await ref.read(plantNotifierProvider.notifier).addPlant(plant);

      // Generate and save schedule
      final tasks = await ref.read(aiRepositoryProvider).generateSchedule(plant, uid);
      await ref.read(taskNotifierProvider.notifier).addTasks(tasks);

      // Award first-plant XP
      final plants = ref.read(plantsProvider).valueOrNull ?? [];
      await ref.read(gameNotifierProvider.notifier).onPlantAdded(plantId, plants.length);

      if (mounted) {
        Navigator.pop(context);
        context.go('/dashboard');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plant.displayName} added! Care schedule created 🌿'),
            backgroundColor: AppColors.hpGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add plant: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          const Text('Add to Your Garden', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('${widget.analysis.commonName} • ${widget.analysis.genus} ${widget.analysis.species}',
              style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
          const SizedBox(height: 20),
          TextField(
            controller: _nicknameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nickname (optional)',
              hintText: 'e.g. Monty, Big Leaf...',
              prefixIcon: Icon(Icons.eco_outlined, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('A 4-week care schedule will be generated automatically',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.add_circle_outline),
            label: Text(_saving ? 'Adding...' : 'Add Plant & Generate Schedule'),
          ),
        ],
      ),
    );
  }
}
