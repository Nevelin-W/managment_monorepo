import 'package:flutter/material.dart';

/// Reusable dialog wrapper with consistent styling
class DialogWrapper extends StatelessWidget {
  final Widget header;
  final Widget content;
  final Widget actions;

  const DialogWrapper({
    super.key,
    required this.header,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.92 : 500.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 16 : 40,
        vertical: 24,
      ),
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: content,
              ),
            ),
            actions,
          ],
        ),
      ),
    );
  }
}