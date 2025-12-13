import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/theme_storage_service.dart';
import '../../../core/utils/app_logger.dart';

enum AppThemeType {
  emerald,
  ocean,
  sunset,
  purple,
  mint,
  rose,
}

class ThemeProvider extends ChangeNotifier {
  static final _log = AppLogger.scope('ThemeProvider');
  
  AppThemeType _currentTheme = AppThemeType.sunset;
  bool _isInitialized = false;
  
  AppThemeType get currentTheme => _currentTheme;
  bool get isInitialized => _isInitialized;
  
  ThemeProvider() {
    _initializeTheme();
  }
  
  /// Initialize theme from storage on app start
  Future<void> _initializeTheme() async {
    try {
      final savedTheme = await ThemeStorageService.loadTheme();
      
      if (savedTheme != null) {
        _currentTheme = savedTheme;
        _log.info('Theme initialized from storage', {'theme': savedTheme.name});
      } else {
        _log.debug('No saved theme, using default: ${_currentTheme.name}');
      }
    } catch (e, stackTrace) {
      _log.error('Error initializing theme', error: e, stackTrace: stackTrace);
      // Continue with default theme
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }
  
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
  
  /// Set theme and persist to storage
  Future<void> setTheme(AppThemeType theme, {bool persist = true}) async {
    if (_currentTheme == theme) return;
    
    _currentTheme = theme;
    notifyListeners();
    
    if (persist) {
      final success = await ThemeStorageService.saveTheme(theme);
      if (!success) {
        _log.warning('Failed to persist theme change', {'theme': theme.name});
      }
    }
  }
  
  /// Get all available themes for UI picker
  List<AppThemeType> get availableThemes => AppThemeType.values;
}