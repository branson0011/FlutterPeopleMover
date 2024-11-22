import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_preference.dart';
import '../models/venue_model.dart';
import '../models/recommendation_score.dart';
import 'dart:math';

class RecommendationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Preferences
  Future<void> saveUserPreferences(UserPreference preferences) async {
    await _firestore
        .collection('user_preferences')
        .doc(preferences.userId)
        .set(preferences.toMap());
  }

  Future<UserPreference?> getUserPreferences(String userId) async {
    final documentSnapshot = await _firestore
        .collection('user_preferences')
        .doc(userId)
        .get();
    
    if (!documentSnapshot.exists) return null;
    return UserPreference.fromMap(documentSnapshot.data()!);
  }

  // Venues
  Future<List<VenueModel>> getNearbyVenues({
    required double latitude,
    required double longitude,
    double radiusKilometers = 5.0,
  }) async {
    // Convert kilometers to latitude/longitude degrees (approximate)
    final latitudeDelta = radiusKilometers / 111.0;
    final longitudeDelta = radiusKilometers / (111.0 * cos(latitude * pi / 180.0));

    final snapshot = await _firestore
        .collection('venues')
        .where('latitude', isGreaterThan: latitude - latitudeDelta)
        .where('latitude', isLessThan: latitude + latitudeDelta)
        .get();

    final venues = snapshot.docs
        .map((documentSnapshot) => VenueModel.fromMap(documentSnapshot.data()))
        .toList();

    // Filter by longitude (Firestore can't query on multiple fields)
    return venues.where((venue) =>
        venue.longitude >= longitude - longitudeDelta &&
        venue.longitude <= longitude + longitudeDelta
    ).toList();
  }

  // Recommendation Scores
  Future<void> saveRecommendationScore(RecommendationScore score) async {
    await _firestore
        .collection('recommendation_scores')
        .add(score.toMap());
  }

  Future<List<RecommendationScore>> getRecentScores({
    required String userId,
    required String venueId,
    Duration duration = const Duration(days: 7),
  }) async {
    final cutoff = DateTime.now().subtract(duration);
    
    final snapshot = await _firestore
        .collection('recommendation_scores')
        .where('userId', isEqualTo: userId)
        .where('venueId', isEqualTo: venueId)
        .where('timestamp', isGreaterThan: cutoff)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((documentSnapshot) => RecommendationScore.fromMap(documentSnapshot.data()))
        .toList();
  }

  // User Interactions
  Future<void> trackUserInteraction({
    required String userId,
    required String venueId,
    required String interactionType,
    Map<String, dynamic>? metadata,
  }) async {
    await _firestore.collection('user_interactions').add({
      'userId': userId,
      'venueId': venueId,
      'interactionType': interactionType,
      'metadata': metadata,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserInteractionHistory({
    required String userId,
    int limit = 50,
  }) async {
    final snapshot = await _firestore
        .collection('user_interactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((documentSnapshot) => documentSnapshot.data())
        .toList();
  }

  // Category Preferences
  Future<void> updateCategoryPreferences({
    required String userId,
    required Map<String, double> categoryWeights,
  }) async {
    await _firestore
        .collection('user_preferences')
        .doc(userId)
        .update({
          'categoryWeights': categoryWeights,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
  }

  // Venue Categories
  Future<List<String>> getAvailableCategories() async {
    final snapshot = await _firestore
        .collection('venue_categories')
        .get();

    return snapshot.docs
        .map((documentSnapshot) => documentSnapshot.id)
        .toList();
  }

  // Analytics
  Future<void> logRecommendationImpression({
    required String userId,
    required String venueId,
    required double score,
    required Map<String, double> factors,
  }) async {
    await _firestore.collection('recommendation_impressions').add({
      'userId': userId,
      'venueId': venueId,
      'score': score,
      'factors': factors,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> getRecommendationStats({
    required String userId,
    Duration period = const Duration(days: 30),
  }) async {
    final cutoff = DateTime.now().subtract(period);
    
    final snapshot = await _firestore
        .collection('recommendation_impressions')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThan: cutoff)
        .get();

    final impressions = snapshot.docs;
    
    // Calculate basic stats
    return {
      'totalImpressions': impressions.length,
      'averageScore': impressions.isEmpty ? 0.0 :
          impressions.map((documentSnapshot) => documentSnapshot.data()['score'] as double)
              .reduce((a, b) => a + b) / impressions.length,
      'topCategories': _calculateTopCategories(impressions),
    };
  }

  Map<String, int> _calculateTopCategories(List<QueryDocumentSnapshot> impressions) {
    final categoryCount = <String, int>{};
    
    for (final impression in impressions) {
      final factors = impression.data()['factors'] as Map<String, dynamic>;
      factors.forEach((category, score) {
        if (score > 0.5) { // Only count significant factors
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
      });
    }
    
    return categoryCount;
  }
}
