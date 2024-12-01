import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../venues/services/integrated_venue_service.dart';
import '../../venues/models/venue.dart';

class PlacesProvider with ChangeNotifier {
  final IntegratedVenueService _venueService;
  List<Venue> _nearbyVenues = [];
  bool _isLoading = false;
  String? _error;

  PlacesProvider({IntegratedVenueService? venueService})
      : _venueService = venueService ?? IntegratedVenueService();

  List<Venue> get nearbyVenues => _nearbyVenues;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> searchNearbyPlaces({
    required LatLng location,
    double radius = 1000,
    String? keyword,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _nearbyVenues = await _venueService.searchVenues(
        location: location,
        radius: radius,
        keyword: keyword,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Venue?> getVenueDetails(String venueId) async {
    try {
      return await _venueService.getVenueDetails(venueId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
