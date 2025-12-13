import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';

enum InfoBoxType { info, error, success }

/// Reusable info/error/success message box
class InfoBox extends StatelessWidget {
  final ThemeColors themeColors;
  final IconData icon;
  final String message;
  final InfoBoxType type;

  const InfoBox({
    super.key,
    required this.themeColors,
    required this.icon,
    required this.message,
    this.type = InfoBoxType.info,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: type == InfoBoxType.info ? 16 : 20,
            color: colors.icon,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.text,
                fontSize: type == InfoBoxType.info ? 12 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _InfoBoxColors _getColors() {
    switch (type) {
      case InfoBoxType.error:
        return _InfoBoxColors(
          background: Colors.red.withValues(alpha: 0.1),
          border: Colors.red.withValues(alpha: 0.3),
          icon: Colors.red,
          text: Colors.red,
        );
      case InfoBoxType.success:
        return _InfoBoxColors(
          background: themeColors.primary.withValues(alpha: 0.1),
          border: themeColors.primary.withValues(alpha: 0.3),
          icon: themeColors.primary,
          text: themeColors.primary,
        );
      case InfoBoxType.info:
        return _InfoBoxColors(
          background: Colors.white.withValues(alpha: 0.05),
          border: themeColors.primary.withValues(alpha: 0.2),
          icon: themeColors.primary.withValues(alpha: 0.7),
          text: Colors.grey[400]!,
        );
    }
  }
}

class _InfoBoxColors {
  final Color background;
  final Color border;
  final Color icon;
  final Color text;

  const _InfoBoxColors({
    required this.background,
    required this.border,
    required this.icon,
    required this.text,
  });
}