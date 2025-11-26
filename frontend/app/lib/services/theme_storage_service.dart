import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../utils/app_logger.dart';

/// Service for persisting theme preferences across sessions
/// Platform-agnostic: works on both web and mobile
class ThemeStorageService {
  static const String _themeKey = 'app_theme';
  static final _log = AppLogger.scope('ThemeStorageService');

  /// Save the current theme preference
  static Future<bool> saveTheme(AppThemeType theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_themeKey, theme.name);
      
      if (success) {
        _log.info('Theme saved successfully', {'theme': theme.name});
      } else {
        _log.warning('Failed to save theme', {'theme': theme.name});
      }
      
      return success;
    } catch (e, stackTrace) {
      _log.error('Error saving theme', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Load the saved theme preference
  /// Returns null if no theme was previously saved
  static Future<AppThemeType?> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString(_themeKey);
      
      if (themeName == null) {
        _log.debug('No saved theme found');
        return null;
      }

      // Convert string back to enum
      try {
        final theme = AppThemeType.values.firstWhere(
          (t) => t.name == themeName,
        );
        _log.info('Theme loaded successfully', {'theme': themeName});
        return theme;
      } catch (e) {
        _log.warning('Invalid theme name found in storage', {
          'themeName': themeName,
        });
        return null;
      }
    } catch (e, stackTrace) {
      _log.error('Error loading theme', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Clear the saved theme preference
  static Future<bool> clearTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_themeKey);
      
      if (success) {
        _log.info('Theme preference cleared');
      }
      
      return success;
    } catch (e, stackTrace) {
      _log.error('Error clearing theme', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}