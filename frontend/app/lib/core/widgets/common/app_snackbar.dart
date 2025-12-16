import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';

/// Common snackbar helper for consistent notifications
class AppSnackBar {
  /// Show success snackbar
  static void showSuccess(
    BuildContext context,
    String message, {
    ThemeColors? themeColors,
  }) {
    final colors = themeColors ?? _getThemeColors(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Show error snackbar
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Show info snackbar
  static void showInfo(
    BuildContext context,
    String message, {
    ThemeColors? themeColors,
  }) {
    final colors = themeColors ?? _getThemeColors(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeColors _getThemeColors(BuildContext context) {
    // Fallback color scheme if ThemeProvider is not available
    final colorScheme = Theme.of(context).colorScheme;
    return ThemeColors(
      primary: colorScheme.primary,
      secondary: colorScheme.secondary,
      tertiary: colorScheme.tertiary,
      background: colorScheme.background,
      surface: colorScheme.surface,
    error: colorScheme.error,
    onPrimary: colorScheme.onPrimary,
    onSecondary: colorScheme.onSecondary,
    onTertiary: colorScheme.onTertiary,
    onSurface: colorScheme.onSurface,
    onError: colorScheme.onError,
    );
  }
}