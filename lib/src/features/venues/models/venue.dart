import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../places/models/place.dart';
import '../../crowd/models/crowd_metrics.dart';
import '../../crowd/models/crowd_level_standard.dart';

class Venue {
  final String id;
  final String name;
  final LatLng location;
  final String? address;
  final double? rating;
  CrowdMetrics? crowdMetrics;
  CrowdDensity? crowdDensity;
  Map<String, dynamic>? metadata;

  Venue({
    required this.id,
    required this.name,
    required this.location,
    this.address,
    this.rating,
    this.crowdMetrics,
    this.crowdDensity,
    this.metadata,
  });

  factory Venue.fromPlace(Place place) {
    return Venue(
      id: place.id,
      name: place.name,
      location: place.location,
      address: place.address,
      rating: place.rating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': {
        'lat': location.latitude,
        'lng': location.longitude,
      },
      'address': address,
      'rating': rating,
      'crowdMetrics': crowdMetrics?.toMap(),
      'crowdDensity': crowdDensity?.toString(),
      'metadata': metadata,
    };
  }
}
