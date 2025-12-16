import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Core screens
import '../../features/home/screens/splash_screen.dart';

// Auth screens
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';

// Main hub
import '../../features/home/screens/main_home_screen.dart';

// Settings (kept from original structure)
import '../../features/settings/screens/settings_screen.dart';

// Subscription app screens
import '../../../features/subscriptions/screens/subscriptions_home_screen.dart';
import '../../../features/subscriptions/screens/subscriptions_list_screen.dart';
import '../../features/subscriptions/screens/subscription_settings_screen.dart';

/// Route names as constants for type-safe navigation
abstract class AppRoutes {
  // Core routes
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const emailVerification = '/email-verification';
  
  // Main hub
  static const home = '/home';
  static const settings = '/settings';
  
  // Subscription app routes
  static const subscriptions = '/subscriptions';
  static const subscriptionsList = '/subscriptions/list';
    static const subscriptionSettings = '/subscriptions/settings';
  
  // Calendar app routes (placeholder)
  static const calendar = '/calendar';
  
  // Workout app routes (placeholder)
  static const workouts = '/workouts';
}

/// Route configuration with navigation guards and error handling
class AppRouter {
  // Singleton pattern for router instance
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  GoRouter? _router;
  GoRouter get router => _router!;

  /// Initialize router with optional auth state
  void initialize({
    required bool Function() isAuthenticated,
    bool enableLogging = false,
  }) {
    // Only initialize once
    if (_router != null) return;
    
    _router = GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: enableLogging,
      
      // Global navigation guard
      redirect: (context, state) {
        final isAuth = isAuthenticated();
        final isGoingToAuth = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.signup ||
            state.matchedLocation == AppRoutes.emailVerification;
        
        // Redirect authenticated users away from auth screens
        if (isAuth && isGoingToAuth) {
          return AppRoutes.home;
        }
        
        // Redirect unauthenticated users to login (except splash)
        if (!isAuth && 
            !isGoingToAuth && 
            state.matchedLocation != AppRoutes.splash) {
          return AppRoutes.login;
        }
        
        return null; // No redirect needed
      },
      
      // Custom error page
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
      
      routes: [
        // ==================== CORE ROUTES ====================
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          pageBuilder: (context, state) => _buildPageTransition(
            child: const SplashScreen(),
            state: state,
          ),
        ),
        
        // ==================== AUTH ROUTES ====================
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (context, state) => _buildPageTransition(
            child: const LoginScreen(),
            state: state,
          ),
        ),
        
        GoRoute(
          path: AppRoutes.signup,
          name: 'signup',
          pageBuilder: (context, state) => _buildPageTransition(
            child: const SignupScreen(),
            state: state,
          ),
        ),
        
        GoRoute(
          path: AppRoutes.emailVerification,
          name: 'emailVerification',
          pageBuilder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return _buildPageTransition(
              child: EmailVerificationScreen(email: email),
              state: state,
            );
          },
        ),
        
        // ==================== MAIN HUB ====================
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => _buildPageTransition(
            child: const MainHomeScreen(),
            state: state,
          ),
        ),
        
        // ==================== SETTINGS ====================
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          pageBuilder: (context, state) => _buildPageTransition(
            child: const SettingsScreen(),
            state: state,
          ),
        ),
        
        // ==================== SUBSCRIPTION APP ====================
        GoRoute(
          path: AppRoutes.subscriptions,
          name: 'subscriptions',
          pageBuilder: (context, state) => _buildPageTransition(
            child: const SubscriptionsHomeScreen(),
            state: state,
          ),
          routes: [
            GoRoute(
              path: 'list',
              name: 'subscriptionsList',
              pageBuilder: (context, state) => _buildPageTransition(
                child: const SubscriptionsListScreen(),
                state: state,
              ),
            ),
            GoRoute(
              path: 'settings',
              name: 'subscriptionSettings',
              pageBuilder: (context, state) => _buildPageTransition(
                child: const SubscriptionSettingsScreen(),
                state: state,
              ),
            ),
          ],
        ),
        
        // ==================== CALENDAR APP (PLACEHOLDER) ====================
        GoRoute(
          path: AppRoutes.calendar,
          name: 'calendar',
          pageBuilder: (context, state) => _buildPageTransition(
            child: _PlaceholderScreen(
              title: 'Family Calendar',
              icon: Icons.calendar_today,
            ),
            state: state,
          ),
        ),
        
        // ==================== WORKOUT APP (PLACEHOLDER) ====================
        GoRoute(
          path: AppRoutes.workouts,
          name: 'workouts',
          pageBuilder: (context, state) => _buildPageTransition(
            child: _PlaceholderScreen(
              title: 'Workouts',
              icon: Icons.fitness_center,
            ),
            state: state,
          ),
        ),
      ],
    );
  }

  /// Build page transition with custom animation
  Page<dynamic> _buildPageTransition({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }
}

/// Placeholder screen for upcoming features
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/home'),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 80,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This feature is under development',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension methods for type-safe navigation
extension AppRouterExtension on BuildContext {
  // Auth navigation
  void goToLogin() => go(AppRoutes.login);
  void goToSignup() => go(AppRoutes.signup);
  void goToEmailVerification(String email) {
    go(Uri(
      path: AppRoutes.emailVerification,
      queryParameters: {'email': email},
    ).toString());
  }
  
  // Main hub
  void goToHome() => go(AppRoutes.home);
  void goToSettings() => go(AppRoutes.settings);
  
  // Subscription app
  void goToSubscriptions() => go(AppRoutes.subscriptions);
  void goToSubscriptionsList() => go(AppRoutes.subscriptionsList);
  void goToSubscriptionSettings() => go(AppRoutes.subscriptionSettings);
  
  // Calendar app
  void goToCalendar() => go(AppRoutes.calendar);
  
  // Workout app
  void goToWorkouts() => go(AppRoutes.workouts);
}