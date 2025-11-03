import 'package:talker/talker.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class AppTalker {
  static late final Talker _instance;
  static bool _initialized = false;

  /// Initialize Talker with configuration
  static void initialize() {
    if (_initialized) return;

    _instance = Talker(
      settings: TalkerSettings(
        enabled: AppConfig.enableLogging || kDebugMode,
        useHistory: true,
        maxHistoryItems: 100,
        useConsoleLogs: true,
      ),
      logger: TalkerLogger(
        output: kIsWeb ? _webOutput : _mobileOutput,
        settings: TalkerLoggerSettings(
          enableColors: !kIsWeb,
          lineSymbol: kIsWeb ? '' : '│',
        ),
      ),
      observer: AppTalkerObserver(),
    );

    _initialized = true;
  }

  /// Get the Talker instance
  static Talker get instance {
    if (!_initialized) {
      throw StateError('AppTalker must be initialized before use. Call AppTalker.initialize() first.');
    }
    return _instance;
  }

  /// Create a scoped logger with a class name prefix
  static TalkerScope createLogger(String className) {
    return TalkerScope(
      talker: instance,
      title: className,
    );
  }

  // Custom output for web
  static void _webOutput(String message) {
    // ignore: avoid_print
    print(message);
  }

  // Custom output for mobile (default behavior)
  static void _mobileOutput(String message) {
    // ignore: avoid_print
    print(message);
  }

  // Sanitization helpers
  static String sanitize(String data, {bool isSensitive = false}) {
    if (!AppConfig.enableLogging || kReleaseMode) {
      return '[REDACTED]';
    }
    
    if (isSensitive) {
      if (data.length <= 10) return '[REDACTED]';
      return '${data.substring(0, 8)}...[${data.length} chars]';
    }
    
    return data;
  }

  static String sanitizeEmail(String email) {
    if (!AppConfig.enableLogging || kReleaseMode) {
      return '[EMAIL]';
    }
    
    final parts = email.split('@');
    if (parts.length == 2) {
      return '***@${parts[1]}';
    }
    return '[EMAIL]';
  }

  static String sanitizeToken(String? token) {
    if (token == null) return 'null';
    if (!AppConfig.enableLogging || kReleaseMode) {
      return '[TOKEN]';
    }
    
    if (token.length <= 20) return '[TOKEN]';
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }

  static String sanitizeResponse(String body) {
    if (!AppConfig.enableLogging || kReleaseMode) {
      return '[RESPONSE]';
    }
    
    if (body.length > 500) {
      return '${body.substring(0, 500)}... [${body.length} total chars]';
    }
    return body;
  }
}

/// Custom Talker Observer for monitoring logs
class AppTalkerObserver extends TalkerObserver {
  @override
  void onError(TalkerError err) {
    // In production, you could send errors to your error tracking service
    // e.g., Sentry, Firebase Crashlytics, etc.
    if (kReleaseMode) {
      // TODO: Send to error tracking service
    }
    super.onError(err);
  }

  @override
  void onException(TalkerException exception) {
    // In production, you could send exceptions to your error tracking service
    if (kReleaseMode) {
      // TODO: Send to error tracking service
    }
    super.onException(exception);
  }

  @override
  void onLog(TalkerData log) {
    // Filter logs in release mode
    if (kReleaseMode && (log.logLevel?.index ?? 0) < LogLevel.warning.index) {
      return;
    }
    super.onLog(log);
  }
}

/// Extension for TalkerScope to add scoped logging with class names
class TalkerScope {
  final Talker talker;
  final String title;

  TalkerScope({
    required this.talker,
    required this.title,
  });

  void debug(dynamic message) => _log(message, LogLevel.debug);
  void info(dynamic message) => _log(message, LogLevel.info);
  void warning(dynamic message) => _log(message, LogLevel.warning);
  void error(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (error != null) {
      talker.handle(error, stackTrace, '[$title] $message');
    } else {
      _log(message, LogLevel.error);
    }
  }

  void _log(dynamic message, LogLevel level) {
    final scopedMessage = '[$title] $message';
    switch (level) {
      case LogLevel.debug:
        talker.debug(scopedMessage);
        break;
      case LogLevel.info:
        talker.info(scopedMessage);
        break;
      case LogLevel.warning:
        talker.warning(scopedMessage);
        break;
      case LogLevel.error:
        talker.error(scopedMessage);
        break;
      default:
        talker.log(scopedMessage);
    }
  }
}