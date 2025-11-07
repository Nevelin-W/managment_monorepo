import 'package:flutter/material.dart';

/// Reusable grid painter for background patterns
/// 
/// Usage:
/// ```dart
/// CustomPaint(
///   painter: GridPainter(
///     color: Colors.blue,
///     step: 50.0,
///   ),
/// )
/// ```
class GridPainter extends CustomPainter {
  final Color color;
  final double step;
  final double strokeWidth;

  const GridPainter({
    required this.color,
    this.step = 50.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = strokeWidth
      ..isAntiAlias = false; // Performance: disable AA for grid lines

    // Draw vertical lines
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.step != step ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}