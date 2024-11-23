import 'package:flutter/foundation.dart';
import '../services/recommendation_service.dart';
import '../models/recommendation.dart';
import '../../preferences/services/preference_filter_service.dart';
import '../../preferences/models/user_preferences.dart';

class RecommendationProvider with ChangeNotifier {
  final RecommendationService recommendationService = RecommendationService();
  final PreferenceFilterService filterService = PreferenceFilterService();
  List<Recommendation> recommendationsList = [];
  List<Recommendation> filteredRecommendations = [];
  bool isLoading = false;

  List<Recommendation> get recommendations => recommendationsList;
  List<Recommendation> get filteredRecommendations => filteredRecommendations;
  bool get isLoadingStatus => isLoading;

  Future<void> loadRecommendations(String userId, UserPreferences userPreferences) async {
    isLoading = true;
    notifyListeners();

    recommendationService.getRecommendations(userId, userPreferences).listen((recommendations) {
      recommendationsList = recommendations;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> applyPreferenceFilter(UserPreferences preferences) async {
    filteredRecommendations = filterService.filterRecommendations(
      recommendationsList,
      preferences,
    );
    notifyListeners();
  }

  Future<void> rateRecommendation(String recommendationId, double rating) async {
    await recommendationService.rateRecommendation(recommendationId, rating);
  }
}
