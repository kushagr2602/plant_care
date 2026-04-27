import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/providers/auth_provider.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/signup_screen.dart';
import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/identify/identify_screen.dart';
import '../../presentation/troubleshoot/troubleshoot_screen.dart';
import '../../presentation/schedule/schedule_screen.dart';
import '../../presentation/plant_detail/plant_detail_screen.dart';
import '../../presentation/shared/loading_indicator.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      if (authState.isLoading) return '/loading';
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/loading', builder: (_, __) => const Scaffold(body: Center(child: AppLoadingIndicator()))),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: '/plant/:id',
        builder: (_, state) => PlantDetailScreen(plantId: state.pathParameters['id']!),
      ),
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/schedule', builder: (_, __) => const ScheduleScreen()),
          GoRoute(path: '/identify', builder: (_, __) => const IdentifyScreen()),
          GoRoute(path: '/troubleshoot', builder: (_, __) => const TroubleshootScreen()),
        ],
      ),
    ],
  );
});

class _AppShell extends ConsumerWidget {
  final Widget child;
  const _AppShell({required this.child});

  static const _tabs = ['/dashboard', '/schedule', '/identify', '/troubleshoot'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t));

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex < 0 ? 0 : currentIndex,
        onTap: (i) => context.go(_tabs[i]),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.eco_outlined), activeIcon: Icon(Icons.eco), label: 'Garden'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), activeIcon: Icon(Icons.camera_alt), label: 'Identify'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services_outlined), activeIcon: Icon(Icons.medical_services), label: 'Diagnose'),
        ],
      ),
    );
  }
}
