import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class Logger {
  static LogLevel logLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static LogHandler logHandler = defaultLogHandler;

  /// Log event with [message] and [logLevel]
  static void logEvent(message, [LogLevel logLevel = LogLevel.debug]) {
    if ((Logger.logLevel != LogLevel.verbose && logLevel != Logger.logLevel)) {
      return;
    }
    logHandler(logLevel, message.toString());
  }

  static void defaultLogHandler(LogLevel logLevel, String message) {
    developer.log(message, name: 'PurchasesDart-${logLevel.name}');
  }
}
