import 'package:flutter/foundation.dart';

/// Log levels for application logging
enum LogLevel { debug, info, warning, error }

/// Professional logging utility with colored output
class Logger {
  Logger._();

  static bool _enableLogging = kDebugMode;
  static LogLevel _minLevel = LogLevel.debug;

  /// Enable or disable logging
  static void setLogging(bool enabled) {
    _enableLogging = enabled;
  }

  /// Set minimum log level
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Log debug message
  static void debug(String message, [String? tag]) {
    _log(LogLevel.debug, message, tag);
  }

  /// Log info message
  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }

  /// Log warning message
  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }

  /// Log error message
  static void error(
    String message, [
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.error, message, tag);
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Internal log method
  static void _log(LogLevel level, String message, [String? tag]) {
    if (!_enableLogging || level.index < _minLevel.index) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = _getLevelString(level);
    final tagStr = tag != null ? '[$tag]' : '';
    final logMessage = '$timestamp $levelStr $tagStr $message';

    // Use debugPrint for Flutter
    debugPrint(logMessage);
  }

  /// Get level string with emoji
  static String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 DEBUG';
      case LogLevel.info:
        return 'ℹ️  INFO';
      case LogLevel.warning:
        return '⚠️  WARNING';
      case LogLevel.error:
        return '❌ ERROR';
    }
  }

  /// Log Modbus communication
  static void modbus(String message, {bool isSent = true}) {
    final direction = isSent ? '📤 SENT' : '📥 RECEIVED';
    info('$direction: $message', 'MODBUS');
  }

  /// Log serial port events
  static void serial(String message) {
    info(message, 'SERIAL');
  }

  /// Log UI events
  static void ui(String message) {
    debug(message, 'UI');
  }
}
