import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'grid_painter.dart';

/// Reusable screen background with gradient, grid, and glow effects
class ScreenBackground extends StatelessWidget {
  final ThemeColors themeColors;
  final Widget child;
  final Alignment glowAlignment;

  const ScreenBackground({
    super.key,
    required this.themeColors,
    required this.child,
    this.glowAlignment = Alignment.topRight,
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
          // Subtle grid background
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: GridPainter(color: themeColors.primary),
              ),
            ),
          ),

          // Glow effect
          _buildGlowEffect(),

          // Main content
          child,
        ],
      ),
    );
  }

  Widget _buildGlowEffect() {
    final isTop = glowAlignment == Alignment.topRight || 
                  glowAlignment == Alignment.topLeft;
    final isLeft = glowAlignment == Alignment.topLeft || 
                   glowAlignment == Alignment.bottomLeft;

    return Positioned(
      top: isTop ? -100 : null,
      bottom: isTop ? null : -100,
      left: isLeft ? -100 : null,
      right: isLeft ? null : -100,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              themeColors.primary.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}