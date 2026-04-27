import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/gemini_service.dart';

// TODO: Replace with your actual Gemini API key
// Get it from: https://ai.google.dev/
const String _geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(apiKey: _geminiApiKey);
});
