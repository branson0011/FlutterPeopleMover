import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/recommendation_service.dart';
import '../models/venue_model.dart';

class RecommendationProvider with ChangeNotifier {
  final RecommendationService _recommendationService = RecommendationService();
  
  List<VenueModel> _recommendations = [];
  bool _isLoading = false;
  String? _error;
  
  List<VenueModel> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRecommendations(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get recommendations
      _recommendations = await _recommendationService.getRecommendations(
        userId: userId,
        userLocation: position,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRecommendations(String userId) async {
    _recommendations = [];
    notifyListeners();
    await fetchRecommendations(userId);
  }
}
