import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/crowd_level_data.dart';
import 'cache/crowd_level_cache.dart';
import 'analytics/crowd_analytics_service.dart';

class CrowdLevelService {
  final BestTimeApiClient _bestTimeApi;
  final FoursquareApiClient _foursquareApi;
  final CrowdLevelCache _cache;
  final CrowdAnalyticsService _analytics;

  CrowdLevelService({
    required BestTimeApiClient bestTimeApi,
    required FoursquareApiClient foursquareApi,
    required CrowdLevelCache cache,
    required CrowdAnalyticsService analytics,
  }) : _bestTimeApi = bestTimeApi,
       _foursquareApi = foursquareApi,
       _cache = cache,
       _analytics = analytics;

  Future<CrowdLevelData> getVenueCrowdLevel(String venueId) async {
    // Check cache first
    final cachedData = await _cache.getCachedCrowdLevel(venueId);
    if (cachedData != null) {
      return cachedData;
    }

    // Fetch fresh data if not cached
    try {
      final bestTimeData = await _bestTimeApi.getLiveData(venueId);
      final foursquareData = await _foursquareApi.getVenueDetails(venueId);
      
      // Combine and normalize the data
      final combinedData = _combineCrowdLevelData(
        bestTimeData, 
        foursquareData
      );
      
      // Cache the result
      await _cache.cacheCrowdLevel(venueId, combinedData);
      
      // Track analytics
      await _analytics.trackCrowdLevel(
        venueId: venueId, actualData: combinedData);
 
      return combinedData;
    } catch (e) {
      print('Error getting crowd level: $e');
      // Return moderate confidence default if APIs fail
      return CrowdLevelData(
        level: 3,
        confidence: 0.5,
        timestamp: DateTime.now(),
        source: 'default',
      );
    }
  }

  Future<Map<String, dynamic>> _getGooglePlacesData(String placeId) async {
    final url = Uri.parse(
      '$_googlePlacesBaseUrl/details/json'
      '?place_id=$placeId'
      '&fields=current_popularity,popular_times'
      '&key=$_googleMapsApiKey'
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to get Google Places data');
  }

  Future<Map<String, dynamic>> _getFoursquareData(String venueId) async {
    final url = Uri.parse('$_foursquareBaseUrl/places/$venueId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': _foursquareApiKey,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to get Foursquare data');
  }

  CrowdLevelData _calculateCombinedCrowdLevel(
    Map<String, dynamic> googleData,
    Map<String, dynamic> foursquareData,
  ) {
    final googleScore = _normalizeGoogleScore(googleData);
    final foursquareScore = _normalizeFoursquareScore(foursquareData);
    
    // Weight the scores (Google data is typically more real-time)
    final combinedScore = (googleScore * 0.7) + (foursquareScore * 0.3);
    
    // Calculate confidence based on data freshness and consistency
    final confidence = _calculateConfidence(googleData, foursquareData);
    
    return CrowdLevelData(
      level: combinedScore.round(),
      confidence: confidence,
      timestamp: DateTime.now(),
      source: 'combined',
      metadata: {
        'google_score': googleScore,
        'foursquare_score': foursquareScore,
      },
    );
  }

  double _normalizeGoogleScore(Map<String, dynamic> data) {
    final currentPopularity = data['current_popularity'] as int?;
    if (currentPopularity == null) return 3.0;
    
    // Google popularity is typically 0-100, normalize to 1-5
    return (currentPopularity / 20) + 1;
  }

  double _normalizeFoursquareScore(Map<String, dynamic> data) {
    final popularity = data['popularity'] as double?;
    if (popularity == null) return 3.0;
    
    // Foursquare popularity is typically 0-10, normalize to 1-5
    return ((popularity * 0.4) + 1).clamp(1.0, 5.0);
  }

  double _calculateConfidence(
    Map<String, dynamic> googleData,
    Map<String, dynamic> foursquareData,
  ) {
    double confidence = 0.8; // Base confidence
    
    // Adjust based on data freshness
    final googleTimestamp = googleData['timestamp'] as String?;
    if (googleTimestamp != null) {
      final age = DateTime.now().difference(DateTime.parse(googleTimestamp));
      if (age.inMinutes < 15) {
        confidence += 0.1;
      } else if (age.inHours > 1) {
        confidence -= 0.1;
      }
    }
    
    // Adjust based on data consistency
    final googleScore = _normalizeGoogleScore(googleData);
    final foursquareScore = _normalizeFoursquareScore(foursquareData);
    final scoreDiff = (googleScore - foursquareScore).abs();
    if (scoreDiff > 1) {
      confidence -= 0.1 * scoreDiff;
    }
    
    return confidence.clamp(0.0, 1.0);
  }
}
