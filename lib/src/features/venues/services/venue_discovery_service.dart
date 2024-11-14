import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import '../models/venue_model.dart';

class VenueDiscoveryService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final GeoFlutterFire geoFlutterFire = GeoFlutterFire();

  // Get nearby venues with intelligent filtering
  Stream<List<VenueModel>> getNearbyVenues({
    required double latitude,
    required double longitude,
    required double radius,
    Map<String, dynamic>? filters,
    String? searchQuery,
  }) {
    // Create a geoFirePoint
    final center = geoFlutterFire.point(latitude: latitude, longitude: longitude);

    // Build base query
    var collectionReference = firebaseFirestore.collection('venues');
    
    // Apply filters if provided
    if (filters != null) {
      collectionReference = _applyFilters(collectionReference, filters);
    }

    // Create the geoFireQuery
    return geoFlutterFire.collection(collectionRef: collectionReference)
        .within(
          center: center,
          radius: radius,
          field: 'location',
          strictMode: true,
        )
        .map((list) => list
            .map((documentSnapshot) => VenueModel.fromMap(documentSnapshot.data() as Map<String, dynamic>))
            .toList());
  }

  // Get personalized venue recommendations
  Future<List<VenueModel>> getPersonalizedRecommendations({
    required String userId,
    required Map<String, dynamic> preferences,
    required GeoPoint location,
  }) async {
    // Implement machine learning-based recommendation logic here
    // This is a placeholder implementation
    final snapshot = await firebaseFirestore
        .collection('venues')
        .where('tags', arrayContainsAny: preferences['interests'])
        .limit(10)
        .get();

    return snapshot.docs
        .map((documentSnapshot) => VenueModel.fromMap(documentSnapshot.data()))
        .toList();
  }

  // Get trending venues
  Future<List<VenueModel>> getTrendingVenues({
    required GeoPoint location,
    double radius = 5.0, // kilometers
  }) async {
    final snapshot = await firebaseFirestore
        .collection('venues')
        .orderBy('crowdData.currentCount', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((documentSnapshot) => VenueModel.fromMap(documentSnapshot.data()))
        .toList();
  }

  // Private helper methods
  Query _applyFilters(Query query, Map<String, dynamic> filters) {
    if (filters['type'] != null) {
      query = query.where('type', isEqualTo: filters['type']);
    }
    if (filters['rating'] != null) {
      query = query.where('rating', isGreaterThanOrEqualTo: filters['rating']);
    }
    if (filters['priceRange'] != null) {
      query = query.where('details.priceRange', isEqualTo: filters['priceRange']);
    }
    if (filters['tags'] != null) {
      query = query.where('tags', arrayContainsAny: filters['tags']);
    }
    return query;
  }
}
