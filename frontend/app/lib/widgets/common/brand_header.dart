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
        // Icon container with gradient
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeColors.primary.withValues(alpha: 0.2),
                themeColors.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeColors.primary.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: themeColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: themeColors.primary,
              size: 32,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Brand name - Bear (white) + Minimum (primary)
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 36,
              fontFamily: 'monospace',
              letterSpacing: -0.5,
            ),
            children: [
              const TextSpan(
                text: 'Bear',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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

        // Slogan with primary color
        Text(
          '> Just the essentials_',
          style: TextStyle(
            color: themeColors.primary.withValues(alpha: 0.7),
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