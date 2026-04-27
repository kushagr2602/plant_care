import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/providers/ai_provider.dart';
import '../add_plant/add_plant_sheet.dart';
import 'widgets/analysis_result_card.dart';

class IdentifyScreen extends ConsumerStatefulWidget {
  const IdentifyScreen({super.key});

  @override
  ConsumerState<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends ConsumerState<IdentifyScreen> {
  Uint8List? _imageBytes;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1280);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _imageBytes = bytes);
    await ref.read(identifyNotifierProvider.notifier).identify(bytes);
  }

  void _reset() {
    setState(() => _imageBytes = null);
    ref.read(identifyNotifierProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final identifyState = ref.watch(identifyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identify Plant'),
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
                const SizedBox(height: 32),
                const Center(
                  child: Text('📸', style: TextStyle(fontSize: 80)),
                ),
                const SizedBox(height: 20),
                const Text('Take or upload a photo of your plant',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Our AI will identify the species and create a personalized care schedule',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 40),
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
                  child: Image.memory(_imageBytes!, height: 260, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                identifyState.analysis.when(
                  data: (analysis) {
                    if (analysis == null) return const SizedBox();
                    return Column(
                      children: [
                        AnalysisResultCard(analysis: analysis),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddPlant(context, analysis),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add to My Garden'),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 12),
                        Text('Analyzing your plant...', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  error: (e, _) => Column(
                    children: [
                      Text('Could not identify plant: $e',
                          style: const TextStyle(color: AppColors.danger)),
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

  void _showAddPlant(BuildContext context, analysis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => AddPlantSheet(analysis: analysis, imageBytes: _imageBytes!),
    );
  }
}
