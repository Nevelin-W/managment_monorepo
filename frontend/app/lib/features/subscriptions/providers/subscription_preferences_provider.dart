// lib/features/subscriptions/providers/subscription_preferences_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/app_logger.dart';

/// Provider for managing subscription app preferences
/// Persists settings to local storage and notifies listeners of changes
class SubscriptionPreferencesProvider extends ChangeNotifier {
  static final _log = AppLogger.scope('SubscriptionPreferencesProvider');

  // Notification settings
  bool _renewalReminders = true;
  bool _weekBeforeReminder = true;
  bool _dayBeforeReminder = true;
  bool _onDayReminder = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  // Display settings
  String _currency = 'USD';
  String _dateFormat = 'MM/DD/YYYY';
  bool _showCents = true;
  bool _compactView = false;
  String _defaultSortOrder = 'upcoming';

  // Data & Privacy
  bool _syncEnabled = true;
  bool _analyticsEnabled = true;

  bool _isInitialized = false;

  // Getters
  bool get renewalReminders => _renewalReminders;
  bool get weekBeforeReminder => _weekBeforeReminder;
  bool get dayBeforeReminder => _dayBeforeReminder;
  bool get onDayReminder => _onDayReminder;
  bool get emailNotifications => _emailNotifications;
  bool get pushNotifications => _pushNotifications;
  
  String get currency => _currency;
  String get dateFormat => _dateFormat;
  bool get showCents => _showCents;
  bool get compactView => _compactView;
  String get defaultSortOrder => _defaultSortOrder;
  
  bool get syncEnabled => _syncEnabled;
  bool get analyticsEnabled => _analyticsEnabled;
  
  bool get isInitialized => _isInitialized;

