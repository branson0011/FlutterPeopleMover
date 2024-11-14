import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';
import '../models/venue_model.dart';

class FirebaseService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // User Operations
  Future<void> createUser(UserModel user) async {
    await firebaseFirestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final documentSnapshot = await firebaseFirestore.collection('users').doc(userId).get();
    return documentSnapshot.exists ? UserModel.fromMap(documentSnapshot.data()!) : null;
  }

  // Venue Operations
  Future<void> createVenue(VenueModel venue) async {
    await firebaseFirestore.collection('venues').doc(venue.id).set(venue.toMap());
  }

  Stream<List<VenueModel>> getNearbyVenues(double latitude, double longitude, double radius) {
    return firebaseFirestore
        .collection('venues')
        .where('location', isLessThanOrEqualTo: radius)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((documentSnapshot) => VenueModel.fromMap(documentSnapshot.data()))
            .toList());
  }

  // Messaging Operations
  Future<String?> getFCMToken() async {
    return await firebaseMessaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
