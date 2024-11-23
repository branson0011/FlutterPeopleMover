class PreferenceModel {
  final String id;
  final String userId;
  final Map<String, dynamic> preferences;
  final DateTime lastUpdated;
  final bool onboardingComplete;

  PreferenceModel({
    required this.id,
    required this.userId,
    required this.preferences,
    required this.lastUpdated,
    this.onboardingComplete = false,
  });

  factory PreferenceModel.fromMap(Map<String, dynamic> map) {
    return PreferenceModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      lastUpdated: map['lastUpdated']?.toDate() ?? DateTime.now(),
      onboardingComplete: map['onboardingComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'preferences': preferences,
      'lastUpdated': lastUpdated,
      'onboardingComplete': onboardingComplete,
    };
  }

  PreferenceModel copyWith({
    String? id,
    String? userId,
    Map<String, dynamic>? preferences,
    DateTime? lastUpdated,
    bool? onboardingComplete,
  }) {
    return PreferenceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      preferences: preferences ?? this.preferences,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
