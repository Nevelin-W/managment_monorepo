/// Application Configuration
/// Values are passed as build-time arguments
class AppConfig {
  static late final String apiBaseUrl;
  static late final String userPoolId;
  static late final String region;
  static late final LogLevel logLevel;
  static bool _initialized = false;

  /// Initialize the configuration with environment values
  static void initialize({
    required String apiBaseUrl,
    required String userPoolId,
    required String region,
    LogLevel logLevel = LogLevel.warning,
  }) {
    if (_initialized) {
      throw StateError('AppConfig has already been initialized');
    }

    AppConfig.apiBaseUrl = apiBaseUrl;
    AppConfig.userPoolId = userPoolId;
    AppConfig.region = region;
    AppConfig.logLevel = logLevel;
    _initialized = true;
  }

  /// Check if configuration has been initialized
  static bool get isInitialized => _initialized;

  // API Endpoints
  static String get authLoginUrl => '$apiBaseUrl/auth/login';
  static String get authSignupUrl => '$apiBaseUrl/auth/signup';
  static String get authConfirmUrl => '$apiBaseUrl/auth/confirm';
  static String get authResendCodeUrl => '$apiBaseUrl/auth/resend-code';
  static String get authMeUrl => '$apiBaseUrl/auth/me';
  static String get subscriptionsUrl => '$apiBaseUrl/subscriptions';
  static String get authUpdateProfileUrl => '$apiBaseUrl/auth/profile';
  static String get authChangePasswordUrl => '$apiBaseUrl/auth/change-password';

  // Helper method to get subscription by ID
  static String subscriptionByIdUrl(String id) => '$subscriptionsUrl/$id';
}

/// Logging levels following standard severity hierarchy
enum LogLevel {
  /// Detailed debug information
  debug(0),

  /// Informational messages
  info(1),

  /// Warning messages
  warning(2),

  /// Error messages
  error(3),

  /// Critical failures
  critical(4),

  /// Disable all logging
  none(99);

  final int severity;
  const LogLevel(this.severity);

  /// Parse log level from string
  static LogLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'debug':
        return LogLevel.debug;
      case 'info':
        return LogLevel.info;
      case 'warning':
      case 'warn':
        return LogLevel.warning;
      case 'error':
        return LogLevel.error;
      case 'critical':
      case 'fatal':
        return LogLevel.critical;
      case 'none':
      case 'off':
        return LogLevel.none;
      default:
        return LogLevel.warning; // Safe default
    }
  }

  bool shouldLog(LogLevel messageLevel) {
    return messageLevel.severity >= severity;
  }
}
