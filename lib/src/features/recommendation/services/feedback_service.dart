import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recommendation_score.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitFeedback({
    required String userId,
    required String venueId,
    required double rating,
    required String feedback,
    Map<String, dynamic>? metadata,
  }) async {
    await _firestore.collection('recommendation_feedback').add({
      'userId': userId,
      'venueId': venueId,
      'rating': rating,
      'feedback': feedback,
      'metadata': metadata,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update venue rating in the machine learning model
    await _updateVenueRating(venueId, rating);
  }

  Future<void> _updateVenueRating(String venueId, double rating) async {
    final venueReference = _firestore.collection('venues').doc(venueId);
    
    await _firestore.runTransaction((transaction) async {
      final venue = await transaction.get(venueReference);
      
      if (venue.exists) {
        final currentRating = venue.data()?['rating'] ?? 0.0;
        final reviewCount = venue.data()?['reviewCount'] ?? 0;
        
        final newRating = ((currentRating * reviewCount) + rating) / (reviewCount + 1);
        
        transaction.update(venueReference, {
          'rating': newRating,
          'reviewCount': reviewCount + 1,
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> getFeedbackHistory(String userId) async {
    final snapshot = await _firestore
        .collection('recommendation_feedback')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((document) => document.data())
        .toList();
  }

  Stream<QuerySnapshot> getFeedbackStream(String venueId) {
    return _firestore
        .collection('recommendation_feedback')
        .where('venueId', isEqualTo: venueId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
