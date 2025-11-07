import 'package:flutter/material.dart';

/// Reusable gradient button with loading state
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Gradient gradient;
  final bool isLoading;
  final double height;
  final BorderRadius? borderRadius;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.gradient,
    this.isLoading = false,
    this.height = 52,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed != null && !isLoading ? gradient : null,
        color: onPressed == null || isLoading 
            ? Colors.grey.withValues(alpha: 0.3) 
            : null,
        borderRadius: effectiveBorderRadius,
        boxShadow: onPressed != null && !isLoading
            ? [
                BoxShadow(
                  color: _getGradientColor().withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: effectiveBorderRadius,
          ),
          disabledBackgroundColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : child,
      ),
    );
  }

  Color _getGradientColor() {
    if (gradient is LinearGradient) {
      final colors = (gradient as LinearGradient).colors;
      return colors.isNotEmpty ? colors.first : Colors.blue;
    }
    return Colors.blue;
  }
}