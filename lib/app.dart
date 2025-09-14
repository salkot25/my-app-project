import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/offline_auth_provider_new.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/widgets/status_gate.dart';
import 'presentation/widgets/connectivity/offline_status_indicator.dart';
import 'core/services/offline_sync_service.dart';
import 'design_system/design_system.dart';

/// Root app widget with offline support
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // Initialize offline sync service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final syncService = ref.read(offlineSyncServiceProvider);
      syncService.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch enhanced auth state that includes offline capabilities
    ref.watch(enhancedAuthStateProvider);

    // Watch theme mode from provider
    final themeMode = ref.watch(flutterThemeModeProvider);

    return MaterialApp.router(
      title: 'Flutter Auth Demo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _createRouter(ref),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Wrap with offline status indicator
        return Scaffold(
          body: Stack(
            children: [
              child ?? const SizedBox.shrink(),

              // Show offline status indicator at the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    color: Colors.transparent,
                    child: const OfflineStatusIndicator(
                      showDetails: false,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Router configuration using GoRouter with offline support
  GoRouter _createRouter(WidgetRef ref) => GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(enhancedAuthStateProvider);
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.isAuthenticated;
      final isOfflineMode = authState.isOfflineMode;

      print(
        'Router redirect - Auth state: isLoading=$isLoading, isAuthenticated=$isAuthenticated, isOfflineMode=$isOfflineMode, location=${state.fullPath}',
      );

      // Show loading screen if auth state is still loading and we're not already there
      if (isLoading && state.fullPath != '/loading') {
        print('Redirecting to loading screen');
        return '/loading';
      }

      // If auth state is loaded and we're on loading screen, redirect appropriately
      if (!isLoading && state.fullPath == '/loading') {
        if (isAuthenticated) {
          print(
            'Auth loaded and authenticated, redirecting from loading to main',
          );
          return '/main';
        } else {
          print(
            'Auth loaded but not authenticated, redirecting from loading to login',
          );
          return '/login';
        }
      }

      // Public routes that don't require authentication
      final publicRoutes = ['/login', '/register', '/loading'];
      final isPublicRoute = publicRoutes.contains(state.fullPath);

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isLoading && !isPublicRoute) {
        print('Not authenticated, redirecting to login');
        return '/login';
      }

      // If authenticated but trying to access public route (except loading), redirect to appropriate screen
      if (isAuthenticated &&
          !isLoading &&
          isPublicRoute &&
          state.fullPath != '/loading') {
        print('Authenticated, redirecting from public route to main');
        return '/main';
      }

      print('No redirect needed');
      return null; // No redirect needed
    },
    routes: [
      // Loading screen for auth state initialization
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),

      // Authentication routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Protected routes
      GoRoute(path: '/', redirect: (context, state) => '/main'),
      GoRoute(
        path: '/main',
        builder: (context, state) =>
            const NotSuspendedGate(child: MainScreen()),
      ),
    ],
  );
}

/// Loading widget shown during authentication state changes
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

/// Error widget for displaying authentication errors
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Welcome screen for unverified users
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.pending_actions, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'Welcome, ${currentUser?.name ?? 'User'}!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your account has been created successfully.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your account is currently pending verification. Please wait for an administrator to verify your account.',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to profile to see full account details
                context.go('/profile');
              },
              icon: const Icon(Icons.person),
              label: const Text('View Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
