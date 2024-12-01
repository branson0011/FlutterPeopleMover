import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/crowd_level_standard.dart';
import '../models/crowd_metrics.dart';

class CrowdAnalyticsService {
  final FirebaseAnalytics _analytics;

  CrowdAnalyticsService(this._analytics);

  Future<void> logCrowdLevelView(String locationId, CrowdDensity density) async {
    await _analytics.logEvent(
      name: 'crowd_level_view',
      parameters: {
        'location_id': locationId,
        'density_level': density.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logUserFeedback({
    required String locationId,
    required CrowdDensity reportedDensity,
    required double confidence,
    String? comment,
  }) async {
    await _analytics.logEvent(
      name: 'crowd_feedback_submitted',
      parameters: {
        'location_id': locationId,
        'reported_density': reportedDensity.toString(),
        'confidence_score': confidence,
        'has_comment': comment != null,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logAccuracyMetrics({
    required String locationId,
    required double predictedConfidence,
    required double actualConfidence,
    required Duration timeDifference,
  }) async {
    await _analytics.logEvent(
      name: 'crowd_prediction_accuracy',
      parameters: {
        'location_id': locationId,
        'predicted_confidence': predictedConfidence,
        'actual_confidence': actualConfidence,
        'time_difference_minutes': timeDifference.inMinutes,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logDetailedMetrics(String locationId, CrowdMetrics metrics) async {
    await _analytics.logEvent(
      name: 'crowd_detailed_metrics',
      parameters: {
        'location_id': locationId,
        'density': metrics.density,
        'flow_rate': metrics.flowRate,
        'average_speed': metrics.averageSpeed,
        'turbulence': metrics.turbulence,
        'timestamp': metrics.timestamp.toIso8601String(),
      },
    );
  }
}
