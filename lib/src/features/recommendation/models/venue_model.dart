class VenueModel {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> categories;
  final Map<String, dynamic> attributes;
  final double rating;
  final int reviewCount;
  final DateTime lastUpdated;

  VenueModel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.categories,
    required this.attributes,
    required this.rating,
    required this.reviewCount,
    required this.lastUpdated,
  });

  factory VenueModel.fromMap(Map<String, dynamic> map) {
    return VenueModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      categories: List<String>.from(map['categories']),
      attributes: Map<String, dynamic>.from(map['attributes']),
      rating: map['rating'],
      reviewCount: map['reviewCount'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'categories': categories,
      'attributes': attributes,
      'rating': rating,
      'reviewCount': reviewCount,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
