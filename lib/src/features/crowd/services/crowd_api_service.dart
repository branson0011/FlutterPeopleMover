import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/crowd_level_standard.dart';
import '../../../core/config/api_config.dart';

class CrowdApiService {
  final String _bestTimeApiKey;
  final String _foursquareApiKey;
  final http.Client _client;

  CrowdApiService({
    required String bestTimeApiKey,
    required String foursquareApiKey,
    http.Client? client,
  })  : _bestTimeApiKey = bestTimeApiKey,
        _foursquareApiKey = foursquareApiKey,
        _client = client ?? http.Client();

  Future<Map<String, dynamic>> getBestTimeData(String venueId) async {
    final url = Uri.parse(
      'https://besttime.app/api/v1/forecasts'
      '?venue_id=$venueId'
      '&api_key_private=$_bestTimeApiKey'
    );

    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to fetch BestTime data');
    } catch (e) {
      throw Exception('BestTime API error: $e');
    }
  }

  Future<Map<String, dynamic>> getFoursquareData(String venueId) async {
    final url = Uri.parse('https://api.foursquare.com/v3/places/$venueId');

    try {
      final response = await _client.get(
        url,
        headers: {
          'Authorization': _foursquareApiKey,
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to fetch Foursquare data');
    } catch (e) {
      throw Exception('Foursquare API error: $e');
    }
  }

  Future<CrowdDensity> calculateCombinedCrowdLevel(String venueId) async {
    final bestTimeData = await getBestTimeData(venueId);
    final foursquareData = await getFoursquareData(venueId);

    // Combine and normalize data from both sources
    final bestTimeScore = _normalizeBestTimeScore(bestTimeData);
    final foursquareScore = _normalizeFoursquareScore(foursquareData);

    // Weight the scores (can be adjusted based on reliability)
    const bestTimeWeight = 0.6;
    const foursquareWeight = 0.4;

    final combinedScore = (bestTimeScore * bestTimeWeight) + 
                         (foursquareScore * foursquareWeight);

    return CrowdLevelStandard.fromPercentage(combinedScore);
  }

  double _normalizeBestTimeScore(Map<String, dynamic> data) {
    final rawScore = data['analysis']?['busy_score'] ?? 0;
    return rawScore / 100; // BestTime uses 0-100 scale
  }

  double _normalizeFoursquareScore(Map<String, dynamic> data) {
    final rawScore = data['popular']?['current_popularity'] ?? 0;
    return rawScore / 100; // Normalize to 0-1 scale
  }
}
