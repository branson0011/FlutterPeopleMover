import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/recommendation_score.dart';
import '../models/user_preference.dart';
import '../models/venue_model.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const double _locationWeight = 0.3;
  static const double _ratingWeight = 0.2;
  static const double _popularityWeight = 0.15;
  static const double _preferenceWeight = 0.35;

  Future<List<VenueModel>> getRecommendations({
    required String userId,
    required Position userLocation,
    int limit = 10,
  }) async {
    try {
      // Get user preferences
      final userPrefs = await _getUserPreferences(userId);
      
      // Get nearby venues
      final venues = await _getNearbyVenues(userLocation);
      
      // Calculate scores
      final scoredVenues = await Future.wait(
        venues.map((venue) => _calculateVenueScore(
          venue,
          userLocation,
          userPrefs,
        )),
      );
      
      // Sort by score and return top results
      scoredVenues.sort((a, b) => b.score.compareTo(a.score));
      
      return venues.where((venue) => 
        scoredVenues.take(limit).any((scored) => scored.itemId == venue.id)
      ).toList();
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }

  Future<UserPreference> _getUserPreferences(String userId) async {
    final documentSnapshot = await _firestore
        .collection('user_preferences')
        .doc(userId)
        .get();
        
    if (!documentSnapshot.exists) {
      return _createDefaultPreferences(userId);
    }
    
    return UserPreference.fromMap(documentSnapshot.data()!);
  }

  Future<List<VenueModel>> _getNearbyVenues(Position userLocation) async {
    final snapshot = await _firestore
        .collection('venues')
        .where('latitude', isGreaterThan: userLocation.latitude - 0.1)
        .where('latitude', isLessThan: userLocation.latitude + 0.1)
        .get();
        
    return snapshot.docs
        .map((documentSnapshot) => VenueModel.fromMap(documentSnapshot.data()))
        .toList();
  }

  Future<RecommendationScore> _calculateVenueScore(
    VenueModel venue,
    Position userLocation,
    UserPreference userPrefs,
  ) async {
    // Calculate distance score
    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      venue.latitude,
      venue.longitude,
    );
    final locationScore = _calculateLocationScore(distance);
    
    // Calculate rating score
    final ratingScore = venue.rating / 5.0;
    
    // Calculate popularity score
    final popularityScore = _calculatePopularityScore(venue.reviewCount);
    
    // Calculate preference score
    final preferenceScore = _calculatePreferenceScore(venue, userPrefs);
    
    // Calculate final score
    final finalScore = (locationScore * _locationWeight) +
        (ratingScore * _ratingWeight) +
        (popularityScore * _popularityWeight) +
        (preferenceScore * _preferenceWeight);
        
    return RecommendationScore(
      itemId: venue.id,
      score: finalScore,
      factors: {
        'location': locationScore,
        'rating': ratingScore,
        'popularity': popularityScore,
        'preference': preferenceScore,
      },
      timestamp: DateTime.now(),
    );
  }

  double _calculateLocationScore(double distance) {
    // Convert distance to a 0-1 score (closer = higher)
    const maxDistance = 5000.0; // 5km
    return 1.0 - (distance / maxDistance).clamp(0.0, 1.0);
  }

  double _calculatePopularityScore(int reviewCount) {
    // Convert review count to a 0-1 score
    const maxReviews = 1000;
    return (reviewCount / maxReviews).clamp(0.0, 1.0);
  }

  double _calculatePreferenceScore(
    VenueModel venue,
    UserPreference userPrefs,
  ) {
    double score = 0.0;
    int matches = 0;
    
    // Check category matches
    for (final category in venue.categories) {
      if (userPrefs.categoryWeights.containsKey(category)) {
        score += userPrefs.categoryWeights[category]!;
        matches++;
      }
    }
    
    // Check explicit preferences
    for (final entry in userPrefs.explicitPreferences.entries) {
      if (venue.attributes.containsKey(entry.key) &&
          entry.value.contains(venue.attributes[entry.key])) {
        score += 1.0;
        matches++;
      }
    }
    
    // Check implicit preferences
    for (final entry in userPrefs.implicitPreferences.entries) {
      if (venue.attributes.containsKey(entry.key)) {
        score += entry.value;
        matches++;
      }
    }
    
    return matches > 0 ? score / matches : 0.0;
  }

  UserPreference _createDefaultPreferences(String userId) {
    return UserPreference(
      userId: userId,
      categoryWeights: {},
      explicitPreferences: {},
      implicitPreferences: {},
      lastUpdated: DateTime.now(),
    );
  }
}
