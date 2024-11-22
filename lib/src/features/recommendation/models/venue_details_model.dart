import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VenueDetails {
  final String id;
  final String name;
  final String type;
  final LatLng location;
  final String address;
  final double rating;
  final double googleRating;
  final int priceLevel;
  final Map<String, dynamic> crowdData;
  final List<String> tags;
  final Map<String, dynamic> operatingHours;
  final String? photoUrl;
  final List<String>? photos;
  final Map<String, dynamic>? amenities;
  final Map<String, dynamic>? accessibility;
  final List<VenueReview>? reviews;
  final Map<String, dynamic>? popularTimes;
  final bool isVerified;
  final DateTime? lastUpdated;

  const VenueDetails({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.address,
    required this.rating,
    required this.googleRating,
    required this.priceLevel,
    required this.crowdData,
    required this.tags,
    required this.operatingHours,
    this.photoUrl,
    this.photos,
    this.amenities,
    this.accessibility,
    this.reviews,
    this.popularTimes,
    this.isVerified = false,
    this.lastUpdated,
  });

  factory VenueDetails.fromFirestore(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;
    final GeoPoint geoPoint = data['location'] as GeoPoint;
    
    return VenueDetails(
      id: documentSnapshot.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      address: data['address'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      googleRating: (data['googleRating'] ?? 0.0).toDouble(),
      priceLevel: data['priceLevel'] ?? 1,
      crowdData: Map<String, dynamic>.from(data['crowdData'] ?? {}),
      tags: List<String>.from(data['tags'] ?? []),
      operatingHours: Map<String, dynamic>.from(data['operatingHours'] ?? {}),
      photoUrl: data['photoUrl'],
      photos: data['photos'] != null ? List<String>.from(data['photos']) : null,
      amenities: data['amenities'],
      accessibility: data['accessibility'],
      reviews: data['reviews'] != null 
        ? (data['reviews'] as List).map((review) => VenueReview.fromMap(review)).toList()
        : null,
      popularTimes: data['popularTimes'],
      isVerified: data['isVerified'] ?? false,
      lastUpdated: data['lastUpdated']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'location': GeoPoint(location.latitude, location.longitude),
      'address': address,
      'rating': rating,
      'googleRating': googleRating,
      'priceLevel': priceLevel,
      'crowdData': crowdData,
      'tags': tags,
      'operatingHours': operatingHours,
      'photoUrl': photoUrl,
      'photos': photos,
      'amenities': amenities,
      'accessibility': accessibility,
      'reviews': reviews?.map((review) => review.toMap()).toList(),
      'popularTimes': popularTimes,
      'isVerified': isVerified,
      'lastUpdated': lastUpdated,
    };
  }

  bool isOpenNow() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday.toString();
    
    if (!operatingHours.containsKey(dayOfWeek)) return false;
    
    final hours = operatingHours[dayOfWeek];
    if (hours == null) return false;
    
    final openTime = _parseTime(hours['open']);
    final closeTime = _parseTime(hours['close']);
    
    final currentTime = now.hour * 60 + now.minute;
    return currentTime >= openTime && currentTime <= closeTime;
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String getCurrentCrowdLevel() {
    return crowdData['current'] ?? 'unknown';
  }

  bool hasAmenity(String amenity) {
    return amenities?[amenity] == true;
  }

  bool isAccessible(String feature) {
    return accessibility?[feature] == true;
  }

  double getAverageRating() {
    return (rating + googleRating) / 2;
  }
}

class VenueReview {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String text;
  final DateTime timestamp;
  final List<String>? photos;
  final Map<String, dynamic>? metrics;

  VenueReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.text,
    required this.timestamp,
    this.photos,
    this.metrics,
  });

  factory VenueReview.fromMap(Map<String, dynamic> map) {
    return VenueReview(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      rating: map['rating'].toDouble(),
      text: map['text'],
      timestamp: map['timestamp'].toDate(),
      photos: map['photos'] != null ? List<String>.from(map['photos']) : null,
      metrics: map['metrics'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'text': text,
      'timestamp': timestamp,
      'photos': photos,
      'metrics': metrics,
    };
  }
}
