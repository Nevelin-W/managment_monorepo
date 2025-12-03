import 'package:flutter/material.dart';

/// Reusable form dropdown with consistent styling
class FormDropdown<T> extends StatelessWidget {
  final T value;
  final String label;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  const FormDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<T>(
      value: value,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      items: items,
      onChanged: onChanged,
      menuMaxHeight: 300,
      isDense: false,
      isExpanded: true,
      icon: Icon(
        Icons.arrow_drop_down,
        color: colorScheme.primary,
      ),
    );
  }
}