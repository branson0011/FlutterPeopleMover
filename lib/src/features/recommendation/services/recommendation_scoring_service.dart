import '../models/recommendation.dart';
import '../../preferences/models/preference_settings.dart';
import 'package:geolocator/geolocator.dart';

class RecommendationScoringService {
  static const double RATING_WEIGHT = 0.35;
  static const double INTEREST_WEIGHT = 0.25;
  static const double LOCATION_WEIGHT = 0.20;
  static const double RECENCY_WEIGHT = 0.15;
  static const double POPULARITY_WEIGHT = 0.05;

  Future<double> calculateScore(
    Recommendation recommendation,
    PreferenceSettings preferences,
    Position? userLocation,
  ) async {
    double score = 0.0;

    // Base rating score (35%)
    score += _calculateRatingScore(recommendation) * RATING_WEIGHT;

    // Interest match score (25%)
    score += _calculateInterestScore(recommendation, preferences) * INTEREST_WEIGHT;

    // Location score (20%)
    if (userLocation != null) {
      score += await _calculateLocationScore(
        recommendation,
        userLocation,
        preferences,
      ) * LOCATION_WEIGHT;
    }

    // Recency score (15%)
    score += _calculateRecencyScore(recommendation) * RECENCY_WEIGHT;

    // Popularity score (5%)
    score += _calculatePopularityScore(recommendation) * POPULARITY_WEIGHT;

    return score;
  }

  double _calculateRatingScore(Recommendation recommendation) {
    return (recommendation.rating / 5.0).clamp(0.0, 1.0);
  }

  double _calculateInterestScore(
    Recommendation recommendation,
    PreferenceSettings preferences,
  ) {
    final userInterests = preferences.interests;
    if (userInterests.isEmpty) return 0.0;

    final recommendationTags = 
        recommendation.metadata['tags'] as List<dynamic>? ?? [];
    
    int matchCount = recommendationTags
        .where((tag) => userInterests.contains(tag))
        .length;

    return (matchCount / userInterests.length).clamp(0.0, 1.0);
  }

  Future<double> _calculateLocationScore(
    Recommendation recommendation,
    Position userLocation,
    PreferenceSettings preferences,
  ) async {
    if (!preferences.locationServices) return 0.0;

    final venueLatitude = recommendation.metadata['latitude'] as double?;
    final venueLongitude = recommendation.metadata['longitude'] as double?;

    if (venueLatitude == null || venueLongitude == null) return 0.0;

    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      venueLatitude,
      venueLongitude,
    );

    // Convert distance to kilometers
    final distanceInKilometers = distance / 1000;
    
    // Get user's preferred maximum distance (default 50 kilometers)
    final maximumDistance = 
        preferences.customSettings['maxDistance'] as double? ?? 50.0;

    // Calculate score based on distance (closer = higher score)
    return (1 - (distanceInKilometers / maximumDistance)).clamp(0.0, 1.0);
  }

  double _calculateRecencyScore(Recommendation recommendation) {
    final age = DateTime.now().difference(recommendation.createdAt).inDays;
    // Consider items up to 30 days old
    return (1 - (age / 30)).clamp(0.0, 1.0);
  }

  double _calculatePopularityScore(Recommendation recommendation) {
    final views = recommendation.metadata['views'] as int? ?? 0;
    final interactions = recommendation.metadata['interactions'] as int? ?? 0;
    
    // Calculate popularity based on views and interactions
    final popularityScore = (views + (interactions * 2)) / 1000;
    return popularityScore.clamp(0.0, 1.0);
  }
}
