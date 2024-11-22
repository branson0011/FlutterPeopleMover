import 'package:shared_preferences.dart';
import 'dart:convert';
import '../models/venue_model.dart';

class CacheService {
  static const String venuesCacheKey = 'venues_cache';
  static const String preferencesCacheKey = 'preferences_cache';
  static const Duration cacheDuration = Duration(minutes: 15);
  
  final SharedPreferences prefs;
  
  CacheService(this.prefs);
  
  Future<void> cacheVenues(String key, List<Venue> venues) async {
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'venues': venues.map((v) => v.toMap()).toList(),
    };
    
    await prefs.setString('$venuesCacheKey:$key', jsonEncode(data));
  }
  
  Future<List<Venue>?> getCachedVenues(String key) async {
    final data = prefs.getString('$venuesCacheKey:$key');
    if (data == null) return null;
    
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    final timestamp = DateTime.parse(decoded['timestamp']);
    
    if (DateTime.now().difference(timestamp) > cacheDuration) {
      await prefs.remove('$venuesCacheKey:$key');
      return null;
    }
    
    final venues = (decoded['venues'] as List)
        .map((v) => Venue.fromMap(v as Map<String, dynamic>))
        .toList();
        
    return venues;
  }
  
  Future<void> cachePreferences(Map<String, dynamic> preferences) async {
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'preferences': preferences,
    };
    
    await prefs.setString(preferencesCacheKey, jsonEncode(data));
  }
  
  Future<Map<String, dynamic>?> getCachedPreferences() async {
    final data = prefs.getString(preferencesCacheKey);
    if (data == null) return null;
    
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    final timestamp = DateTime.parse(decoded['timestamp']);
    
    if (DateTime.now().difference(timestamp) > cacheDuration) {
      await prefs.remove(preferencesCacheKey);
      return null;
    }
    
    return decoded['preferences'] as Map<String, dynamic>;
  }
  
  Future<void> clearCache() async {
    final keys = prefs.getKeys().where((k) => 
        k.startsWith(venuesCacheKey) || k == preferencesCacheKey);
    
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
