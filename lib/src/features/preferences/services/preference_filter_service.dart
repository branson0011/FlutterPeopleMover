import '../models/preference_settings.dart';
import '../../recommendation/models/recommendation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'preference_exception.dart';
import 'recommendation_service.dart';

class PreferenceFilterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RecommendationService _recommendationService = RecommendationService();

  List<Recommendation> filterRecommendations(
    List<Recommendation> recommendations,
    PreferenceSettings preferences,
  ) {
    if (recommendations.isEmpty) return [];

    var filtered = _filterByInterests(recommendations, preferences.interests);
    
    if (preferences.locationServices) {
      filtered = _filterByLocation(filtered, preferences);
    }

    filtered = _applyCustomFilters(filtered, preferences.customSettings);
    filtered.sort((a, b) => _calculateRelevanceScore(b, preferences)
        .compareTo(_calculateRelevanceScore(a, preferences)));

    return filtered;
  }

  List<Recommendation> _filterByInterests(
    List<Recommendation> recommendations,
    List<String> interests,
  ) {
    if (interests.isEmpty) return recommendations;
    
    return recommendations.where((recommendation) {
      final tags = recommendation.metadata['tags'] as List<dynamic>? ?? [];
      return interests.any((interest) => tags.contains(interest));
    }).toList();
  }

  List<Recommendation> _filterByLocation(
    List<Recommendation> recommendations,
    PreferenceSettings preferences,
  ) {
    final maxDistance = preferences.customSettings['maxDistance'] ?? 50.0;
    
    return recommendations.where((recommendation) {
      final distance = recommendation.metadata['distance'] as double? ?? double.infinity;
      return distance <= maxDistance;
    }).toList();
  }

  List<Recommendation> _applyCustomFilters(
    List<Recommendation> recommendations,
    Map<String, dynamic> customSettings,
  ) {
    return recommendations.where((recommendation) {
      for (var setting in customSettings.entries) {
        if (!_matchesCustomFilter(recommendation, setting.key, setting.value)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  bool _matchesCustomFilter(
    Recommendation recommendation,
    String filterKey,
    dynamic filterValue,
  ) {
    final metadata = recommendation.metadata;
    if (!metadata.containsKey(filterKey)) return true;
    
    switch (filterKey) {
      case 'price':
        return metadata[filterKey] <= filterValue;
      case 'rating':
        return metadata[filterKey] >= filterValue;
      case 'category':
        return metadata[filterKey] == filterValue;
      default:
        return true;
    }
  }

  double _calculateRelevanceScore(
    Recommendation recommendation,
    PreferenceSettings preferences,
  ) {
    double score = 0.0;
    
    // Base score from rating (40%)
    score += recommendation.rating * 0.4;
    
    // Interest match score (30%)
    final tags = recommendation.metadata['tags'] as List<dynamic>? ?? [];
    final interestMatchCount = preferences.interests
        .where((interest) => tags.contains(interest))
        .length;
    score += (interestMatchCount / preferences.interests.length) * 0.3;
    
    // Recency score (20%)
    final age = DateTime.now().difference(recommendation.createdAt).inDays;
    score += (30 - age) / 30 * 0.2;
    
    // Location score (10%)
    if (preferences.locationServices) {
      final distance = recommendation.metadata['distance'] as double? ?? double.infinity;
      final maxDistance = preferences.customSettings['maxDistance'] ?? 50.0;
      score += ((maxDistance - distance) / maxDistance).clamp(0.0, 1.0) * 0.1;
    }
    
    return score;
  }

  Future<void> updatePreference(String userId, String key, dynamic value) async {
    try {
      await _firestore.collection('preferences').doc(userId).update({
        'preferences.$key': value,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Update recommendation cache
      await _updateRecommendationCache(userId);
    } catch (e) {
      throw PreferenceException('Failed to update preference: $e');
    }
  }

  Future<void> _updateRecommendationCache(String userId) async {
    final userPrefs = await getUserPreferences(userId).first;
    await _recommendationService.updateRecommendations(
      userId: userId,
      preferences: userPrefs,
    );
  }
}
