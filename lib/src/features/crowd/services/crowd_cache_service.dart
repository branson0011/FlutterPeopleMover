import 'package:shared_preferences.dart';
import 'dart:convert';
import '../models/crowd_level_standard.dart';

class CrowdCacheService {
  static const String _crowdLevelKey = 'crowd_level_cache';
  static const Duration _cacheDuration = Duration(minutes: 15);
  final SharedPreferences _prefs;

  CrowdCacheService(this._prefs);

  Future<void> cacheCrowdLevel(String locationId, Map<String, dynamic> data) async {
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(
      _getCacheKey(locationId),
      json.encode(cacheEntry),
    );
  }

  Future<Map<String, dynamic>?> getCachedCrowdLevel(String locationId) async {
    final cachedData = _prefs.getString(_getCacheKey(locationId));
    if (cachedData == null) return null;

    final cacheEntry = json.decode(cachedData);
    final timestamp = DateTime.parse(cacheEntry['timestamp']);
    
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      await _prefs.remove(_getCacheKey(locationId));
      return null;
    }

    return cacheEntry['data'];
  }

  Future<void> invalidateCache(String locationId) async {
    await _prefs.remove(_getCacheKey(locationId));
  }

  String _getCacheKey(String locationId) => '${_crowdLevelKey}_$locationId';
}
