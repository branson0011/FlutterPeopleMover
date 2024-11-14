import 'dart:collection';
import 'package:collection/collection.dart';

class CacheManager<T> {
  final int maximumSize;
  final Duration maximumAge;
  final LinkedHashMap<String, _CacheEntry<T>> _cache;

  CacheManager({
    this.maximumSize = 100,
    this.maximumAge = const Duration(minutes: 30),
  }) : _cache = LinkedHashMap();

  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (DateTime.now().difference(entry.timestamp) > maximumAge) {
      _cache.remove(key);
      return null;
    }

    // Move to end (most recently used)
    _cache.remove(key);
    _cache[key] = entry;
    return entry.value;
  }

  void set(String key, T value) {
    if (_cache.length >= maximumSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = _CacheEntry(value);
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
      (_, entry) => now.difference(entry.timestamp) > maximumAge
    );
    return _cache.values.map((e) => e.value).toList();
  }

  List<T> where(bool Function(T) test) {
    return getAll().where(test).toList();
  }

  T? firstWhere(bool Function(T) test, {T? Function()? orElse}) {
    return getAll().firstWhereOrNull(test);
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime timestamp;

  _CacheEntry(this.value) : timestamp = DateTime.now();
}
