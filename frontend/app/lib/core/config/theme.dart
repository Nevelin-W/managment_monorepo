import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Theme configuration class
class AppTheme {
  // Available color schemes - Modern palettes based on color theory
  
  // Forest: Emerald green + warm amber + soft coral
  static const ColorScheme emeraldScheme = ColorScheme(
    primary: Color(0xFF10B981),      // Emerald green
    secondary: Color(0xFFF59E0B),    // Warm amber
    tertiary: Color(0xFFFF6B9D),     // Soft coral
    surface: Color(0xFF1F2937),
    error: Color(0xFFEF4444),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
  );

  // Ocean: Deep blue + cyan + coral orange (complementary)
  static const ColorScheme oceanScheme = ColorScheme(
    primary: Color(0xFF3B82F6),      // Royal blue
    secondary: Color(0xFF06B6D4),    // Cyan
    tertiary: Color(0xFFFF7849),     // Coral orange
    surface: Color(0xFF1E293B),
    error: Color(0xFFEF4444),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
  );

  // Sunset: Warm amber + vibrant red + golden yellow (keeping original)
  static const ColorScheme sunsetScheme = ColorScheme(
    primary: Color(0xFFF59E0B),
    secondary: Color(0xFFEF4444),
    tertiary: Color(0xFFFBBF24),
    surface: Color(0xFF292524),
    error: Color(0xFFDC2626),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
  );

  // Lavender: Purple + pink + mint (triadic harmony)
  static const ColorScheme purpleScheme = ColorScheme(
    primary: Color(0xFFA855F7),      // Purple
    secondary: Color(0xFFEC4899),    // Hot pink
    tertiary: Color(0xFF34D399),     // Mint green
    surface: Color(0xFF2D1B4E),
    error: Color(0xFFEF4444),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
  );

  // Arctic: Cyan + indigo + lime (cool with pop)
  static const ColorScheme mintScheme = ColorScheme(
    primary: Color(0xFF06B6D4),      // Cyan
    secondary: Color(0xFF6366F1),    // Indigo
    tertiary: Color(0xFFBEF264),     // Lime green
    surface: Color(0xFF164E63),
    error: Color(0xFFEF4444),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Color(0xFF1F2937),   // Dark text on lime
    onSurface: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
  );

  // Rose: Pink + purple + peach (analogous warm)
  static const ColorScheme roseScheme = ColorScheme(
    primary: Color(0xFFEC4899),      // Hot pink
    secondary: Color(0xFF8B5CF6),    // Violet
    tertiary: Color(0xFFFB923C),     // Peach orange
    surface: Color(0xFF4C1D3C),
    error: Color(0xFFEF4444),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
  );

  // Build theme from color scheme
  static ThemeData buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }

  // Pre-built themes
  static ThemeData emeraldTheme = buildTheme(emeraldScheme);
  static ThemeData oceanTheme = buildTheme(oceanScheme);
  static ThemeData sunsetTheme = buildTheme(sunsetScheme);
  static ThemeData purpleTheme = buildTheme(purpleScheme);
  static ThemeData mintTheme = buildTheme(mintScheme);
  static ThemeData roseTheme = buildTheme(roseScheme);

  // Light theme (keeping your original)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF10B981),
      secondary: Color(0xFF059669),
      surface: Color(0xFFFFFFFF),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    ),
    scaffoldBackgroundColor: const Color(0xFFF9FAFB),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF10B981), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Color(0xFFE5E7EB)),
      ),
    ),
  );
}

// Helper to get theme colors for splash screen
class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color error;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.error,
  });

  static ThemeColors fromColorScheme(ColorScheme scheme) {
    return ThemeColors(
      primary: scheme.primary,
      secondary: scheme.secondary,
      tertiary: scheme.tertiary,
      background: scheme.surface,
      surface: scheme.surface,
      error: scheme.error,
    );
  }

  static const ThemeColors emerald = ThemeColors(
  primary: Color(0xFF10B981),
  secondary: Color(0xFFF59E0B),
  tertiary: Color(0xFFFF6B9D),
  background: Color(0xFF111827),
  surface: Color(0xFF1F2937),
  error: Color(0xFFEF4444),
);

static const ThemeColors ocean = ThemeColors(
  primary: Color(0xFF3B82F6),
  secondary: Color(0xFF06B6D4),
  tertiary: Color(0xFFFF7849),
  background: Color(0xFF0F172A),
  surface: Color(0xFF1E293B),
  error: Color(0xFFEF4444),
);

static const ThemeColors sunset = ThemeColors(
  primary: Color(0xFFF59E0B),
  secondary: Color(0xFFEF4444),
  tertiary: Color(0xFFFBBF24),
  background: Color(0xFF1C1917),
  surface: Color(0xFF292524),
  error: Color(0xFFDC2626),
);

static const ThemeColors purple = ThemeColors(
  primary: Color(0xFFA855F7),
  secondary: Color(0xFFEC4899),
  tertiary: Color(0xFF34D399),
  background: Color(0xFF1A0B2E),
  surface: Color(0xFF2D1B4E),
  error: Color(0xFFEF4444),
);

static const ThemeColors mint = ThemeColors(
  primary: Color(0xFF06B6D4),
  secondary: Color(0xFF6366F1),
  tertiary: Color(0xFFBEF264),
  background: Color(0xFF083344),
  surface: Color(0xFF164E63),
  error: Color(0xFFEF4444),
);

static const ThemeColors rose = ThemeColors(
  primary: Color(0xFFEC4899),
  secondary: Color(0xFF8B5CF6),
  tertiary: Color(0xFFFB923C),
  background: Color(0xFF2D0A26),
  surface: Color(0xFF4C1D3C),
  error: Color(0xFFEF4444),
);
}