import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/venue.dart';
import '../../places/services/places_api_service.dart';
import '../../crowd/services/crowd_standardization_service.dart';
import '../../crowd/services/crowd_api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UnifiedVenueService {
  final PlacesApiService _placesService;
  final CrowdStandardizationService _crowdService;
  final String _bestTimeApiKey;
  final String _foursquareApiKey;
  final CrowdApiService _crowdApiService;

  UnifiedVenueService({
    required String bestTimeApiKey,
    required String foursquareApiKey,
    PlacesApiService? placesService,
  }) : _bestTimeApiKey = bestTimeApiKey,
       _foursquareApiKey = foursquareApiKey,
       _placesService = placesService ?? PlacesApiService(),
       _crowdApiService = CrowdApiService(bestTimeApiKey: bestTimeApiKey, foursquareApiKey: foursquareApiKey),
       _crowdService = CrowdStandardizationService();

  Future<List<Venue>> searchVenues({
    required LatLng location,
    required double radius,
    String? keyword,
    Map<String, dynamic>? filters,
  }) async {
    // Get base venue data from Google Places
    final places = await _placesService.searchNearby(
      location: location,
      radius: radius,
      keyword: keyword,
    );

    // Enrich with additional data sources
    return Future.wait(places.map((place) async {
      final venue = Venue.fromPlace(place);
      
      // Add BestTime data
      final bestTimeData = await _fetchBestTimeData(venue);
      venue.crowdMetrics?.updateWithBestTime(bestTimeData);
      
      // Add Foursquare data
      final foursquareData = await _fetchFoursquareData(venue);
      venue.updateWithFoursquare(foursquareData);
      
      // Calculate final crowd metrics
      venue.crowdMetrics = await _crowdService.calculateCombinedMetrics(
        googleData: place.rawData,
        bestTimeData: bestTimeData,
        foursquareData: foursquareData,
      );

      // Add our proprietary crowd data
      venue.crowdMetrics = await _fetchCrowdMetrics(venue.id);
      
      // Add real-time crowd level
      venue.crowdDensity = await _crowdApiService.calculateCombinedCrowdLevel(venue.id);
      
      return venue;
    }));
  }

  Future<Map<String, dynamic>> _fetchBestTimeData(Venue venue) async {
    final url = Uri.parse(
      'https://besttime.app/api/v1/forecasts'
      '?venue_id=${venue.id}'
      '&api_key_private=$_bestTimeApiKey'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('BestTime API error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _fetchFoursquareData(Venue venue) async {
    final url = Uri.parse(
      'https://api.foursquare.com/v3/places/${venue.id}'
    );

    try {
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
      return {};
    } catch (e) {
      print('Foursquare API error: $e');
      return {};
    }
  }
}
