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

  String? getCachedAppUserID() => _storage.getString(_appUserIdKey);

  Future<void> setCachedAppUserID(String? value) async => value == null
      ? await _storage.remove(_appUserIdKey)
      : await _storage.setString(_appUserIdKey, value);
}
