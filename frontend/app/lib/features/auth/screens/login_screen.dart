import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../home/providers/theme_provider.dart';
import '../../../core/config/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/widgets/login_form.dart';
import '../../../features/auth/widgets/auth_screen_layout.dart';
import '../../../core/widgets/common/brand_header.dart';
import '../../../features/auth/widgets/auth_footer.dart';

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
    _checkAndRedirect();
  }

  void _checkAndRedirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
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

    final isAuthenticated = context.select<AuthProvider, bool>(
      (provider) => provider.isAuthenticated,
    );

    if (isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
    }

    return Scaffold(
      body: AuthScreenLayout(
        themeColors: themeColors,
        header: BrandHeader(
          themeColors: themeColors,
          icon: Icons.lock_outline,
        ),
        footer: AuthFooter(
          themeColors: themeColors,
          promptText: "Don't have an account? ",
          actionText: 'Sign Up',
          onActionPressed: () => context.go('/signup'),
        ),
        child: LoginForm(themeColors: themeColors),
      ),
    );
  }
}