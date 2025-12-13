import 'package:flutter/material.dart';

/// Reusable form switch with consistent styling
class FormSwitch extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;
  final String title;
  final String activeSubtitle;
  final String inactiveSubtitle;

  const FormSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.activeSubtitle,
    required this.inactiveSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          value ? activeSubtitle : inactiveSubtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
      ),
    );
  }
}