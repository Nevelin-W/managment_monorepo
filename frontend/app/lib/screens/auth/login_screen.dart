import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/auth/auth_screen_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndRedirect();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check again when dependencies change (e.g., when navigating back)
    _checkAndRedirect();
  }

  void _checkAndRedirect() {
    // Use addPostFrameCallback to ensure the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final authProvider = context.read<AuthProvider>();
      
      // If user is already authenticated, redirect to home
      if (authProvider.isAuthenticated) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.select<ThemeProvider, ThemeColors>(
      (provider) => provider.themeColors,
    );

    // Listen to auth changes and redirect if authenticated
    final isAuthenticated = context.select<AuthProvider, bool>(
      (provider) => provider.isAuthenticated,
    );

    // If authenticated during build, schedule redirect
    if (isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/home');
        }
      });
    }

    return Scaffold(
      body: AuthScreenLayout(
        themeColors: themeColors,
        header: _LoginHeader(themeColors: themeColors),
        footer: _SignUpFooter(themeColors: themeColors),
        child: LoginForm(themeColors: themeColors),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  final ThemeColors themeColors;

  const _LoginHeader({required this.themeColors});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: themeColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: themeColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.lock_outline,
              color: themeColors.primary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 32,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            children: [
              const TextSpan(text: 'Bear'),
              TextSpan(
                text: 'Minimum',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: themeColors.primary,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          '> Just the essentials_',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11,
            fontFamily: 'monospace',
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SignUpFooter extends StatelessWidget {
  final ThemeColors themeColors;

  const _SignUpFooter({required this.themeColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () => context.go('/signup'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: themeColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}