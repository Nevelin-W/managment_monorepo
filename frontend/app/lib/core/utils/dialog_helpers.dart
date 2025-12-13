import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../../features/subscriptions/models/subscription_model.dart';

/// Helper functions for showing common dialogs
class DialogHelpers {
  /// Show a confirmation dialog
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required ThemeColors themeColors,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? Colors.red : themeColors.primary,
            ),
            child: Text(
              confirmText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required ThemeColors themeColors,
    required String itemName,
  }) {
    return showConfirmDialog(
      context: context,
      themeColors: themeColors,
      title: 'Delete Subscription',
      message:
          'Are you sure you want to delete "$itemName"? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar({
    required BuildContext context,
    required String message,
    required Color color,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar({
    required BuildContext context,
    required String message,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

/// Reusable delete confirmation handler
class SubscriptionDeleteHandler {
  final BuildContext context;
  final ThemeColors themeColors;

  SubscriptionDeleteHandler({
    required this.context,
    required this.themeColors,
  });

  Future<void> confirmAndDelete({
    required Subscription subscription,
    required Future<void> Function(String id) deleteFunction,
    VoidCallback? onSuccess,
  }) async {
    if (!context.mounted) return;

    final confirmed = await DialogHelpers.showDeleteConfirmation(
      context: context,
      themeColors: themeColors,
      itemName: subscription.name,
    );

    if (confirmed == true && context.mounted) {
      try {
        await deleteFunction(subscription.id);

        if (context.mounted) {
          DialogHelpers.showSuccessSnackbar(
            context: context,
            message: '${subscription.name} deleted successfully',
            color: themeColors.primary,
          );
          onSuccess?.call();
        }
      } catch (e) {
        if (context.mounted) {
          DialogHelpers.showErrorSnackbar(
            context: context,
            message: 'Failed to delete subscription: $e',
          );
        }
      }
    }
  }
}