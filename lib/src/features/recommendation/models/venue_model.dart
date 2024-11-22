import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class Venue {
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
  final Map<String, dynamic>? amenities;
  final Map<String, dynamic>? accessibility;
  final Map<String, dynamic>? reviews;

  const Venue({
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
    this.amenities,
    this.accessibility,
    this.reviews,
  });

  factory Venue.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final GeoPoint geoPoint = data['location'] as GeoPoint;
    
    return Venue(
      id: doc.id,
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
      amenities: data['amenities'],
      accessibility: data['accessibility'],
      reviews: data['reviews'],
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
      'amenities': amenities,
      'accessibility': accessibility,
      'reviews': reviews,
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

  double getDistance(LatLng userLocation) {
    return _calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      location.latitude,
      location.longitude,
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371e3; // Earth's radius in meters
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a = sin(deltaPhi/2) * sin(deltaPhi/2) +
        cos(phi1) * cos(phi2) *
        sin(deltaLambda/2) * sin(deltaLambda/2);
    final c = 2 * atan2(sqrt(a), sqrt(1-a));

    return R * c;
  }
}
