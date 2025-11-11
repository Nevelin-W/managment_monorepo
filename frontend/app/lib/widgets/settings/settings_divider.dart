import 'package:flutter/material.dart';

class SettingsDivider extends StatelessWidget {
  final dynamic themeColors;

  const SettingsDivider({super.key, required this.themeColors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}