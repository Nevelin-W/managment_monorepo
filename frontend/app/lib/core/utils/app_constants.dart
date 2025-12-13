/// Application-wide constants for consistent spacing, sizing, and styling

class AppSpacing {
  // Padding values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  
  // Page padding
  static const double pageHorizontal = 24.0;
  static const double pageVertical = 16.0;
  
  // Card padding
  static const double cardPadding = 20.0;
  static const double cardPaddingCompact = 16.0;
  
  // List spacing
  static const double listItemGap = 12.0;
  static const double listItemGapLarge = 16.0;
  static const double listBottomPadding = 100.0;
}

class AppBorderRadius {
  static const double xs = 8.0;
  static const double sm = 10.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  
  // Specific use cases
  static const double card = 16.0;
  static const double cardLarge = 20.0;
  static const double button = 12.0;
  static const double chip = 20.0;
  static const double dialog = 16.0;
}

class AppElevation {
  static const double none = 0.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  
  // Specific use cases
  static const double card = 0.0;
  static const double button = 0.0;
  static const double fab = 8.0;
}

class AppIconSize {
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 28.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 60.0;
}

class AppFontSize {
  static const double xs = 11.0;
  static const double sm = 13.0;
  static const double md = 14.0;
  static const double base = 16.0;
  static const double lg = 18.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 28.0;
  static const double huge = 32.0;
  
  // Specific use cases
  static const double body = 14.0;
  static const double bodyLarge = 16.0;
  static const double caption = 13.0;
  static const double title = 20.0;
  static const double heading = 24.0;
  static const double display = 32.0;
}

class AppOpacity {
  static const double disabled = 0.38;
  static const double faint = 0.03;
  static const double subtle = 0.1;
  static const double light = 0.2;
  static const double medium = 0.3;
  static const double strong = 0.5;
  static const double veryStrong = 0.6;
}

class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  // Specific use cases
  static const Duration snackbar = Duration(seconds: 3);
  static const Duration snackbarLong = Duration(seconds: 5);
  static const Duration loadingDebounce = Duration(milliseconds: 300);
}

class AppConstraints {
  // Max widths
  static const double dialogMaxWidth = 500.0;
  static const double cardMaxWidth = 600.0;
  
  // Min heights
  static const double buttonMinHeight = 48.0;
  static const double textFieldMinHeight = 56.0;
  
  // App bar
  static const double appBarExpandedHeight = 180.0;
  static const double appBarExpandedHeightLarge = 170.0;
}

class AppGridConstants {
  static const double gridSpacing = 50.0;
  static const double glowSize = 250.0;
  static const double glowOffset = -100.0;
}