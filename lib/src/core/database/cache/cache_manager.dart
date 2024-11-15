import 'dart:collection';
import 'dart:convert';
import 'package:collection/collection.dart';
import '../models/cache_entry.dart';
import 'package:shared_preferences.dart';

class CacheManager<T> {
  final int maxSize;
  final Duration maxAge;
  final bool persistToDisk;
  final String? cacheKey;
  final LinkedHashMap<String, _CacheEntry<T>> _cache;
  final SharedPreferences? _prefs;

  CacheManager({
    this.maxSize = 100,
    this.maxAge = const Duration(minutes: 30),
    this.persistToDisk = false,
    this.cacheKey,
    SharedPreferences? prefs,
  }) : _cache = LinkedHashMap(),
       _prefs = prefs {
    if (persistToDisk && cacheKey != null) {
      _loadFromDisk();
    }
  }

  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (DateTime.now().difference(entry.timestamp) > maxAge) {
      _cache.remove(key);
      return null;
    }

    // Move to end (most recently used)
    _cache.remove(key);
    _cache[key] = entry;
    return entry.value;
  }

  void set(String key, T value) {
    if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = _CacheEntry(value);
    _persistToDisk();
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  List<T> getAll() {
    final now = DateTime.now();
    _cache.removeWhere(
      (_, entry) => now.difference(entry.timestamp) > maxAge
    );
    return _cache.values.map((e) => e.value).toList();
  }

  List<T> where(bool Function(T) test) {
    return getAll().where(test).toList();
  }

  T? firstWhere(bool Function(T) test, {T? Function()? orElse}) {
    return getAll().firstWhereOrNull(test);
  }

  Future<void> _loadFromDisk() async {
    if (_prefs == null || cacheKey == null) return;
    
    final data = _prefs!.getString(cacheKey!);
    if (data != null) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        _cache[key] = _CacheEntry<T>(
          value as T,
          DateTime.fromMillisecondsSinceEpoch(
            decoded['${key}_timestamp'] as int,
          ),
        );
      });
    }
  }

  Future<void> _persistToDisk() async {
    if (!persistToDisk || _prefs == null || cacheKey == null) return;
    
    final data = <String, dynamic>{};
    _cache.forEach((key, entry) {
      data[key] = entry.value;
      data['${key}_timestamp'] = entry.timestamp.millisecondsSinceEpoch;
    });
    
    await _prefs!.setString(cacheKey!, jsonEncode(data));
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime timestamp;

  _CacheEntry(this.value) : timestamp = DateTime.now();
}
