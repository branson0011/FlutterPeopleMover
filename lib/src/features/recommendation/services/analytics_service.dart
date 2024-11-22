import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recommendation_score.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logRecommendationImpression({
    required String userId,
    required String venueId,
    required RecommendationScore score,
    required Map<String, dynamic> context,
  }) async {
    await _firestore.collection('analytics_impressions').add({
      'userId': userId,
      'venueId': venueId,
      'score': score.toMap(),
      'context': context,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> logUserInteraction({
    required String userId,
    required String venueId,
    required String interactionType,
    required Map<String, dynamic> metadata,
  }) async {
    await _firestore.collection('analytics_interactions').add({
      'userId': userId,
      'venueId': venueId,
      'interactionType': interactionType,
      'metadata': metadata,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> getRecommendationMetrics({
    required String userId,
    required Duration period,
  }) async {
    final cutoff = DateTime.now().subtract(period);
    
    final impressions = await _firestore
        .collection('analytics_impressions')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThan: cutoff)
        .get();

    final interactions = await _firestore
        .collection('analytics_interactions')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThan: cutoff)
        .get();

    return {
      'totalImpressions': impressions.docs.length,
      'totalInteractions': interactions.docs.length,
      'interactionRate': interactions.docs.length / impressions.docs.length,
      'averageScore': _calculateAverageScore(impressions.docs),
      'popularCategories': _getPopularCategories(impressions.docs),
      'interactionTypes': _getInteractionTypes(interactions.docs),
    };
  }

  double _calculateAverageScore(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return 0.0;
    
    final totalScore = docs.fold<double>(
      0.0,
      (sum, doc) => sum + (doc.data() as Map<String, dynamic>)['score']['score'],
    );
    
    return totalScore / docs.length;
  }

  Map<String, int> _getPopularCategories(List<QueryDocumentSnapshot> docs) {
    final categories = <String, int>{};
    
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final venueCategories = List<String>.from(
        data['context']['categories'] ?? [],
      );
      
      for (final category in venueCategories) {
        categories[category] = (categories[category] ?? 0) + 1;
      }
    }
    
    return categories;
  }

  Map<String, int> _getInteractionTypes(List<QueryDocumentSnapshot> docs) {
    final types = <String, int>{};
    
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final type = data['interactionType'] as String;
      types[type] = (types[type] ?? 0) + 1;
    }
    
    return types;
  }
}
