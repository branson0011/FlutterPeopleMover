import 'dart:collection';
import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/cache_entry.dart';

class CacheManager<T> {
  final int maxSize;
  final Duration maxAge;
  final bool persistToDisk;
  final String? cacheKey;
  final LinkedHashMap<String, CacheEntry<T>> _cache;
  final SharedPreferences? _prefs;
  final T Function(Map<String, dynamic>)? fromJson;
  final Map<String, dynamic> Function(T)? toJson;
  final Map<String, int> _hitCount = {};
  final Map<String, int> _missCount = {};

  CacheManager({
    this.maxSize = 100,
    this.maxAge = const Duration(minutes: 30),
    this.persistToDisk = false,
    this.cacheKey,
    SharedPreferences? prefs,
    this.fromJson,
    this.toJson,
  })  : _cache = LinkedHashMap(),
        _prefs = prefs {
    if (persistToDisk && prefs != null) {
      _loadFromDisk();
    }
  }

  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) {
      _missCount[key] = (_missCount[key] ?? 0) + 1;
      return null;
    }

    if (entry.isExpired(maxAge)) {
      _cache.remove(key);
      _missCount[key] = (_missCount[key] ?? 0) + 1;
      _persistToDisk();
      return null;
    }

    _hitCount[key] = (_hitCount[key] ?? 0) + 1;
    // Move to end (most recently used)
    _cache.remove(key);
    _cache[key] = entry;
    return entry.value;
  }

  void set(String key, T value, {String? metadata}) {
    if (_cache.length >= maxSize) {
      _evictLeastUsed();
    }

    _cache[key] = CacheEntry<T>(
      value,
      metadata: metadata,
    );
    _persistToDisk();
  }

  void _evictLeastUsed() {
    if (_cache.isEmpty) return;
    
    // Find entry with lowest hit count
    var leastUsedKey = _cache.keys.reduce((a, b) {
      final aCount = _hitCount[a] ?? 0;
      final bCount = _hitCount[b] ?? 0;
      return aCount < bCount ? a : b;
    });

    _cache.remove(leastUsedKey);
    _hitCount.remove(leastUsedKey);
    _missCount.remove(leastUsedKey);
  }

  Future<void> _loadFromDisk() async {
    if (_prefs == null || cacheKey == null) return;
    
    try {
      final data = _prefs!.getString(cacheKey!);
      if (data != null) {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        
        for (var entry in decoded.entries) {
          if (fromJson != null) {
            final value = fromJson!(entry.value['value']);
            _cache[entry.key] = CacheEntry<T>(
              value,
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                entry.value['timestamp'],
              ),
              metadata: entry.value['metadata'],
            );
          }
        }
      }
    } catch (e) {
      print('Error loading cache from disk: $e');
    }
  }

  Future<void> _persistToDisk() async {
    if (!persistToDisk || _prefs == null || cacheKey == null) return;
    
    try {
      final data = <String, dynamic>{};
      _cache.forEach((key, entry) {
        data[key] = {
          'value': toJson != null ? toJson!(entry.value) : entry.value,
          'timestamp': entry.timestamp.millisecondsSinceEpoch,
          'metadata': entry.metadata,
        };
      });
      
      await _prefs!.setString(cacheKey!, jsonEncode(data));
    } catch (e) {
      print('Error persisting cache to disk: $e');
    }
  }

  void remove(String key) {
    _cache.remove(key);
    _hitCount.remove(key);
    _missCount.remove(key);
    _persistToDisk();
  }

  void clear() {
    _cache.clear();
    _hitCount.clear();
    _missCount.clear();
    _persistToDisk();
  }

  Map<String, double> getHitRatios() {
    final ratios = <String, double>{};
    final keys = {..._hitCount.keys, ..._missCount.keys};
    
    for (final key in keys) {
      final hits = _hitCount[key] ?? 0;
      final misses = _missCount[key] ?? 0;
      final total = hits + misses;
      ratios[key] = total > 0 ? hits / total : 0.0;
    }
    
    return ratios;
  }

  int get size => _cache.length;
  bool get isEmpty => _cache.isEmpty;
  bool get isNotEmpty => _cache.isNotEmpty;
  Iterable<String> get keys => _cache.keys;
  Iterable<T> get values => _cache.values.map((e) => e.value);
}
