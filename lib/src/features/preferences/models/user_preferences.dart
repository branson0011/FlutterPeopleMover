class UserPreferences {
  final String userId;
  final Map<String, dynamic> preferences;
  final DateTime lastUpdated;
  final bool onboardingComplete;

  UserPreferences({
    required this.userId,
    required this.preferences,
    required this.lastUpdated,
    this.onboardingComplete = false,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['userId'] ?? '',
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      lastUpdated: map['lastUpdated']?.toDate() ?? DateTime.now(),
      onboardingComplete: map['onboardingComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'preferences': preferences,
      'lastUpdated': lastUpdated,
      'onboardingComplete': onboardingComplete,
    };
  }

  UserPreferences copyWith({
    Map<String, dynamic>? preferences,
    bool? onboardingComplete,
  }) {
    return UserPreferences(
      userId: userId,
      preferences: preferences ?? this.preferences,
      lastUpdated: DateTime.now(),
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
