import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/crowd_level_data.dart';

class BestTimeApiClient {
  final String apiKey;
  final String baseUrl = 'https://besttime.app/api/v1';

  BestTimeApiClient({required this.apiKey});

  Future<Map<String, dynamic>> getForecast(String venueId) async {
    final url = Uri.parse('$baseUrl/forecasts/$venueId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to get forecast: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getLiveData(String venueId) async {
    final url = Uri.parse('$baseUrl/venues/$venueId/live');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to get live data: ${response.statusCode}');
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
