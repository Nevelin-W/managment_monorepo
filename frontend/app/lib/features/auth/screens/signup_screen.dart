import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/widgets/signup_form.dart';
import '../../../features/home/providers/theme_provider.dart';
import '../../../core/config/theme.dart';
import '../../../features/auth/widgets/auth_screen_layout.dart';
import '../../../core/widgets/common/brand_header.dart';
import '../../../features/auth/widgets/auth_footer.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColors = context.select<ThemeProvider, ThemeColors>(
      (provider) => provider.themeColors,
    );

    return Scaffold(
      body: AuthScreenLayout(
        themeColors: themeColors,
        header: BrandHeader(
          themeColors: themeColors,
          icon: Icons.lock_outline,
        ),
        footer: AuthFooter(
          themeColors: themeColors,
          promptText: 'Already have an account? ',
          actionText: 'Sign In',
          onActionPressed: () => context.go('/login'),
        ),
        child: SignupForm(themeColors: themeColors),
      ),
    );
  }
}