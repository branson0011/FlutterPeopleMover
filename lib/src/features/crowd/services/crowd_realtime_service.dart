import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crowd_metrics.dart';
import '../models/crowd_level_standard.dart';
import 'crowd_standardization_service.dart';
import 'crowd_cache_service.dart';

class CrowdRealtimeService {
  final FirebaseFirestore _firestore;
  final CrowdCacheService _cacheService;
  final Duration _updateThreshold = const Duration(minutes: 5);

  CrowdRealtimeService(this._firestore, this._cacheService);

  Stream<CrowdMetrics> getRealtimeMetrics(String locationId) {
    return _firestore
        .collection('crowd_metrics')
        .doc(locationId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          
          final data = snapshot.data()!;
          final metrics = CrowdMetrics.fromMap(data);
          
          // Cache the metrics
          _cacheService.cacheCrowdLevel(locationId, data);
          
          return metrics;
        })
        .where((metrics) => metrics != null)
        .map((metrics) => metrics!);
  }

  Future<void> updateMetrics(String locationId, CrowdMetrics metrics) async {
    await _firestore
        .collection('crowd_metrics')
        .doc(locationId)
        .set(metrics.toMap(), SetOptions(merge: true));
  }

  Stream<List<String>> getHighRiskLocations() {
    return _firestore
        .collection('crowd_metrics')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CrowdMetrics.fromMap(doc.data()))
              .where((metrics) {
                final riskScore = 
                    CrowdStandardizationService.calculateRiskScore(metrics);
                return riskScore > 0.7; // High risk threshold
              })
              .map((metrics) => metrics.locationId)
              .toList();
        });
  }
}
