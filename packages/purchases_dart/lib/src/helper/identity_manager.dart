import 'package:purchases_dart/src/helper/cache_manager.dart';
import 'package:purchases_dart/src/helper/logger.dart';
import 'package:purchases_dart/src/helper/purchase_error_code.dart';
import 'package:purchases_dart/src/networking/purchases_backend.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:uuid/uuid.dart';

class IdentityManager {
  final CacheManager deviceCache;
  final PurchasesBackend backend;

  IdentityManager(this.deviceCache, this.backend);

  String? get currentAppUserId => deviceCache.getCachedAppUserId();

  final RegExp anonymousIdRegex = RegExp(r'^\$RCAnonymousID:([a-f0-9]{32})$');

  void configure(String? appUserId) {
    if (appUserId?.trim().isEmpty == true) {
      Logger.logEvent(
          'EMPTY_APP_USER_ID_WILL_BECOME_ANONYMOUS', LogLevel.debug);
    }

    final appUserIdToUse = appUserId?.trim().isNotEmpty == true
        ? appUserId
        : deviceCache.getCachedAppUserId() ?? _generateRandomId();

    Logger.logEvent('IDENTIFYING_APP_USER_ID $appUserIdToUse', LogLevel.debug);

    deviceCache.setCachedAppUserId(appUserIdToUse);
  }

  Future<LogInResult> logIn(String newAppUserId) async {
    if (newAppUserId.trim().isEmpty) {
      throw const PurchasesDartError(
        code: PurchasesDartErrorCode.InvalidAppUserIdError,
      ).toPlatformException();
    }

    if (currentAppUserId == newAppUserId) {
      Logger.logEvent('LOG_IN_CALLED_WITH_SAME_APP_USER_ID', LogLevel.error);
      throw Exception('Log in called with the same appUserID');
    }

    Logger.logEvent('LOGGING_IN $currentAppUserId -> $newAppUserId');
    final oldAppUserId = currentAppUserId;

    LogInResult loginResult = await backend.logIn(
      oldAppUserId: oldAppUserId,
      newAppUserId: newAppUserId,
    );

    deviceCache.setCachedAppUserId(newAppUserId);

    return loginResult;
  }

  void switchUser(String newAppUserId) {
    Logger.logEvent('SWITCHING_USER $newAppUserId');
    _resetAndSaveUserId(newAppUserId);
  }

  Future<void> logOut() async {
    if (currentUserIsAnonymous()) {
      Logger.logEvent('LOG_OUT_CALLED_ON_ANONYMOUS_USER');
      throw const PurchasesDartError(
        code: PurchasesDartErrorCode.LogOutWithAnonymousUserError,
      ).toPlatformException();
    }
    _resetAndSaveUserId(_generateRandomId());
    Logger.logEvent('LOG_OUT_SUCCESSFUL');
  }

  bool currentUserIsAnonymous() {
    final currentAppUserIdLooksAnonymous =
        _isUserIdAnonymous(deviceCache.getCachedAppUserId() ?? '');
    return currentAppUserIdLooksAnonymous;
  }

  // Private functions
  bool _isUserIdAnonymous(String appUserId) {
    return anonymousIdRegex.hasMatch(appUserId);
  }

  String _generateRandomId() {
    var uuid = const Uuid().v4();
    var randomId = "\$RCAnonymousID:${uuid.replaceAll("-", "").toLowerCase()}";
    Logger.logEvent('Setting new anonymous ID: $randomId');
    return randomId;
  }

  void _resetAndSaveUserId(String newUserId) {
    deviceCache.setCachedAppUserId(newUserId);
  }
}
