import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/plant_analysis.dart';
import '../../data/models/diagnosis_result.dart';
import '../../data/models/plant.dart';
import '../../data/repositories/ai_repository.dart';
import '../../data/repositories/mock_ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) => MockAiRepository());

class IdentifyState {
  final AsyncValue<PlantAnalysis?> analysis;
  const IdentifyState({this.analysis = const AsyncValue.data(null)});
  IdentifyState copyWith({AsyncValue<PlantAnalysis?>? analysis}) =>
      IdentifyState(analysis: analysis ?? this.analysis);
}

class IdentifyNotifier extends Notifier<IdentifyState> {
  @override
  IdentifyState build() => const IdentifyState();

  Future<void> identify(Uint8List imageBytes) async {
    state = state.copyWith(analysis: const AsyncValue.loading());
    state = await AsyncValue.guard(
      () => ref.read(aiRepositoryProvider).identifyPlant(imageBytes),
    ).then((v) => state.copyWith(analysis: v.whenData((d) => d)));
  }

  void reset() => state = const IdentifyState();
}

final identifyNotifierProvider = NotifierProvider<IdentifyNotifier, IdentifyState>(IdentifyNotifier.new);

class DiagnoseState {
  final AsyncValue<DiagnosisResult?> result;
  const DiagnoseState({this.result = const AsyncValue.data(null)});
  DiagnoseState copyWith({AsyncValue<DiagnosisResult?>? result}) =>
      DiagnoseState(result: result ?? this.result);
}

class DiagnoseNotifier extends Notifier<DiagnoseState> {
  @override
  DiagnoseState build() => const DiagnoseState();

  Future<void> diagnose(Uint8List imageBytes, {Plant? plant}) async {
    state = state.copyWith(result: const AsyncValue.loading());
    state = await AsyncValue.guard(
      () => ref.read(aiRepositoryProvider).diagnosePlant(imageBytes, plant: plant),
    ).then((v) => state.copyWith(result: v.whenData((d) => d)));
  }

  void reset() => state = const DiagnoseState();
}

final diagnoseNotifierProvider = NotifierProvider<DiagnoseNotifier, DiagnoseState>(DiagnoseNotifier.new);
