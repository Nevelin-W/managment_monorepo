import 'package:flutter/material.dart';
import 'settings_card.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final List<Widget> children;
  final dynamic themeColors;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    required this.themeColors,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: titleColor ?? Colors.grey[500],
                letterSpacing: 1.2,
              ),
            ),
          ),
          SettingsCard(
            themeColors: themeColors,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}