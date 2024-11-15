class Rating {
  final String id;
  final String userId;
  final String venueId;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Rating({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'],
      userId: map['user_id'],
      venueId: map['venue_id'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'venue_id': venueId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  Rating copyWith({
    double? rating,
    String? comment,
  }) {
    return Rating(
      id: id,
      userId: userId,
      venueId: venueId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
