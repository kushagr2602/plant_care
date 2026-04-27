import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// TODO: Set your Gemini API key here
// Get it from: https://ai.google.dev/
const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Replace geminiApiKey with actual key from environment or Firebase Remote Config
  runApp(const ProviderScope(child: PlantCareApp()));
}

class PlantCareApp extends ConsumerWidget {
  const PlantCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'PlantCare',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
