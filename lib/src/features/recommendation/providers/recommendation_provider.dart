import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/venue_model.dart';
import '../services/recommendation_service.dart';
import '../services/analytics_service.dart';
import '../services/cache_service.dart';

class RecommendationProvider with ChangeNotifier {
  final RecommendationService recommendationService;
  final AnalyticsService analyticsService;
  final CacheService cacheService;
  
  List<Venue> venues = [];
  List<Venue> recommendedVenues = [];
  bool isLoading = false;
  String? error;
  Map<String, dynamic> preferences = {};
  List<String> recentVisits = [];
  DateTime? lastFetch;

  static const Duration cacheDuration = Duration(minutes: 15);

  RecommendationProvider({
    required AnalyticsService analytics,
    required CacheService cache,
  })  : recommendationService = RecommendationService(),
        analyticsService = analytics,
        cacheService = cache;

  Future<void> fetchNearbyVenues({
    required LatLng userLocation,
    double radius = 5000,
    Map<String, dynamic>? filters,
  }) async {
    final String cacheKey = '${userLocation.latitude},${userLocation.longitude}_$radius';
    
    if (_shouldUseCache(cacheKey)) {
      final cachedVenues = await cacheService.getCachedVenues(cacheKey);
      if (cachedVenues != null) {
        venues = cachedVenues;
        notifyListeners();
        return;
      }
    }
    
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      venues = await recommendationService.getNearbyVenues(
        userLocation: userLocation,
        radius: radius,
        filters: filters,
      );

      await cacheService.cacheVenues(cacheKey, venues);

      isLoading = false;
      notifyListeners();
    } catch (exception) {
      error = exception.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecommendations({
    required LatLng userLocation,
    double radius = 5000,
    int limit = 10,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      recommendedVenues = await recommendationService.getRecommendedVenues(
        userLocation: userLocation,
        preferences: preferences,
        radius: radius,
        limit: limit,
      );

      isLoading = false;
      notifyListeners();
    } catch (exception) {
      error = exception.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void updatePreferences(Map<String, dynamic> newPreferences) {
    preferences = {...preferences, ...newPreferences};
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  bool _shouldUseCache(String cacheKey) {
    // Implement cache logic here
    return false; // Placeholder return
  }
}
