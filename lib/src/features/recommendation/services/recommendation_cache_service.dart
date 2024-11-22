import 'package:shared_preferences.dart';
import 'dart:convert';
import '../models/venue_model.dart';
import '../models/recommendation_score.dart';

class RecommendationCacheService {
  final SharedPreferences sharedPreferences;
  static const String recommendationKey = 'cached_recommendations';
  static const String scoresKey = 'cached_scores';
  static const Duration cacheDuration = Duration(hours: 1);

  RecommendationCacheService(this.sharedPreferences);

  Future<void> cacheRecommendations(List<VenueModel> venues) async {
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'venues': venues.map((venue) => venue.toMap()).toList(),
    };
    
    await sharedPreferences.setString(
      recommendationKey,
      jsonEncode(data),
    );
  }

  Future<List<VenueModel>?> getCachedRecommendations() async {
    final data = sharedPreferences.getString(recommendationKey);
    if (data == null) return null;

    final decoded = jsonDecode(data);
    final timestamp = DateTime.parse(decoded['timestamp']);
    
    if (DateTime.now().difference(timestamp) > cacheDuration) {
      await sharedPreferences.remove(recommendationKey);
      return null;
    }

    return (decoded['venues'] as List)
        .map((venue) => VenueModel.fromMap(venue))
        .toList();
  }

  Future<void> cacheScores(List<RecommendationScore> scores) async {
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'scores': scores.map((score) => score.toMap()).toList(),
    };
    
    await sharedPreferences.setString(
      scoresKey,
      jsonEncode(data),
    );
  }

  Future<List<RecommendationScore>?> getCachedScores() async {
    final data = sharedPreferences.getString(scoresKey);
    if (data == null) return null;

    final decoded = jsonDecode(data);
    final timestamp = DateTime.parse(decoded['timestamp']);
    
    if (DateTime.now().difference(timestamp) > cacheDuration) {
      await sharedPreferences.remove(scoresKey);
      return null;
    }

    return (decoded['scores'] as List)
        .map((score) => RecommendationScore.fromMap(score))
        .toList();
  }

  Future<void> clearCache() async {
    await Future.wait([
      sharedPreferences.remove(recommendationKey),
      sharedPreferences.remove(scoresKey),
    ]);
  }
}
