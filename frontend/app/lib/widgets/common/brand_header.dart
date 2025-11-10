import 'package:flutter/material.dart';
import '../../config/theme.dart';

class BrandHeader extends StatelessWidget {
  final ThemeColors themeColors;
  final IconData icon;

  const BrandHeader({
    super.key,
    required this.themeColors,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon container (custom per screen)
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
              icon,
              color: themeColors.primary,
              size: 28,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Brand name
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

        // Slogan
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