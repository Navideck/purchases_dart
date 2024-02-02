import 'dart:developer' as developer;

bool showLogs = true;
String _errorColor = '\x1B[31m';
String _successColor = '\x1B[32m';
String _warningColor = '\x1B[33m';
String _infoColor = '\x1B[34m';

// Blue text
void logInfo(dynamic msg, [String? tag]) {
  if (!showLogs) return;
  developer.log(
    '$_infoColor${tag != null ? "$tag: " : ""}$msg$_infoColor',
    name: 'PurchasesDart',
  );
}

// Green text
void logSuccess(msg) {
  if (!showLogs) return;
  developer.log('$_successColor$msg$_successColor', name: 'PurchasesDart');
}

// Yellow text
void logWarning(msg) {
  if (!showLogs) return;
  developer.log('$_warningColor$msg$_warningColor', name: 'PurchasesDart');
}

// Red text
void logError(dynamic msg, [String? tag]) {
  if (!showLogs) return;
  developer.log(
    '$_errorColor${tag != null ? "$tag: " : ""}$msg$_errorColor',
    name: 'PurchasesDart',
  );
}
