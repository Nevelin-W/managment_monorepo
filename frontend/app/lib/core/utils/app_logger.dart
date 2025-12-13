import 'package:talker/talker.dart' as talker_lib;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Application-wide logging utility
/// Provides structured logging with configurable levels and data sanitization
class AppLogger {
  static late final talker_lib.Talker _instance;
  static bool _initialized = false;

  /// Initialize the logger with configuration
  static void initialize() {
    if (_initialized) return;

    _instance = talker_lib.Talker(
      settings: talker_lib.TalkerSettings(
        enabled: _shouldEnableLogging(),
        useHistory: true,
        maxHistoryItems: 1000,
        useConsoleLogs: true,
      ),
      logger: talker_lib.TalkerLogger(
        output: kIsWeb ? _webOutput : _mobileOutput,
        settings: talker_lib.TalkerLoggerSettings(
          enableColors: !kIsWeb,
          lineSymbol: kIsWeb ? '' : '│',
        ),
      ),
      observer: AppLoggerObserver(),
    );

    _initialized = true;
    
    // Log initialization
    if (_shouldEnableLogging()) {
      _instance.info('Logger initialized with level: ${AppConfig.logLevel.name}');
    }
  }

  /// Determine if logging should be enabled based on config and build mode
  static bool _shouldEnableLogging() {
    // Always enable in debug mode
    if (kDebugMode) return true;
    
    // In profile/release, respect the log level configuration
    return AppConfig.logLevel != LogLevel.none;
  }

  /// Get the Talker instance
  static talker_lib.Talker get instance {
    if (!_initialized) {
      throw StateError(
        'AppLogger must be initialized before use. '
        'Call AppLogger.initialize() first.'
      );
    }
    return _instance;
  }

  /// Create a scoped logger for a specific class/module
  static LoggerScope scope(String name) {
    return LoggerScope(
      talker: instance,
      name: name,
      minLevel: AppConfig.logLevel,
    );
  }

  // Platform-specific output handlers
  static void _webOutput(String message) {
    // ignore: avoid_print
    print(message);
  }

  static void _mobileOutput(String message) {
    // ignore: avoid_print
    print(message);
  }
}

/// Custom observer for log monitoring and filtering
class AppLoggerObserver extends talker_lib.TalkerObserver {
  @override
  void onError(talker_lib.TalkerError err) {
    if (_shouldProcess(LogLevel.error)) {
      // In production, send to error tracking service
      if (kReleaseMode) {
        _sendToErrorTracking(err);
      }
    }
    super.onError(err);
  }

  @override
  void onException(talker_lib.TalkerException err) {
    if (_shouldProcess(LogLevel.error)) {
      if (kReleaseMode) {
        _sendToErrorTracking(err);
      }
    }
    super.onException(err);
  }

  @override
  void onLog(talker_lib.TalkerData log) {
    // Convert Talker's log level to our LogLevel
    final logLevel = _mapTalkerLogLevel(log);
    
    if (!_shouldProcess(logLevel)) {
      return; // Filter out logs below threshold
    }
    
    super.onLog(log);
  }

  bool _shouldProcess(LogLevel level) {
    return AppConfig.logLevel.shouldLog(level);
  }

  LogLevel _mapTalkerLogLevel(talker_lib.TalkerData log) {
    if (log is talker_lib.TalkerError || log is talker_lib.TalkerException) {
      return LogLevel.error;
    }
    
    final talkerLevel = log.logLevel;
    if (talkerLevel == null) return LogLevel.info;
    
    // Map Talker's LogLevel to our LogLevel
    if (talkerLevel == talker_lib.LogLevel.debug) return LogLevel.debug;
    if (talkerLevel == talker_lib.LogLevel.info) return LogLevel.info;
    if (talkerLevel == talker_lib.LogLevel.warning) return LogLevel.warning;
    if (talkerLevel == talker_lib.LogLevel.error) return LogLevel.error;
    if (talkerLevel == talker_lib.LogLevel.critical) return LogLevel.critical;
    
    return LogLevel.info;
  }

  void _sendToErrorTracking(dynamic error) {
    // TODO: Implement error tracking integration
    // Example: Sentry.captureException(error);
  }
}

/// Scoped logger for class-level logging with automatic filtering
class LoggerScope {
  final talker_lib.Talker talker;
  final String name;
  final LogLevel minLevel;

  LoggerScope({
    required this.talker,
    required this.name,
    required this.minLevel,
  });

  /// Log debug message
  void debug(String message, [Map<String, dynamic>? context]) {
    if (minLevel.shouldLog(LogLevel.debug)) {
      _log(message, LogLevel.debug, context);
    }
  }

