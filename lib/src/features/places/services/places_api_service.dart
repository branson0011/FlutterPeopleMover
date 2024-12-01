import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/place.dart';
import '../../../core/config/api_config.dart';

class PlacesApiService {
  final String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String _apiKey = ApiConfig.googleMapsApiKey;
  final http.Client _client;

  PlacesApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Place>> searchNearby({
    required LatLng location,
    required double radius,
    String? type,
    String? keyword,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/nearbysearch/json?'
      'location=${location.latitude},${location.longitude}'
      '&radius=$radius'
      '&key=$_apiKey'
      '${type != null ? '&type=$type' : ''}'
      '${keyword != null ? '&keyword=$keyword' : ''}'
    );

    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((place) => Place.fromGooglePlaces(place))
            .toList();
      }
      throw Exception('Failed to fetch nearby places');
    } catch (e) {
      throw Exception('Places API error: $e');
    }
  }

  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      '$_baseUrl/details/json?'
      'place_id=$placeId'
      '&fields=name,formatted_address,geometry,rating,user_ratings_total,current_popularity,photos'
      '&key=$_apiKey'
    );

    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PlaceDetails.fromGooglePlaces(data['result']);
      }
      throw Exception('Failed to fetch place details');
    } catch (e) {
      throw Exception('Place Details API error: $e');
    }
  }

  Future<List<PlacePhoto>> getPlacePhotos(String placeId) async {
    final details = await getPlaceDetails(placeId);
    return details.photos;
  }
}
