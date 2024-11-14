import 'package:cloud_firestore/cloud_firestore.dart';

class VenueModel {
  final String id;
  final String name;
  final String description;
  final GeoPoint location;
  final String type;
  final Map<String, dynamic> details;
  final Map<String, dynamic> operatingHours;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic> crowdData;
  final List<String> tags;
  final Map<String, dynamic> amenities;
  final DateTime lastUpdated;

  VenueModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.type,
    required this.details,
    required this.operatingHours,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.crowdData,
    required this.tags,
    required this.amenities,
    required this.lastUpdated,
  });

  factory VenueModel.fromMap(Map<String, dynamic> map) {
    return VenueModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      location: map['location'],
      type: map['type'],
      details: Map<String, dynamic>.from(map['details']),
      operatingHours: Map<String, dynamic>.from(map['operatingHours']),
      rating: map['rating']?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] ?? 0,
      crowdData: Map<String, dynamic>.from(map['crowdData']),
      tags: List<String>.from(map['tags']),
      amenities: Map<String, dynamic>.from(map['amenities']),
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'type': type,
      'details': details,
      'operatingHours': operatingHours,
      'rating': rating,
      'reviewCount': reviewCount,
      'crowdData': crowdData,
      'tags': tags,
      'amenities': amenities,
      'lastUpdated': lastUpdated,
    };
  }
}
