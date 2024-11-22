import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';
import 'dart:math';
import '../models/recommendation_score.dart';
import '../models/venue_model.dart';
import '../models/user_preference.dart';

class MLService {
  static final MLService _instance = MLService._internal();
  late Interpreter _interpreter;
  bool _isInitialized = false;

  factory MLService() => _instance;

  MLService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _interpreter = await Interpreter.fromAsset('assets/ml/recommendation_model.tflite');
      _isInitialized = true;
    } catch (e) {
      print('Error initializing ML model: $e');
      rethrow;
    }
  }

  Future<List<double>> predictUserPreferences(
    UserPreference userPreferences,
    List<VenueModel> venues,
  ) async {
    if (!_isInitialized) await initialize();

    final input = _prepareInputData(userPreferences, venues);
    final output = List<double>.filled(venues.length, 0);

    try {
      _interpreter.run(input, output);
      return output;
    } catch (e) {
      print('Error running ML prediction: $e');
      return _fallbackPrediction(venues.length);
    }
  }

  List<List<double>> _prepareInputData(
    UserPreference userPreferences,
    List<VenueModel> venues,
  ) {
    final input = <List<double>>[];
    
    for (final venue in venues) {
      final venueFeatures = <double>[
        venue.rating,
        venue.reviewCount.toDouble(),
        ...venue.categories.map((category) => 
          userPreferences.categoryWeights[category] ?? 0.0
        ).toList(),
        ...venue.attributes.values.map((value) => 
          value is num ? value.toDouble() : 0.0
        ).toList(),
      ];
      input.add(venueFeatures);
    }

    return input;
  }

  List<double> _fallbackPrediction(int length) {
    final random = Random();
    return List.generate(
      length,
      (_) => 0.3 + random.nextDouble() * 0.7,
    );
  }

  Future<void> trainModel(
    List<RecommendationScore> historicalScores,
    List<VenueModel> venues,
    UserPreference userPreferences,
  ) async {
    if (!_isInitialized) await initialize();

    final trainingData = _prepareTrainingData(
      historicalScores,
      venues,
      userPreferences,
    );

    try {
      await _interpreter.runForMultipleInputs(
        trainingData.inputs,
        trainingData.outputs,
      );
    } catch (e) {
      print('Error training ML model: $e');
      rethrow;
    }
  }

  ({List<List<double>> inputs, List<List<double>> outputs}) _prepareTrainingData(
    List<RecommendationScore> historicalScores,
    List<VenueModel> venues,
    UserPreference userPreferences,
  ) {
    final inputs = <List<double>>[];
    final outputs = <List<double>>[];

    for (final score in historicalScores) {
      final venue = venues.firstWhere((venue) => venue.id == score.itemId);
      inputs.add(_prepareInputData(userPreferences, [venue])[0]);
      outputs.add([score.score]);
    }

    return (inputs: inputs, outputs: outputs);
  }

  void dispose() {
    if (_isInitialized) {
      _interpreter.close();
      _isInitialized = false;
    }
  }
}
