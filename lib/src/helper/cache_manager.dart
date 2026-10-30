import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  final SharedPreferences _storage;
  CacheManager._(this._storage);

  static CacheManager? _instance;

  static Future<CacheManager> get instance async {
    if (_instance != null) return _instance!;
    final storage = await SharedPreferences.getInstance();
    _instance = CacheManager._(storage);
    return _instance!;
  }

  final _appUserIdKey = 'appUserID';

  String? getCachedAppUserId() => _storage.getString(_appUserIdKey);

  Future<void> setCachedAppUserId(String? value) async => value == null
      ? await _storage.remove(_appUserIdKey)
      : await _storage.setString(_appUserIdKey, value);

  VirtualCurrenciesCache virtualCurrencies(String userId) =>
      VirtualCurrenciesCache(_storage, userId);
}

class VirtualCurrenciesCache {
  const VirtualCurrenciesCache(this._storage, this.userId);

  final SharedPreferences _storage;
  final String userId;

  String get _key => 'virtualCurrencies_$userId';

  Future<bool> invalidate() => _storage.remove(_key);

  Map<String, dynamic>? getCached() {
    final value = _storage.getString(_key);
    return value == null ? null : jsonDecode(value) as Map<String, dynamic>;
  }

  Future<bool> setCached(Map<String, dynamic> data) {
    return _storage.setString(_key, jsonEncode(data));
  }
}
