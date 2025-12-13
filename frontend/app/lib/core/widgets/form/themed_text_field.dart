import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';

class ThemedTextField extends StatelessWidget {
  final TextEditingController controller;
  final ThemeColors themeColors;
  final String labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;

  const ThemedTextField({
    super.key,
    required this.controller,
    required this.themeColors,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofillHints: autofillHints,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: themeColors.primary.withValues(alpha: 0.7),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: themeColors.primary.withValues(alpha: 0.7),
              )
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: themeColors.background.withValues(alpha: 0.5),
        border: _buildBorder(themeColors.primary.withValues(alpha: 0.2)),
        enabledBorder: _buildBorder(themeColors.primary.withValues(alpha: 0.2)),
        focusedBorder: _buildBorder(themeColors.primary, width: 2),
        errorBorder: _buildBorder(themeColors.tertiary),
        focusedErrorBorder: _buildBorder(themeColors.tertiary, width: 2),
      ),
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}