class Recommendation {
  final String id;
  final String userId;
  final String venueId;
  final double score;
  final String reason;
  final DateTime createdAt;
  final DateTime? expiresAt;

  Recommendation({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.score,
    required this.reason,
    required this.createdAt,
    this.expiresAt,
  });

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['id'],
      userId: map['user_id'],
      venueId: map['venue_id'],
      score: map['score'],
      reason: map['reason'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      expiresAt: map['expires_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expires_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'venue_id': venueId,
      'score': score,
      'reason': reason,
      'created_at': createdAt.millisecondsSinceEpoch,
      'expires_at': expiresAt?.millisecondsSinceEpoch,
    };
  }
}
