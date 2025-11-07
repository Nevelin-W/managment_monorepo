import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../common/grid_painter.dart';

/// Reusable layout for all authentication screens
/// Provides consistent background, glows, and structure
class AuthScreenLayout extends StatelessWidget {
  final ThemeColors themeColors;
  final Widget header;
  final Widget child;
  final Widget? footer;

  const AuthScreenLayout({
    super.key,
    required this.themeColors,
    required this.header,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColors.background,
            themeColors.surface,
            themeColors.background,
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildGridBackground(),
          _buildGlowEffects(),
          _buildScrollableContent(),
        ],
      ),
    );
  }

  Widget _buildGridBackground() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: CustomPaint(
          painter: GridPainter(
            color: themeColors.primary,
            step: 40.0,
          ),
        ),
      ),
    );
  }

  Widget _buildGlowEffects() {
    return Stack(
      children: [
        _buildGlow(
          top: -100,
          right: -100,
          color: themeColors.primary,
          opacity: 0.15,
        ),
        _buildGlow(
          bottom: -100,
          left: -100,
          color: themeColors.secondary,
          opacity: 0.1,
        ),
      ],
    );
  }

  Widget _buildGlow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                header,
                const SizedBox(height: 48),
                child,
                if (footer != null) ...[
                  const SizedBox(height: 24),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}