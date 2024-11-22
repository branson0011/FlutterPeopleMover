import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/venue_model.dart';

class RecommendationService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  
  Future<List<Venue>> getNearbyVenues({
    required LatLng userLocation,
    required double radius,
    required Map<String, dynamic> preferences,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final bounds = _calculateBounds(userLocation, radius);
      
      Query query = firebaseFirestore.collection('venues')
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .where('location', isGreaterThan: bounds['min'])
          .where('location', isLessThan: bounds['max']);
      
      if (filters != null) {
        query = _applyFilters(query, filters);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((document) => Venue.fromFirestore(document))
          .where((venue) => _isWithinRadius(venue.location, userLocation, radius))
          .toList();
    } catch (exception) {
      print('Error getting nearby venues: $exception');
      return [];
    }
  }

  Query _applyFilters(Query query, Map<String, dynamic> filters) {
    if (filters.containsKey('priceLevel')) {
      query = query.where('priceLevel', isEqualTo: filters['priceLevel']);
    }
    
    if (filters.containsKey('type')) {
      query = query.where('type', isEqualTo: filters['type']);
    }
    
    if (filters.containsKey('rating')) {
      query = query.where('rating', isGreaterThanOrEqualTo: filters['rating']);
    }
    
    if (filters.containsKey('tags')) {
      query = query.where('tags', arrayContainsAny: filters['tags']);
    }
    
    return query;
  }

  Map<String, GeoPoint> _calculateBounds(LatLng center, double radiusInKilometers) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers
    
    double angularDistance = radiusInKilometers / earthRadius;
    
    double minLat = center.latitude - angularDistance * 180/3.141592653589793;
    double maxLat = center.latitude + angularDistance * 180/3.141592653589793;
    
    double minLng = center.longitude - angularDistance * 180/3.141592653589793 / cos(center.latitude * 3.141592653589793/180);
    double maxLng = center.longitude + angularDistance * 180/3.141592653589793 / cos(center.latitude * 3.141592653589793/180);
    
    return {
      'min': GeoPoint(minLat, minLng),
      'max': GeoPoint(maxLat, maxLng),
    };
  }

  bool _isWithinRadius(LatLng point1, LatLng point2, double radius) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers
    
    double lat1 = point1.latitude * 3.141592653589793/180;
    double lat2 = point2.latitude * 3.141592653589793/180;
    double lng1 = point1.longitude * 3.141592653589793/180;
    double lng2 = point2.longitude * 3.141592653589793/180;
    
    double deltaLat = lat2 - lat1;
    double deltaLng = lng2 - lng1;
    
    double a = sin(deltaLat/2) * sin(deltaLat/2) +
        cos(lat1) * cos(lat2) *
        sin(deltaLng/2) * sin(deltaLng/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double distance = earthRadius * c;
    
    return distance <= radius;
  }

  Future<List<Venue>> getRecommendedVenues({
    required LatLng userLocation,
    required Map<String, dynamic> preferences,
    required double radius,
    int limit = 10,
    required List<String> recentVisits,
  }) async {
    try {
      final venues = await getNearbyVenues(
        userLocation: userLocation,
        radius: radius,
        preferences: preferences,
      );
      
      final scoredVenues = venues.map((venue) {
        final score = _calculateVenueScore(
          venue: venue,
          userLocation: userLocation,
          preferences: preferences,
          recentVisits: recentVisits,
        );
        return MapEntry(venue, score);
      }).toList();
      
      scoredVenues.sort((a, b) => b.value.compareTo(a.value));
      
      return scoredVenues
          .take(limit)
          .map((entry) => entry.key)
          .toList();
    } catch (exception) {
      print('Error getting recommended venues: $exception');
      return [];
    }
  }

  double _calculateVenueScore({
    required Venue venue,
    required LatLng userLocation,
    required Map<String, dynamic> preferences,
    required List<String> recentVisits,
  }) {
    Map<String, double> components = {
      'rating': _calculateRatingScore(venue),
      'distance': _calculateDistanceScore(venue, userLocation),
      'preferences': _calculatePreferenceScore(venue, preferences),
      'crowdLevel': _calculateCrowdScore(venue, preferences),
      'popularity': _calculatePopularityScore(venue, recentVisits),
      'timeRelevance': _calculateTimeRelevance(venue),
      'diversityBonus': _calculateDiversityBonus(venue, recentVisits),
    };
     
    // Apply dynamic weights based on user behavior
    final weights = _calculateDynamicWeights(preferences);
    double totalScore = 0.0;
    
    components.forEach((key, value) {
      totalScore += value * (weights[key] ?? 1.0);
    });
    
    return totalScore;
  }

  double _calculateRatingScore(Venue venue) {
    return ((venue.rating + venue.googleRating) / 2) * 0.3;
  }

  double _calculateDistanceScore(Venue venue, LatLng userLocation) {
    final distance = venue.getDistance(userLocation);
    return (1 - (distance / 5000)).clamp(0.0, 1.0) * 0.2;
  }

  double _calculatePreferenceScore(Venue venue, Map<String, dynamic> preferences) {
    double score = 0.0;
    if (preferences['priceLevel'] == venue.priceLevel) {
      score += 0.15;
    }
    
    if (preferences.containsKey('tags')) {
      final preferredTags = preferences['tags'] as List<String>;
      final matchingTags = venue.tags.where((tag) => preferredTags.contains(tag));
      score += (matchingTags.length / preferredTags.length) * 0.2;
    }
    
    return score;
  }

  double _calculateCrowdScore(Venue venue, Map<String, dynamic> preferences) {
    if (_matchesCrowdPreference(venue.crowdData, preferences['crowdPreference'])) {
      return 0.15;
    }
    return 0.0;
  }

  double _calculatePopularityScore(Venue venue, List<String> recentVisits) {
    // Enhanced popularity scoring
    double score = 0.0;
    
    // Consider review count and ratings
    if (venue.reviews != null) {
      score += (venue.reviews!.length / 100).clamp(0.0, 0.5);
      
      // Calculate average rating trend
      final recentReviews = _getRecentReviews(venue.reviews!, days: 30);
      if (recentReviews.isNotEmpty) {
        final avgRecentRating = recentReviews.map((r) => r['rating'] as num).average;
        score += (avgRecentRating / 5.0) * 0.5;
      }
    }
    
    return score;
  }

  bool _matchesCrowdPreference(Map<String, dynamic> crowdData, String? preference) {
    if (preference == null) return true;
    
    final currentLevel = crowdData['current'] as String?;
    switch (preference.toLowerCase()) {
      case 'quiet':
        return currentLevel == 'low';
      case 'moderate':
        return currentLevel == 'medium';
      case 'busy':
        return currentLevel == 'high';
      default:
        return true;
    }
  }
}
