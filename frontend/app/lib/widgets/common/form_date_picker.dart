import 'package:flutter/material.dart';

/// Reusable date picker field with consistent styling
class FormDatePicker extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime date;
  final VoidCallback onTap;

  const FormDatePicker({
    super.key,
    required this.label,
    required this.icon,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: colorScheme.primary),
          filled: true,
          fillColor: colorScheme.surface.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              style: textTheme.bodyLarge,
            ),
            Icon(
              Icons.arrow_drop_down,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}