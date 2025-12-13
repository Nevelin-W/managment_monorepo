import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';

/// Reusable empty state widget
class EmptyStateWidget extends StatelessWidget {
  final ThemeColors themeColors;
  final VoidCallback onAddPressed;
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final bool isFullPage;

  const EmptyStateWidget({
    super.key,
    required this.themeColors,
    required this.onAddPressed,
    this.title = 'No subscriptions yet',
    this.subtitle = 'Add your first subscription to get started',
    this.buttonText = 'Add Subscription',
    this.icon = Icons.inbox_outlined,
    this.isFullPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isFullPage ? 48 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconContainer(),
            SizedBox(height: isFullPage ? 32 : 24),
            Text(
              title,
              style: TextStyle(
                fontSize: isFullPage ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isFullPage ? 12 : 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isFullPage ? 40 : 32),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    final size = isFullPage ? 120.0 : 100.0;
    final iconSize = isFullPage ? 60.0 : 48.0;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColors.primary.withValues(alpha: 0.2),
            themeColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isFullPage ? 40 : 30),
        border: Border.all(
          color: themeColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: themeColors.primary.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: onAddPressed,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        buttonText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isFullPage ? 15 : 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: themeColors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: isFullPage ? 18 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isFullPage ? 14 : 12),
        ),
        elevation: 8,
        shadowColor: themeColors.primary.withValues(alpha: 0.5),
      ),
    );
  }
}