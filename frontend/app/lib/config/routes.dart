// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/subscriptions/subscriptions_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Route names as constants for type-safe navigation
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const emailVerification = '/email-verification';
  static const home = '/home';
  static const subscriptions = '/home/subscriptions';
  static const settings = '/home/settings';
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
        // Splash Route
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          pageBuilder: (context, state) => _buildPageTransition(
            child: const SplashScreen(),
            state: state,
          ),
        ),
        
        // Auth Routes
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
        
        // Home Route with nested routes
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => _buildPageTransition(
            child: const HomeScreen(),
            state: state,
          ),
          routes: [
            // Nested subscriptions route
            GoRoute(
              path: 'subscriptions',
              name: 'subscriptions',
              pageBuilder: (context, state) => _buildPageTransition(
                child: const SubscriptionsScreen(),
                state: state,
              ),
            ),
            
            // Nested settings route
            GoRoute(
              path: 'settings',
              name: 'settings',
              pageBuilder: (context, state) => _buildPageTransition(
                child: const SettingsScreen(),
                state: state,
              ),
            ),
          ],
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

/// Extension methods for type-safe navigation
extension AppRouterExtension on BuildContext {
  /// Navigate to login screen
  void goToLogin() => go(AppRoutes.login);
  
  /// Navigate to signup screen
  void goToSignup() => go(AppRoutes.signup);
  
  /// Navigate to email verification with email parameter
  void goToEmailVerification(String email) {
    go(Uri(
      path: AppRoutes.emailVerification,
      queryParameters: {'email': email},
    ).toString());
  }
  
  /// Navigate to home screen
  void goToHome() => go(AppRoutes.home);
  
  /// Navigate to subscriptions screen
  void goToSubscriptions() => go(AppRoutes.subscriptions);
  
  /// Navigate to settings screen
  void goToSettings() => go(AppRoutes.settings);
}

// Usage in widgets:
// context.goToLogin();
// context.goToEmailVerification('user@example.com');
// context.go(AppRoutes.home);