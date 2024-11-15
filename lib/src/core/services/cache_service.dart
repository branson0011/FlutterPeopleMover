import 'package:shared_preferences.dart';
import '../cache/cache_manager.dart';

class CacheService {
  final SharedPreferences _preferences;
  final Map<String, CacheManager> _caches = {};
  final Duration defaultMaximumAge;
  final int defaultMaximumSize;

  CacheService(
    this._preferences, {
    this.defaultMaximumAge = const Duration(minutes: 30),
    this.defaultMaximumSize = 100,
  });

  CacheManager<T> getCache<T>({
    required String name,
    Duration? maximumAge,
    int? maximumSize,
    bool persistToDisk = false,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic> Function(T)? toJson,
  }) {
    if (!_caches.containsKey(name)) {
      _caches[name] = CacheManager<T>(
        maximumAge: maximumAge ?? defaultMaximumAge,
        maximumSize: maximumSize ?? defaultMaximumSize,
        persistToDisk: persistToDisk,
        cacheKey: persistToDisk ? 'cache_$name' : null,
        preferences: persistToDisk ? _preferences : null,
        fromJson: fromJson,
        toJson: toJson,
      );
    }
    return _caches[name] as CacheManager<T>;
  }

  void clearCache(String name) {
    _caches[name]?.clear();
  }

  void clearAllCaches() {
    _caches.values.forEach((cache) => cache.clear());
  }

  Map<String, Map<String, double>> getAllCacheMetrics() {
    final metrics = <String, Map<String, double>>{};
    _caches.forEach((name, cache) {
      metrics[name] = cache.getHitRatios();
    });
    return metrics;
  }

  void removeCacheManager(String name) {
    _caches.remove(name);
  }

  bool hasCacheManager(String name) => _caches.containsKey(name);
}
