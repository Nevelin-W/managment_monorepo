import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';

/// Reusable container wrapper for auth forms
class FormContainer extends StatelessWidget {
  final ThemeColors themeColors;
  final Widget child;

  const FormContainer({
    super.key,
    required this.themeColors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColors.surface.withValues(alpha: 0.6),
            themeColors.background.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: themeColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: child,
        ),
      ),
    );
  }
}