import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contextify/core/design/app_theme.dart';
import 'package:contextify/core/providers/theme_provider.dart';
import 'package:contextify/features/onboarding/onboarding_screen.dart';
import 'package:contextify/features/home/home_screen.dart';
import 'package:contextify/features/history/analysis_detail_screen.dart';
import 'package:contextify/features/paywall/paywall_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Determine initial route
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  final initialRoute = onboardingComplete ? '/home' : '/onboarding';

  runApp(
    ProviderScope(
      child: ContextifyApp(initialRoute: initialRoute),
    ),
  );
}

/// Root application widget.
class ContextifyApp extends ConsumerWidget {
  const ContextifyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    final router = GoRouter(
      initialLocation: initialRoute,
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/analysis/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return AnalysisDetailScreen(analysisId: id);
          },
        ),
        GoRoute(
          path: '/paywall',
          builder: (context, state) => const PaywallScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Contextify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: themeMode == AppThemeMode.amoled
          ? AppTheme.amoled()
          : AppTheme.dark(),
      themeMode: themeMode.themeMode,
      routerConfig: router,
    );
  }
}
