import 'package:shared_preferences.dart';
import 'dart:convert';
import '../../models/crowd_level_data.dart';

class CrowdLevelCache {
  static const String _prefix = 'crowd_level_';
  static const Duration _defaultExpiration = Duration(minutes: 15);
  final SharedPreferences _prefs;

  CrowdLevelCache(this._prefs);

  Future<void> cacheCrowdLevel(
    String venueId, 
    CrowdLevelData data,
    {Duration? expiration}
  ) async {
    final key = _getCacheKey(venueId);
    final expirationTime = DateTime.now()
        .add(expiration ?? _defaultExpiration)
        .millisecondsSinceEpoch;
    
    final cacheData = {
      'data': data.toMap(),
      'expiration': expirationTime,
    };

    await _prefs.setString(key, json.encode(cacheData));
  }

  Future<CrowdLevelData?> getCachedCrowdLevel(String venueId) async {
    final key = _getCacheKey(venueId);
    final cachedData = _prefs.getString(key);
    
    if (cachedData == null) return null;

    final decoded = json.decode(cachedData) as Map<String, dynamic>;
    final expiration = DateTime.fromMillisecondsSinceEpoch(
      decoded['expiration'] as int
    );

    if (DateTime.now().isAfter(expiration)) {
      await _prefs.remove(key);
      return null;
    }

    return CrowdLevelData.fromMap(
      decoded['data'] as Map<String, dynamic>
    );
  }

  Future<void> invalidateCache(String venueId) async {
    await _prefs.remove(_getCacheKey(venueId));
  }

  Future<void> clearAllCache() async {
    final keys = _prefs.getKeys()
        .where((key) => key.startsWith(_prefix));
    
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  String _getCacheKey(String venueId) => '$_prefix$venueId';
}
