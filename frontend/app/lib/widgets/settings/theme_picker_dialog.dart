import 'package:flutter/material.dart';
import '../../providers/theme_provider.dart';
import '../../config/theme.dart';

class ThemePickerDialog extends StatefulWidget {
  final ThemeProvider themeProvider;

  const ThemePickerDialog({
    super.key,
    required this.themeProvider,
  });

  @override
  State<ThemePickerDialog> createState() => _ThemePickerDialogState();
}

class _ThemePickerDialogState extends State<ThemePickerDialog> {
  late AppThemeType _selectedTheme;
  late AppThemeType _originalTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.themeProvider.currentTheme;
    _originalTheme = widget.themeProvider.currentTheme;
  }

  ThemeColors _getThemeColors(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.emerald:
        return ThemeColors.emerald;
      case AppThemeType.ocean:
        return ThemeColors.ocean;
      case AppThemeType.sunset:
        return ThemeColors.sunset;
      case AppThemeType.purple:
        return ThemeColors.purple;
      case AppThemeType.mint:
        return ThemeColors.mint;
      case AppThemeType.rose:
        return ThemeColors.rose;
    }
  }

  String _getThemeName(AppThemeType theme) {
    return theme.name[0].toUpperCase() + theme.name.substring(1);
  }

  void _previewTheme(AppThemeType theme) {
    setState(() => _selectedTheme = theme);
    widget.themeProvider.setTheme(theme);
  }

  void _saveTheme() {
    // Theme is already applied, just close
    Navigator.of(context).pop(true);
  }

  void _cancelTheme() {
    // Revert to original theme
    widget.themeProvider.setTheme(_originalTheme);
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final currentColors = _getThemeColors(_selectedTheme);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : 20,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isWeb ? 600 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              currentColors.surface,
              currentColors.background,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: currentColors.primary.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(currentColors),

            // Theme Grid
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _buildThemeGrid(isWeb),
              ),
            ),

            // Action Buttons
            _buildActions(currentColors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.palette_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Theme',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pick a theme to personalize your experience',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeGrid(bool isWeb) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isWeb ? 3 : 1;
        final spacing = isWeb ? 16.0 : 12.0;
        final childAspectRatio = isWeb ? 1.2 : 2.5;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: AppThemeType.values.length,
          itemBuilder: (context, index) {
            final theme = AppThemeType.values[index];
            return _buildThemeCard(theme, isWeb);
          },
        );
      },
    );
  }

  Widget _buildThemeCard(AppThemeType theme, bool isWeb) {
    final colors = _getThemeColors(theme);
    final isSelected = _selectedTheme == theme;
    final themeName = _getThemeName(theme);

    return GestureDetector(
      onTap: () => _previewTheme(theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surface.withValues(alpha: 0.8),
              colors.background.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Color Preview Circles
            Positioned(
              top: isWeb ? 16 : 20,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildColorCircle(colors.primary, isWeb ? 22 : 28),
                  SizedBox(width: isWeb ? 4 : 6),
                  _buildColorCircle(colors.secondary, isWeb ? 18 : 24),
                  SizedBox(width: isWeb ? 4 : 6),
                  _buildColorCircle(colors.tertiary, isWeb ? 14 : 20),
                ],
              ),
            ),
            // Theme Name
            Positioned(
              bottom: isWeb ? 16 : 20,
              left: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    themeName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isWeb ? 15 : 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[300],
                    ),
                  ),
                  // Only show SELECTED badge on web
                  if (isWeb && isSelected) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'SELECTED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Checkmark (more prominent on mobile)
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(isWeb ? 4 : 6),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: isWeb ? 16 : 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'Cancel',
              onPressed: _cancelTheme,
              isPrimary: false,
              colors: colors,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              label: 'Apply Theme',
              onPressed: _saveTheme,
              isPrimary: true,
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    required ThemeColors colors,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [colors.primary, colors.secondary],
                  )
                : null,
            color: isPrimary ? null : colors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }
}