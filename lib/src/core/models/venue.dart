class Venue {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? priceLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> categoryIds;

  Venue({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.priceLevel,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryIds,
  });

  factory Venue.fromMap(Map<String, dynamic> map) {
    return Venue(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      rating: map['rating'],
      priceLevel: map['price_level'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      categoryIds: List<String>.from(map['category_ids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'price_level': priceLevel,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
