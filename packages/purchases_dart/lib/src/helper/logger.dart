import 'dart:developer' as developer;

import 'package:purchases_flutter/purchases_flutter.dart';

class Logger {
  static LogLevel? logLevel;
  static LogHandler logHandler = defaultLogHandler;

  /// Log event with [message] and [logLevel]
  static void logEvent(message, [LogLevel logLevel = LogLevel.debug]) {
    if (Logger.logLevel == null ||
        (Logger.logLevel != LogLevel.verbose && logLevel != Logger.logLevel)) {
      return;
    }
    logHandler(logLevel, message.toString());
  }

  static void defaultLogHandler(LogLevel logLevel, String message) {
    developer.log(message, name: 'PurchasesDart-${logLevel.name}');
  }
}
