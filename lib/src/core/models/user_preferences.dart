class UserPreferences {
  final String userId;
  final Map<String, dynamic> preferences;
  final DateTime updatedAt;

  UserPreferences({
    required this.userId,
    required this.preferences,
    required this.updatedAt,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['user_id'],
      preferences: Map<String, dynamic>.from(map['preferences']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'preferences': preferences,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  UserPreferences copyWith({
    Map<String, dynamic>? preferences,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      userId: userId,
      preferences: preferences ?? this.preferences,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
