class Recommendation {
  final String id;
  final String title;
  final String description;
  final double rating;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.metadata,
    required this.createdAt,
  });

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      rating: map['rating']?.toDouble() ?? 0.0,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rating': rating,
      'metadata': metadata,
      'createdAt': createdAt,
    };
  }
}
