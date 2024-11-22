import 'package:flutter/foundation.dart';
import '../services/ml_service.dart';
import '../models/venue_model.dart';
import '../models/user_preference.dart';
import '../models/recommendation_score.dart';

class MLRecommendationProvider with ChangeNotifier {
  final MLService _mlService = MLService();
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      await _mlService.initialize();
      _isInitialized = true;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<List<VenueModel>> getMLRecommendations({
    required UserPreference userPrefs,
    required List<VenueModel> venues,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      _setLoading(true);
      final predictions = await _mlService.predictUserPreferences(
        userPrefs,
        venues,
      );

      final scoredVenues = List.generate(
        venues.length,
        (i) => (venue: venues[i], score: predictions[i]),
      );

      scoredVenues.sort((a, b) => b.score.compareTo(a.score));
      return scoredVenues.map((e) => e.venue).toList();
    } catch (e) {
      _setError(e.toString());
      return venues;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> trainModel({
    required List<RecommendationScore> historicalScores,
    required List<VenueModel> venues,
    required UserPreference userPrefs,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      _setLoading(true);
      await _mlService.trainModel(
        historicalScores,
        venues,
        userPrefs,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String value) {
    _error = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }
}
