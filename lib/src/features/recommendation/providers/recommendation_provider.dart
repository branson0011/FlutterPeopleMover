import 'package:flutter/foundation.dart';
import '../services/recommendation_service.dart';
import '../models/venue_model.dart';
import '../models/user_preference.dart';

class RecommendationProvider with ChangeNotifier {
  final RecommendationService _recommendationService;
  List<VenueModel> _recommendations = [];
  bool _isLoading = false;
  String? _error;
  UserPreference? _userPreferences;
  Map<String, bool> _selectedFilters = {};

  List<VenueModel> get recommendations => _recommendations;
  bool get isLoading => _isLoading;

  Future<void> fetchRecommendations(String userId) async {
    _setLoading(true);
    
    try {
      // Get user preferences first
      _userPreferences = await _recommendationService.getUserPreferences(userId);
      
      // Apply filters to recommendations
      final filteredRecommendations = _applyFilters(_recommendations);
      _recommendations = filteredRecommendations;
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }
  
  void updateFilters(Map<String, bool> filters) {
    _selectedFilters = filters;
    final filteredRecommendations = _applyFilters(_recommendations);
    _recommendations = filteredRecommendations;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  List<VenueModel> _applyFilters(List<VenueModel> recommendations) {
    // Implement filtering logic based on _selectedFilters
    return recommendations; // Placeholder for actual filtering logic
  }
}
