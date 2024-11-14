class UserInteraction {
  final String id;
  final String userId;
  final String venueId;
  final String interactionType;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  UserInteraction({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.interactionType,
    required this.timestamp,
    this.data,
  });

  factory UserInteraction.fromMap(Map<String, dynamic> map) {
    return UserInteraction(
      id: map['id'],
      userId: map['user_id'],
      venueId: map['venue_id'],
      interactionType: map['interaction_type'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'venue_id': venueId,
      'interaction_type': interactionType,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'data': data,
    };
  }
}
