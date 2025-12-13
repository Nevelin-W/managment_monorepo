import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';

/// Orbital loading indicator with custom colors
/// 
/// Displays an animated orbital pattern with three rings and orbiting dots
class OrbitalLoadingIndicator extends StatefulWidget {
  final ThemeColors colors;
  final double size;

  const OrbitalLoadingIndicator({
    super.key,
    required this.colors,
    this.size = 80.0,
  });

  @override
  State<OrbitalLoadingIndicator> createState() =>
      _OrbitalLoadingIndicatorState();
}

class _OrbitalLoadingIndicatorState extends State<OrbitalLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _duration = Duration(milliseconds: 2000);
  static const _ringCount = 3;
  static const _fullRotation = 6.28318; // 2 * PI

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => _buildOrbitalSystem(),
      ),
    );
  }

  Widget _buildOrbitalSystem() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ..._buildOrbitalRings(),
        ..._buildOrbitingDots(),
        _buildCenterPulse(),
      ],
    );
  }

  List<Widget> _buildOrbitalRings() {
    return List.generate(_ringCount, (i) {
      final ringSize = widget.size * 0.75 - (i * widget.size * 0.1875);
      final rotation = (_controller.value * _fullRotation) + (i * 2.09);
      
      return Transform.rotate(
        angle: rotation,
        child: Container(
          width: ringSize,
          height: ringSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _getRingColor(i).withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildOrbitingDots() {
    return List.generate(_ringCount, (i) {
      final rotation = (_controller.value * _fullRotation) + (i * 2.09);
      final distance = widget.size * 0.375 - (i * widget.size * 0.09375);
      final dotColor = _getRingColor(i);
      
      return Transform.rotate(
        angle: rotation,
        child: Transform.translate(
          offset: Offset(distance, 0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  dotColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.8),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCenterPulse() {
    // Create smooth pulse using sine wave
    final pulseValue = 1.0 + (0.2 * (1 - (_controller.value * 2 - 1).abs()));
    
    return Transform.scale(
      scale: pulseValue,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              widget.colors.primary,
              widget.colors.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.colors.primary.withValues(alpha: 0.8),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRingColor(int index) {
    switch (index) {
      case 0:
        return widget.colors.primary;
      case 1:
        return widget.colors.secondary;
      case 2:
        return widget.colors.tertiary;
      default:
        return widget.colors.primary;
    }
  }
}