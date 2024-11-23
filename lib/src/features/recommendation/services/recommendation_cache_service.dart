import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recommendation.dart';
import '../../preferences/models/user_preferences.dart';
import 'package:shared_preferences.dart';

class RecommendationCacheService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs;
  static const String CACHE_EXPIRY_KEY = 'recommendation_cache_expiry';
  static const Duration CACHE_DURATION = Duration(hours: 24);

  RecommendationCacheService(this._prefs);

  Future<void> cacheRecommendations(
    String userId,
    List<Recommendation> recommendations,
  ) async {
    final batch = _firestore.batch();
    final cacheRef = _firestore.collection('recommendation_cache').doc(userId);
    
    // Store cache expiry time
    final expiryTime = DateTime.now().add(CACHE_DURATION);
    await _prefs.setString(
      '${CACHE_EXPIRY_KEY}_$userId',
      expiryTime.toIso8601String(),
    );

    batch.set(cacheRef, {
      'recommendations': recommendations.map((recommendation) => recommendation.toMap()).toList(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'expiresAt': expiryTime,
    });
    
    await batch.commit();
  }

  Future<bool> isCacheValid(String userId) async {
    final expiryTimeStr = _prefs.getString('${CACHE_EXPIRY_KEY}_$userId');
    if (expiryTimeStr == null) return false;

    final expiryTime = DateTime.parse(expiryTimeStr);
    return DateTime.now().isBefore(expiryTime);
  }

  Future<List<Recommendation>> getCachedRecommendations(String userId) async {
    final cacheDocument = await _firestore
        .collection('recommendation_cache')
        .doc(userId)
        .get();
        
    if (!cacheDocument.exists) return [];
    
    final data = cacheDocument.data()!;
    final List<dynamic> recommendationsData = data['recommendations'] ?? [];
    
    return recommendationsData
        .map((data) => Recommendation.fromMap(data))
        .toList();
  }
  
  Future<void> invalidateCache(String userId) async {
    await _firestore
        .collection('recommendation_cache')
        .doc(userId)
        .delete();
  }
  
  Stream<List<Recommendation>> watchCachedRecommendations(String userId) {
    return _firestore
        .collection('recommendation_cache')
        .doc(userId)
        .snapshots()
        .map((document) {
          if (!document.exists) return [];
          
          final data = document.data()!;
          final List<dynamic> recommendationsData = data['recommendations'] ?? [];
          
          return recommendationsData
              .map((data) => Recommendation.fromMap(data))
              .toList();
        });
  }
}
