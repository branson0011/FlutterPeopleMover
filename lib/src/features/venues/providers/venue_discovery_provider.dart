import 'package:flutter/foundation.dart';
import '../services/venue_discovery_service.dart';
import '../models/venue_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VenueDiscoveryProvider with ChangeNotifier {
  final VenueDiscoveryService _service = VenueDiscoveryService();
  List<VenueModel> _venues = [];
  List<VenueModel> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  List<VenueModel> get venues => _venues;
  List<VenueModel> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch nearby venues
  Future<void> fetchNearbyVenues({
    required double latitude,
    required double longitude,
    required double radius,
    Map<String, dynamic>? filters,
  }) async {
    _setLoading(true);
    try {
      _service.getNearbyVenues(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        filters: filters,
      ).listen(
        (venues) {
          _venues = venues;
          notifyListeners();
        },
        onError: (error) {
          _setError(error.toString());
        },
      );
    } catch (exception) {
      _setError(exception.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch personalized recommendations
  Future<void> fetchRecommendations({
    required String userId,
    required Map<String, dynamic> preferences,
    required GeoPoint location,
  }) async {
    _setLoading(true);
    try {
      _recommendations = await _service.getPersonalizedRecommendations(
        userId: userId,
        preferences: preferences,
        location: location,
      );
      notifyListeners();
    } catch (exception) {
      _setError(exception.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
