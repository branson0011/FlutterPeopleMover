import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/venue_model.dart';
import '../models/recommendation_score.dart';
import '../models/user_preference.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<VenueModel>> getRecommendations({
    required String userId,
    required Position userLocation,
    UserPreference? preferences,
    int limit = 10,
  }) async {
    try {
      final venues = await _getNearbyVenues(userLocation);
      final scores = await _calculateScores(
        venues,
        userLocation,
        preferences,
      );
      
      // Apply preference weights if available
      if (preferences != null) {
        for (var score in scores) {
          final categoryWeight = preferences.categoryWeights[score.category] ?? 1.0;
          score.score *= categoryWeight;
          
          // Apply explicit preferences
          if (preferences.explicitPreferences['categories']?.contains(score.category) ?? false) {
            score.score *= 1.2; // Boost score by 20% for preferred categories
          }
        }
      }
      
      scores.sort((a, b) => b.score.compareTo(a.score));
      return scores
          .take(limit)
          .map((score) => venues.firstWhere((v) => v.id == score.itemId))
          .toList();
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }

  Future<UserPreference> getUserPreferences(String userId) async {
    final doc = await _firestore
        .collection('user_preferences')
        .doc(userId)
        .get();
        
    if (!doc.exists) {
      return _createDefaultPreferences(userId);
    }
    
    return UserPreference.fromMap(doc.data()!);
  }

  Future<void> updatePreferences(String userId, UserPreference preferences) async {
    await _firestore
        .collection('user_preferences')
        .doc(userId)
        .set(preferences.toMap());
  }

  // Other methods like _getNearbyVenues and _calculateScores would be here
}
