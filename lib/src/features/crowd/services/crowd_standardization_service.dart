import '../models/crowd_level_standard.dart';
import '../models/crowd_metrics.dart';

/// Service for standardizing crowd levels across different data sources
class CrowdStandardizationService {
  Future<CrowdMetrics> calculateCombinedMetrics({
    required Map<String, dynamic> googleData,
    required Map<String, dynamic> bestTimeData,
    required Map<String, dynamic> foursquareData,
  }) async {
    final density = peopleCount / areaInSquareMeters;
    
    // Additional logic to combine metrics from different sources
    double confidenceScore = _calculateConfidenceScore(googleData, bestTimeData, foursquareData);
    
    // Create and return a CrowdMetrics object based on combined data
    return CrowdMetrics(density: density, confidenceScore: confidenceScore);
  }

  double _calculateConfidenceScore(
    Map<String, dynamic> googleData,
    Map<String, dynamic> bestTimeData,
    Map<String, dynamic> foursquareData,
  ) {
    double confidence = 0.0;
    int sourcesCount = 0;

    // Google Places confidence (40%)
    if (googleData['current_popularity'] != null) {
      confidence += 0.4 * (googleData['rating'] ?? 0.5);
      sourcesCount++;
    }

    // BestTime confidence (30%)
    if (bestTimeData['analysis'] != null) {
      confidence += 0.3 * (bestTimeData['analysis']['confidence'] ?? 0.5);
      sourcesCount++;
    }

    // Foursquare confidence (30%)
    if (foursquareData['popularity'] != null) {
      confidence += 0.3 * (foursquareData['rating'] ?? 0.5);
      sourcesCount++;
    }

    return sourcesCount > 0 ? confidence / sourcesCount : 0.5;
  }
}