  /// Log info message
  void info(String message, [Map<String, dynamic>? context]) {
    if (minLevel.shouldLog(LogLevel.info)) {
      _log(message, LogLevel.info, context);
    }
  }

  /// Log warning message
  void warning(String message, [Map<String, dynamic>? context]) {
    if (minLevel.shouldLog(LogLevel.warning)) {
      _log(message, LogLevel.warning, context);
    }
  }

  /// Log error message with optional exception and stack trace
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (!minLevel.shouldLog(LogLevel.error)) return;

    if (error != null) {
      talker.handle(
        error,
        stackTrace,
        _formatMessage(message, context),
      );
    } else {
      _log(message, LogLevel.error, context);
    }
  }

  /// Log critical message
  void critical(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (!minLevel.shouldLog(LogLevel.critical)) return;

    if (error != null) {
      talker.handle(
        error,
        stackTrace,
        _formatMessage(message, context),
      );
    } else {
      _log(message, LogLevel.critical, context);
    }
  }

  void _log(String message, LogLevel level, Map<String, dynamic>? context) {
    final formattedMessage = _formatMessage(message, context);
    
    switch (level) {
      case LogLevel.debug:
        talker.debug(formattedMessage);
        break;
      case LogLevel.info:
        talker.info(formattedMessage);
        break;
      case LogLevel.warning:
        talker.warning(formattedMessage);
        break;
      case LogLevel.error:
        talker.error(formattedMessage);
        break;
      case LogLevel.critical:
        talker.critical(formattedMessage);
        break;
      case LogLevel.none:
        break;
    }
  }

  String _formatMessage(String message, Map<String, dynamic>? context) {
    final buffer = StringBuffer('[$name] $message');
    
    if (context != null && context.isNotEmpty) {
      buffer.write(' | ');
      buffer.write(context.entries.map((e) => '${e.key}=${e.value}').join(', '));
    }
    
    return buffer.toString();
  }
}

/// Data sanitization utilities for logging
class LogSanitizer {
  /// Sanitize general data based on sensitivity
  static String sanitize(
    String data, {
    bool isSensitive = false,
    int maxLength = 500,
  }) {
    if (kReleaseMode && isSensitive) {
      return '[REDACTED]';
    }
    
    if (isSensitive && data.length > 10) {
      return '${data.substring(0, 8)}...[${data.length} chars]';
    }
    
    if (data.length > maxLength) {
      return '${data.substring(0, maxLength)}... [${data.length} total chars]';
    }
    
    return data;
  }

  /// Sanitize email addresses
  static String email(String email) {
    if (kReleaseMode) {
      return '[EMAIL]';
    }
    
    final parts = email.split('@');
    if (parts.length == 2 && parts[0].isNotEmpty) {
      final localPart = parts[0];
      final maskedLocal = localPart.length > 2
          ? '${localPart[0]}***${localPart[localPart.length - 1]}'
          : '***';
      return '$maskedLocal@${parts[1]}';
    }
    return '[EMAIL]';
  }

  /// Sanitize authentication tokens
  static String token(String? token) {
    if (token == null || token.isEmpty) return 'null';
    if (kReleaseMode) return '[TOKEN]';
    
    if (token.length <= 20) return '[TOKEN:short]';
    return '${token.substring(0, 6)}...${token.substring(token.length - 6)} [${token.length} chars]';
  }

  /// Sanitize API responses
  static String response(String body, {int maxLength = 500}) {
    if (kReleaseMode) return '[RESPONSE]';
    return sanitize(body, maxLength: maxLength);
  }

  /// Sanitize passwords (always redacted)
  static String password() => '[REDACTED]';

  /// Sanitize credit card numbers
  static String creditCard(String? card) {
    if (card == null || card.isEmpty) return 'null';
    if (kReleaseMode) return '[CARD]';
    
    final digitsOnly = card.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= 4) {
      return '****${digitsOnly.substring(digitsOnly.length - 4)}';
    }
    return '[CARD]';
  }

  /// Sanitize phone numbers
  static String phone(String? phone) {
    if (phone == null || phone.isEmpty) return 'null';
    if (kReleaseMode) return '[PHONE]';
    
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= 4) {
      return '***${digitsOnly.substring(digitsOnly.length - 4)}';
    }
    return '[PHONE]';
  }

  /// Sanitize structured data (JSON-like objects)
  static Map<String, dynamic> sanitizeMap(
    Map<String, dynamic> data,
    List<String> sensitiveKeys,
  ) {
    if (kReleaseMode) {
      return {'_sanitized': true};
    }

    final sanitized = Map<String, dynamic>.from(data);
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '[REDACTED]';
      }
    }
    return sanitized;
  }
}