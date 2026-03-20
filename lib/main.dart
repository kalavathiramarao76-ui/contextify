import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contextify/core/design/app_theme.dart';
import 'package:contextify/core/providers/auth_provider.dart';
import 'package:contextify/core/providers/theme_provider.dart';
import 'package:contextify/core/services/auth_service.dart';
import 'package:contextify/features/auth/login_screen.dart';
import 'package:contextify/features/auth/signup_screen.dart';
import 'package:contextify/features/onboarding/onboarding_screen.dart';
import 'package:contextify/features/home/home_screen.dart';
import 'package:contextify/features/history/analysis_detail_screen.dart';
import 'package:contextify/features/paywall/paywall_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await Hive.initFlutter();
  // Pre-open the analyses box so StorageService can use it immediately
  await Hive.openBox<String>('analyses');

  // Determine initial route
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  String initialRoute;
  if (!onboardingComplete) {
    initialRoute = '/onboarding';
  } else {
    // Check if user has a stored auth token
    final authService = AuthService();
    final token = await authService.getToken();
    initialRoute = token != null ? '/home' : '/login';
  }

  runApp(
    ProviderScope(
      child: ContextifyApp(initialRoute: initialRoute),
    ),
  );
}

/// Root application widget.
class ContextifyApp extends ConsumerStatefulWidget {
  const ContextifyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  ConsumerState<ContextifyApp> createState() => _ContextifyAppState();
}

class _ContextifyAppState extends ConsumerState<ContextifyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: widget.initialRoute,
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
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

    // Check auth status on app start
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Contextify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: themeMode == AppThemeMode.amoled
          ? AppTheme.amoled()
          : AppTheme.dark(),
      themeMode: themeMode.themeMode,
      routerConfig: _router,
    );
  }
}
