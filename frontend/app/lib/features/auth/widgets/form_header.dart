import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';

/// Reusable header component for form containers
class FormHeader extends StatelessWidget {
  final ThemeColors themeColors;
  final String title;
  final String subtitle;

  const FormHeader({
    super.key,
    required this.themeColors,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: themeColors.primary.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                themeColors.primary.withValues(alpha: 0.5),
                themeColors.secondary.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}