  // Currency symbols
  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'CAD': 'CAD\$',
    'AUD': 'AUD\$',
    'JPY': '¥',
  };

  String get currencySymbol => currencySymbols[_currency] ?? '\$';

  SubscriptionPreferencesProvider() {
    _initializePreferences();
  }

  /// Load preferences from storage on initialization
  Future<void> _initializePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _renewalReminders = prefs.getBool('sub_renewal_reminders') ?? true;
      _weekBeforeReminder = prefs.getBool('sub_week_before_reminder') ?? true;
      _dayBeforeReminder = prefs.getBool('sub_day_before_reminder') ?? true;
      _onDayReminder = prefs.getBool('sub_on_day_reminder') ?? false;
      _emailNotifications = prefs.getBool('sub_email_notifications') ?? true;
      _pushNotifications = prefs.getBool('sub_push_notifications') ?? true;

      _currency = prefs.getString('sub_currency') ?? 'USD';
      _dateFormat = prefs.getString('sub_date_format') ?? 'MM/DD/YYYY';
      _showCents = prefs.getBool('sub_show_cents') ?? true;
      _compactView = prefs.getBool('sub_compact_view') ?? false;
      _defaultSortOrder = prefs.getString('sub_default_sort_order') ?? 'upcoming';

      _syncEnabled = prefs.getBool('sub_sync_enabled') ?? true;
      _analyticsEnabled = prefs.getBool('sub_analytics_enabled') ?? true;

      _isInitialized = true;
      notifyListeners();
      
      _log.info('Preferences initialized successfully');
    } catch (e, stackTrace) {
      _log.error('Failed to initialize preferences', error: e, stackTrace: stackTrace);
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Update notification settings
  Future<void> setRenewalReminders(bool value) async {
    _renewalReminders = value;
    notifyListeners();
    await _saveBool('sub_renewal_reminders', value);
  }

  Future<void> setWeekBeforeReminder(bool value) async {
    _weekBeforeReminder = value;
    notifyListeners();
    await _saveBool('sub_week_before_reminder', value);
  }

  Future<void> setDayBeforeReminder(bool value) async {
    _dayBeforeReminder = value;
    notifyListeners();
    await _saveBool('sub_day_before_reminder', value);
  }

  Future<void> setOnDayReminder(bool value) async {
    _onDayReminder = value;
    notifyListeners();
    await _saveBool('sub_on_day_reminder', value);
  }

  Future<void> setEmailNotifications(bool value) async {
    _emailNotifications = value;
    notifyListeners();
    await _saveBool('sub_email_notifications', value);
  }

  Future<void> setPushNotifications(bool value) async {
    _pushNotifications = value;
    notifyListeners();
    await _saveBool('sub_push_notifications', value);
  }

  /// Update display settings
  Future<void> setCurrency(String value) async {
    _currency = value;
    notifyListeners();
    await _saveString('sub_currency', value);
  }

  Future<void> setDateFormat(String value) async {
    _dateFormat = value;
    notifyListeners();
    await _saveString('sub_date_format', value);
  }

  Future<void> setShowCents(bool value) async {
    _showCents = value;
    notifyListeners();
    await _saveBool('sub_show_cents', value);
  }

  Future<void> setCompactView(bool value) async {
    _compactView = value;
    notifyListeners();
    await _saveBool('sub_compact_view', value);
  }

  Future<void> setDefaultSortOrder(String value) async {
    _defaultSortOrder = value;
    notifyListeners();
    await _saveString('sub_default_sort_order', value);
  }

  /// Update data & privacy settings
  Future<void> setSyncEnabled(bool value) async {
    _syncEnabled = value;
    notifyListeners();
    await _saveBool('sub_sync_enabled', value);
  }

  Future<void> setAnalyticsEnabled(bool value) async {
    _analyticsEnabled = value;
    notifyListeners();
    await _saveBool('sub_analytics_enabled', value);
  }

  /// Helper methods for persistence
  Future<void> _saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      _log.warning('Failed to save bool preference', {'key': key, 'error': e});
    }
  }

  Future<void> _saveString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      _log.warning('Failed to save string preference', {'key': key, 'error': e});
    }
  }

  /// Utility methods for formatting based on preferences
  
  /// Format amount based on currency and showCents settings
  String formatAmount(double amount) {
    if (_showCents) {
      return '$currencySymbol${amount.toStringAsFixed(2)}';
    } else {
      return '$currencySymbol${amount.toStringAsFixed(0)}';
    }
  }

  /// Format date based on dateFormat setting
  String formatDate(DateTime date) {
    switch (_dateFormat) {
      case 'MM/DD/YYYY':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'DD/MM/YYYY':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'YYYY-MM-DD':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      default:
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  /// Check if we should show a notification for a subscription
  bool shouldShowNotification(DateTime renewalDate) {
    if (!_renewalReminders) return false;

    final now = DateTime.now();
    final daysUntilRenewal = renewalDate.difference(now).inDays;

    if (_weekBeforeReminder && daysUntilRenewal == 7) return true;
    if (_dayBeforeReminder && daysUntilRenewal == 1) return true;
    if (_onDayReminder && daysUntilRenewal == 0) return true;

    return false;
  }

  /// Reset all preferences to defaults
  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove all subscription preference keys
      final keysToRemove = prefs.getKeys().where((key) => key.startsWith('sub_'));
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      // Reset to defaults
      _renewalReminders = true;
      _weekBeforeReminder = true;
      _dayBeforeReminder = true;
      _onDayReminder = false;
      _emailNotifications = true;
      _pushNotifications = true;
      _currency = 'USD';
      _dateFormat = 'MM/DD/YYYY';
      _showCents = true;
      _compactView = false;
      _defaultSortOrder = 'upcoming';
      _syncEnabled = true;
      _analyticsEnabled = true;

      notifyListeners();
      _log.info('Preferences reset to defaults');
    } catch (e, stackTrace) {
      _log.error('Failed to reset preferences', error: e, stackTrace: stackTrace);
    }
  }
}

