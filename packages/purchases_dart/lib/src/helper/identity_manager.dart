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

  String? get currentAppUserID => deviceCache.getCachedAppUserID();

  final RegExp anonymousIdRegex = RegExp(r'^\$RCAnonymousID:([a-f0-9]{32})$');

  void configure(String? appUserID) {
    if (appUserID?.trim().isEmpty == true) {
      Logger.logEvent(
          'EMPTY_APP_USER_ID_WILL_BECOME_ANONYMOUS', LogLevel.debug);
    }

    final appUserIDToUse = appUserID?.trim().isNotEmpty == true
        ? appUserID
        : deviceCache.getCachedAppUserID() ?? _generateRandomID();

    Logger.logEvent('IDENTIFYING_APP_USER_ID $appUserIDToUse', LogLevel.debug);

    deviceCache.setCachedAppUserID(appUserIDToUse);
  }

  Future<LogInResult> logIn(String newAppUserID) async {
    if (newAppUserID.trim().isEmpty) {
      throw const PurchasesDartError(
        code: PurchasesDartErrorCode.InvalidAppUserIdError,
      ).toPlatformException();
    }

    if (currentAppUserID == newAppUserID) {
      Logger.logEvent('LOG_IN_CALLED_WITH_SAME_APP_USER_ID', LogLevel.error);
      throw Exception('Log in called with the same appUserID');
    }

    Logger.logEvent('LOGGING_IN $currentAppUserID -> $newAppUserID');
    final oldAppUserID = currentAppUserID;

    LogInResult loginResult = await backend.logIn(
      oldAppUserID: oldAppUserID,
      newAppUserID: newAppUserID,
    );

    deviceCache.setCachedAppUserID(newAppUserID);

    return loginResult;
  }

  void switchUser(String newAppUserID) {
    Logger.logEvent('SWITCHING_USER $newAppUserID');
    _resetAndSaveUserID(newAppUserID);
  }

  Future<void> logOut() async {
    if (currentUserIsAnonymous()) {
      Logger.logEvent('LOG_OUT_CALLED_ON_ANONYMOUS_USER');
      throw const PurchasesDartError(
        code: PurchasesDartErrorCode.LogOutWithAnonymousUserError,
      ).toPlatformException();
    }
    _resetAndSaveUserID(_generateRandomID());
    Logger.logEvent('LOG_OUT_SUCCESSFUL');
  }

  bool currentUserIsAnonymous() {
    final currentAppUserIDLooksAnonymous =
        _isUserIDAnonymous(deviceCache.getCachedAppUserID() ?? '');
    return currentAppUserIDLooksAnonymous;
  }

  // Private functions
  bool _isUserIDAnonymous(String appUserID) {
    return anonymousIdRegex.hasMatch(appUserID);
  }

  String _generateRandomID() {
    var uuid = const Uuid().v4();
    var randomId = "\$RCAnonymousID:${uuid.replaceAll("-", "").toLowerCase()}";
    Logger.logEvent('Setting new anonymous ID: $randomId');
    return randomId;
  }

  void _resetAndSaveUserID(String newUserID) {
    deviceCache.setCachedAppUserID(newUserID);
  }
}
