import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class AppLogger {
  static Logger createLogger(String className) {
    return Logger(
      filter: _CustomLogFilter(),
      printer: kIsWeb ? _WebPrettyPrinter(className) : _MobilePrettyPrinter(className),
      output: kIsWeb ? _WebConsoleOutput() : null,
    );
  }

  // Sanitize sensitive data from logs
  static String sanitize(String data, {bool isSensitive = false}) {
    if (!AppConfig.enableLogging || kReleaseMode) {
      return '[REDACTED]';
    }
    
    if (isSensitive) {
      // In debug mode, show partial data for debugging
      if (data.length <= 10) return '[REDACTED]';
      return '${data.substring(0, 8)}...[${data.length} chars]';
    }
    
    return data;
  }

  // Sanitize email addresses
  static String sanitizeEmail(String email) {
    if (!AppConfig.enableLogging || kReleaseMode) {
      return '[EMAIL]';
    }
    
    // Show only domain in debug mode
    final parts = email.split('@');
    if (parts.length == 2) {
      return '***@${parts[1]}';
    }
    return '[EMAIL]';
  }

  // Sanitize tokens
  static String sanitizeToken(String? token) {
    if (token == null) return 'null';
    if (!AppConfig.enableLogging || kReleaseMode) {
      return '[TOKEN]';
    }
    
    // In debug mode, show first and last 4 chars
    if (token.length <= 20) return '[TOKEN]';
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }

  // Sanitize response bodies that might contain sensitive data
  static String sanitizeResponse(String body) {
    if (!AppConfig.enableLogging || kReleaseMode) {
      return '[RESPONSE]';
    }
    
    // Truncate long responses
    if (body.length > 500) {
      return '${body.substring(0, 500)}... [${body.length} total chars]';
    }
    return body;
  }
}

class _CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // In release mode, only log warnings and errors
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    
    // In debug mode, respect the enableLogging flag
    return AppConfig.enableLogging;
  }
}

class _WebPrettyPrinter extends LogPrinter {
  final String className;
  
  _WebPrettyPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    final level = event.level.name.toUpperCase().padRight(7);
    final message = event.message;
    final time = DateTime.now().toIso8601String().split('T')[1].substring(0, 12);

    final buffer = StringBuffer();
    buffer.write('[$time] [$level] [$className] $message');

    if (event.error != null) {
      buffer.write('\n   Error: ${event.error}');
    }

    if (event.stackTrace != null && event.level.index >= Level.error.index) {
      final stackLines = event.stackTrace.toString().split('\n').take(5);
      buffer.write('\n   Stack: ${stackLines.join('\n          ')}');
    }

    return [buffer.toString()];
  }
}

class _MobilePrettyPrinter extends PrettyPrinter {
  final String className;

  _MobilePrettyPrinter(this.className)
      : super(
          methodCount: 0,
          errorMethodCount: 3,
          lineLength: 80,
          colors: true,
          printEmojis: false,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        );

  @override
  List<String> log(LogEvent event) {
    final original = super.log(event);
    return original.map((line) => '[$className] $line').toList();
  }
}

class _WebConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      // ignore: avoid_print
      print(line);
    }
  }
}