import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/preference_settings.dart';

class PreferenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'user_preferences';

  Future<void> savePreferences(String userId, PreferenceSettings preferences) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .set(preferences.toMap(), SetOptions(merge: true));
  }

  Stream<PreferenceSettings> getUserPreferences(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((documentSnapshot) => documentSnapshot.exists 
            ? PreferenceSettings.fromMap(documentSnapshot.data()!)
            : PreferenceSettings());
  }

  Future<void> updatePreference(String userId, String key, dynamic value) async {
    try {
      await _firestore.collection('user_preferences').doc(userId).update({
        'preferences.$key': value,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Update recommendation cache
      await _updateRecommendationCache(userId);
    } catch (e) {
      throw PreferenceException('Failed to update preference: $e');
    }
  }

  Future<void> _updateRecommendationCache(String userId) async {
    final userPreferences = await getUserPreferences(userId).first;
    await _recommendationService.updateRecommendations(
      userId: userId,
      preferences: userPreferences,
    );
  }

  Future<void> addInterest(String userId, String interest) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .update({
          'interests': FieldValue.arrayUnion([interest])
        });
  }

  Future<void> removeInterest(String userId, String interest) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .update({
          'interests': FieldValue.arrayRemove([interest])
        });
  }
}
