import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/crowd_level_data.dart';

class FoursquareApiClient {
  final String apiKey;
  final String baseUrl = 'https://api.foursquare.com/v3';

  FoursquareApiClient({required this.apiKey});

  Future<Map<String, dynamic>> getVenueDetails(String venueId) async {
    final url = Uri.parse('$baseUrl/places/$venueId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': apiKey,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to get venue details: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getPopularHours(String venueId) async {
    final url = Uri.parse('$baseUrl/places/$venueId/hours/popular');
    final response = await http.get(
      url,
      headers: {
        'Authorization': apiKey,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to get popular hours: ${response.statusCode}');
  }

  CrowdLevel mapPopularityToCrowdLevel(int popularity) {
    // Foursquare uses a 0-10 scale
    if (popularity < 2) return CrowdLevel.veryEmpty;
    if (popularity < 4) return CrowdLevel.light;
    if (popularity < 6) return CrowdLevel.moderate;
    if (popularity < 8) return CrowdLevel.busy;
    return CrowdLevel.veryCrowded;
  }

  CrowdLevel mapRawScoreToCrowdLevel(int rawScore) {
    // BestTime uses a 0-100 score
    if (rawScore < 20) return CrowdLevel.veryEmpty;
    if (rawScore < 40) return CrowdLevel.light;
    if (rawScore < 60) return CrowdLevel.moderate;
    if (rawScore < 80) return CrowdLevel.busy;
    return CrowdLevel.veryCrowded;
  }
}
