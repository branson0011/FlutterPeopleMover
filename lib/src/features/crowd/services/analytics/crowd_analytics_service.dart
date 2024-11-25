import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/crowd_level_data.dart';

class CrowdAnalyticsService {
  final FirebaseFirestore _firestore;
  
  CrowdAnalyticsService({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _analytics => 
      _firestore.collection('crowd_analytics');
  
  CollectionReference get _predictions => 
      _firestore.collection('crowd_predictions');

  Future<void> trackCrowdLevel({
    required String venueId,
    required CrowdLevelData actualData,
    CrowdLevelData? predictedData,
  }) async {
    final timestamp = DateTime.now();
    
    await _analytics.add({
      'venueId': venueId,
      'timestamp': timestamp,
      'actualLevel': actualData.level.level,
      'predictedLevel': predictedData?.level.level,
      'confidence': actualData.confidence,
      'accuracy': predictedData != null 
          ? _calculateAccuracy(actualData, predictedData) 
          : null,
      'source': actualData.source,
      'metadata': {
        ...?actualData.metadata,
        'predictionError': predictedData != null 
            ? (actualData.level.level - predictedData.level.level).abs() 
            : null,
      },
    });
  }

  Future<void> recordPrediction({
    required String venueId,
    required CrowdLevelData prediction,
    required DateTime targetTime,
  }) async {
    await _predictions.add({
      'venueId': venueId,
      'timestamp': DateTime.now(),
      'targetTime': targetTime,
      'predictedLevel': prediction.level.level,
      'confidence': prediction.confidence,
      'metadata': prediction.metadata,
    });
  }

  Stream<List<CrowdLevelData>> getHistoricalData(
    String venueId, {
    Duration? timeWindow,
  }) {
    Query query = _analytics
        .where('venueId', isEqualTo: venueId)
        .orderBy('timestamp', descending: true);

    if (timeWindow != null) {
      final cutoff = DateTime.now().subtract(timeWindow);
      query = query.where(
        'timestamp', 
        isGreaterThanOrEqualTo: cutoff
      );
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CrowdLevelData(
          level: CrowdLevel.fromLevel(data['actualLevel'] as int),
          confidence: data['confidence'] as double,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          source: data['source'] as String,
          metadata: data['metadata'] as Map<String, dynamic>?,
        );
      }).toList();
    });
  }

  Future<Map<String, dynamic>> getAnalytics(
    String venueId, {
    Duration timeWindow = const Duration(days: 7),
  }) async {
    final cutoff = DateTime.now().subtract(timeWindow);
    
    final snapshot = await _analytics
        .where('venueId', isEqualTo: venueId)
        .where('timestamp', isGreaterThanOrEqualTo: cutoff)
        .get();

    final records = snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    return {
      'averageAccuracy': _calculateAverageAccuracy(records),
      'predictionSuccess': _calculatePredictionSuccess(records),
      'confidenceMetrics': _calculateConfidenceMetrics(records),
      'peakTimes': _analyzePeakTimes(records),
      'trendAnalysis': _analyzeTrends(records),
    };
  }

  double _calculateAccuracy(
    CrowdLevelData actual, 
    CrowdLevelData predicted
  ) {
    final diff = (actual.level.level - predicted.level.level).abs();
    return 1.0 - (diff / 4.0); // Normalize to 0-1 scale
  }

  double _calculateAverageAccuracy(List<Map<String, dynamic>> records) {
    final accuracies = records
        .where((r) => r['accuracy'] != null)
        .map((r) => r['accuracy'] as double);
    
    if (accuracies.isEmpty) return 0.0;
    return accuracies.reduce((a, b) => a + b) / accuracies.length;
  }

  Map<String, double> _calculatePredictionSuccess(
    List<Map<String, dynamic>> records
  ) {
    final totalPredictions = records
        .where((r) => r['predictedLevel'] != null)
        .length;
    
    if (totalPredictions == 0) return {'rate': 0.0};

    final successfulPredictions = records
        .where((r) => r['accuracy'] != null && r['accuracy'] as double >= 0.8)
        .length;

    return {
      'rate': successfulPredictions / totalPredictions,
      'total': totalPredictions.toDouble(),
      'successful': successfulPredictions.toDouble(),
    };
  }

  Map<String, dynamic> _calculateConfidenceMetrics(
    List<Map<String, dynamic>> records
  ) {
    final confidences = records
        .where((r) => r['confidence'] != null)
        .map((r) => r['confidence'] as double)
        .toList();

    if (confidences.isEmpty) {
      return {
        'average': 0.0,
        'min': 0.0,
        'max': 0.0,
      };
    }

    return {
      'average': confidences.reduce((a, b) => a + b) / confidences.length,
      'min': confidences.reduce((a, b) => a < b ? a : b),
      'max': confidences.reduce((a, b) => a > b ? a : b),
    };
  }

  Map<String, List<int>> _analyzePeakTimes(
    List<Map<String, dynamic>> records
  ) {
    final hourlyLevels = List<List<int>>.generate(
      24, 
      (_) => []
    );

    for (final record in records) {
      final timestamp = (record['timestamp'] as Timestamp).toDate();
      final level = record['actualLevel'] as int;
      hourlyLevels[timestamp.hour].add(level);
    }

    return {
      'averageLevels': List.generate(24, (hour) {
        final levels = hourlyLevels[hour];
        if (levels.isEmpty) return 0;
        return levels.reduce((a, b) => a + b) ~/ levels.length;
      }),
    };
  }

  Map<String, dynamic> _analyzeTrends(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return {};

    records.sort((a, b) => 
      (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp)
    );

    final trends = <String, dynamic>{
      'overall': _calculateTrendDirection(records),
      'byDayOfWeek': _calculateTrendsByDay(records),
    };

    return trends;
  }

  String _calculateTrendDirection(List<Map<String, dynamic>> records) {
    if (records.length < 2) return 'stable';

    final first = records.first['actualLevel'] as int;
    final last = records.last['actualLevel'] as int;
    final diff = last - first;

    if (diff > 1) return 'increasing';
    if (diff < -1) return 'decreasing';
    return 'stable';
  }

  Map<String, String> _calculateTrendsByDay(
    List<Map<String, dynamic>> records
  ) {
    final dayTrends = <int, List<Map<String, dynamic>>>{};

    for (final record in records) {
      final day = (record['timestamp'] as Timestamp)
          .toDate()
          .weekday;
      dayTrends.putIfAbsent(day, () => []).add(record);
    }

    return Map.fromEntries(
      dayTrends.entries.map((entry) => 
        MapEntry(
          _getDayName(entry.key),
          _calculateTrendDirection(entry.value),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = [
      'monday', 'tuesday', 'wednesday', 
      'thursday', 'friday', 'saturday', 'sunday'
    ];
    return days[weekday - 1];
  }
}
