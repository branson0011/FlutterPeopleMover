import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/crowd_level_standard.dart';
import '../services/crowd_cache_service.dart';

class CrowdApiClient {
  final String baseUrl;
  final http.Client httpClient;
  final CrowdCacheService cacheService;

  CrowdApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    required this.cacheService,
  }) : httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> getCrowdData(String locationId) async {
    try {
      // Check cache first
      final cachedData = await cacheService.getCachedCrowdLevel(locationId);
      if (cachedData != null) {
        return cachedData;
      }

      // If not in cache, fetch from API
      final response = await httpClient.get(
        Uri.parse('$baseUrl/crowd-levels/$locationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load crowd data');
      }
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  Future<void> reportCrowdLevel({
    required String locationId,
    required CrowdDensity density,
    required double confidence,
  }) async {
    try {
      await httpClient.post(
        Uri.parse('$baseUrl/crowd-levels/$locationId/reports'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'density': density.toString(),
          'confidence': confidence,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      throw Exception('Failed to report crowd level: $e');
    }
  }
}
