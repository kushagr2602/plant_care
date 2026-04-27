import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/providers/ai_provider.dart';
import '../../domain/providers/plant_provider.dart';
import '../../domain/providers/game_provider.dart';
import '../../data/models/plant.dart';
import 'widgets/diagnosis_card.dart';
import 'widgets/recovery_plan_card.dart';

class TroubleshootScreen extends ConsumerStatefulWidget {
  const TroubleshootScreen({super.key});

  @override
  ConsumerState<TroubleshootScreen> createState() => _TroubleshootScreenState();
}

class _TroubleshootScreenState extends ConsumerState<TroubleshootScreen> {
  Uint8List? _imageBytes;
  Plant? _selectedPlant;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1280);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _imageBytes = bytes);
    await ref.read(diagnoseNotifierProvider.notifier).diagnose(bytes, plant: _selectedPlant);
  }

  void _reset() {
    setState(() {
      _imageBytes = null;
      _selectedPlant = null;
    });
    ref.read(diagnoseNotifierProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final diagnoseState = ref.watch(diagnoseNotifierProvider);
    final plantsAsync = ref.watch(plantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Troubleshoot'),
        actions: [
          if (_imageBytes != null)
            IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_imageBytes == null) ...[
                const SizedBox(height: 24),
                const Center(child: Text('🔍', style: TextStyle(fontSize: 80))),
                const SizedBox(height: 20),
                const Text('Is your plant struggling?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Photo your plant and our AI will diagnose the issue and create a recovery plan',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                plantsAsync.when(
                  data: (plants) => plants.isEmpty
                      ? const SizedBox()
                      : DropdownButtonFormField<Plant?>(
                          value: _selectedPlant,
                          decoration: const InputDecoration(
                            labelText: 'Which plant? (optional)',
                            prefixIcon: Icon(Icons.eco_outlined, color: AppColors.primary),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Don\'t know')),
                            ...plants.map((p) => DropdownMenuItem(value: p, child: Text(p.displayName))),
                          ],
                          onChanged: (p) => setState(() => _selectedPlant = p),
                        ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ] else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_imageBytes!, height: 220, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                diagnoseState.result.when(
                  data: (result) {
                    if (result == null) return const SizedBox();
                    return Column(
                      children: [
                        DiagnosisCard(result: result),
                        const SizedBox(height: 12),
                        if (!result.isHealthy) ...[
                          RecoveryPlanCard(result: result),
                          const SizedBox(height: 16),
                          if (_selectedPlant != null)
                            ElevatedButton.icon(
                              onPressed: () => _applyBoost(result.plantId),
                              icon: const Icon(Icons.healing),
                              label: const Text('Start Recovery (+10 HP, +30 XP)'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.hpGreen),
                            ),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 12),
                        Text('Diagnosing your plant...', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  error: (e, _) => Column(
                    children: [
                      Text('Diagnosis failed: $e', style: const TextStyle(color: AppColors.danger)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _reset, child: const Text('Try Again')),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyBoost(String plantId) async {
    if (plantId.isEmpty && _selectedPlant == null) return;
    final id = plantId.isNotEmpty ? plantId : _selectedPlant!.id;
    await ref.read(gameNotifierProvider.notifier).applyDiagnosisBoost(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recovery started! +10 HP, +30 XP 💚'), backgroundColor: AppColors.hpGreen),
      );
    }
  }
}
