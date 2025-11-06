import 'package:flutter/material.dart';
import '../config/theme.dart';

enum AppThemeType {
  emerald,
  ocean,
  sunset,
  purple,
  mint,
  rose,
}

class ThemeProvider extends ChangeNotifier {
  AppThemeType _currentTheme = AppThemeType.mint;
  
  AppThemeType get currentTheme => _currentTheme;
  
  ThemeData get themeData {
    switch (_currentTheme) {
      case AppThemeType.emerald:
        return AppTheme.emeraldTheme;
      case AppThemeType.ocean:
        return AppTheme.oceanTheme;
      case AppThemeType.sunset:
        return AppTheme.sunsetTheme;
      case AppThemeType.purple:
        return AppTheme.purpleTheme;
      case AppThemeType.mint:
        return AppTheme.mintTheme;
      case AppThemeType.rose:
        return AppTheme.roseTheme;
    }
  }
  
  ThemeColors get themeColors {
    switch (_currentTheme) {
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
  
  String get themeName {
    switch (_currentTheme) {
      case AppThemeType.emerald:
        return 'Emerald';
      case AppThemeType.ocean:
        return 'Ocean';
      case AppThemeType.sunset:
        return 'Sunset';
      case AppThemeType.purple:
        return 'Purple';
      case AppThemeType.mint:
        return 'Mint';
      case AppThemeType.rose:
        return 'Rose';
    }
  }
  
  void setTheme(AppThemeType theme) {
    _currentTheme = theme;
    notifyListeners();
  }
  
  // Get all available themes for UI picker
  List<AppThemeType> get availableThemes => AppThemeType.values;
}