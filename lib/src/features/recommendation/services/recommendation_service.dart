import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recommendation.dart';
import '../../preferences/models/user_preferences.dart';

class RecommendationService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Stream<List<Recommendation>> getRecommendations(
    String userId,
    UserPreferences preferences,
  ) {
    return firebaseFirestore
        .collection('recommendations')
        .where('metadata.tags', arrayContainsAny: preferences.preferences['interests'] ?? [])
        .orderBy('rating', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recommendation.fromMap(doc.data()))
            .toList());
  }

  Future<void> rateRecommendation(String recommendationId, double rating) async {
    await firebaseFirestore.collection('recommendations').doc(recommendationId).update({
      'rating': rating,
      'ratedAt': FieldValue.serverTimestamp(),
    });
  }
}
