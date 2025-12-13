import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../home/providers/theme_provider.dart';
import '../../../core/config/theme.dart';
import '../../../features/auth/widgets/auth_screen_layout.dart';
import '../../../features/auth/widgets/email_verification_form.dart';
import '../../../core/widgets/common/brand_header.dart';
import '../../../features/auth/widgets/auth_footer.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

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
          promptText: 'Wrong email? ',
          actionText: 'Back to Login',
          onActionPressed: () => context.go('/login'),
        ),
        child: EmailVerificationForm(
          themeColors: themeColors,
          email: email,
        ),
      ),
    );
  }
}