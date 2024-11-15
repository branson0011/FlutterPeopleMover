import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences.dart';
import 'cache_config.dart';
import '../models/cache_entry.dart';

abstract class CacheStore<T> {
  Future<void> set(String key, CacheEntry<T> entry);
  Future<CacheEntry<T>?> get(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<int> size();
}

class MemoryCacheStore<T> implements CacheStore<T> {
  final Map<String, CacheEntry<T>> _cache = {};

  @override
  Future<void> set(String key, CacheEntry<T> entry) async {
    _cache[key] = entry;
  }

  @override
  Future<CacheEntry<T>?> get(String key) async {
    return _cache[key];
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }

  @override
  Future<int> size() async {
    return _cache.length;
  }
}

class DiskCacheStore<T> implements CacheStore<T> {
  final SharedPreferences _preferences;
  final String prefix;
  final T Function(Map<String, dynamic>)? fromJson;
  final Map<String, dynamic> Function(T)? toJson;

  DiskCacheStore(
    this._preferences, {
    required this.prefix,
    this.fromJson,
    this.toJson,
  });

  @override
  Future<void> set(String key, CacheEntry<T> entry) async {
    final data = {
      'value': toJson != null ? toJson!(entry.value) : entry.value,
      'timestamp': entry.timestamp.millisecondsSinceEpoch,
      'metadata': entry.metadata,
    };
    await _preferences.setString('$prefix$key', jsonEncode(data));
  }

  @override
  Future<CacheEntry<T>?> get(String key) async {
    final data = _preferences.getString('$prefix$key');
    if (data == null) return null;

    final decoded = jsonDecode(data);
    final value = fromJson != null
        ? fromJson!(decoded['value'])
        : decoded['value'] as T;

    return CacheEntry<T>(
      value,
      timestamp: DateTime.fromMillisecondsSinceEpoch(decoded['timestamp']),
      metadata: decoded['metadata'],
    );
  }

  @override
  Future<void> remove(String key) async {
    await _preferences.remove('$prefix$key');
  }

  @override
  Future<void> clear() async {
    final keys = _preferences.getKeys().where((key) => key.startsWith(prefix));
    for (final key in keys) {
      await _preferences.remove(key);
    }
  }

  @override
  Future<int> size() async {
    return _preferences.getKeys().where((key) => key.startsWith(prefix)).length;
  }
}
