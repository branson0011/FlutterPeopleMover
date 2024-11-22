class UserPreference {
  final String userId;
  final Map<String, double> categoryWeights;
  final Map<String, List<String>> explicitPreferences;
  final Map<String, double> implicitPreferences;
  final DateTime lastUpdated;

  UserPreference({
    required this.userId,
    required this.categoryWeights,
    required this.explicitPreferences,
    required this.implicitPreferences,
    required this.lastUpdated,
  });

  factory UserPreference.fromMap(Map<String, dynamic> map) {
    return UserPreference(
      userId: map['userId'],
      categoryWeights: Map<String, double>.from(map['categoryWeights']),
      explicitPreferences: Map<String, List<String>>.from(
        map['explicitPreferences'].map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      implicitPreferences: Map<String, double>.from(map['implicitPreferences']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoryWeights': categoryWeights,
      'explicitPreferences': explicitPreferences,
      'implicitPreferences': implicitPreferences,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  UserPreference copyWith({
    Map<String, double>? categoryWeights,
    Map<String, List<String>>? explicitPreferences,
    Map<String, double>? implicitPreferences,
  }) {
    return UserPreference(
      userId: userId,
      categoryWeights: categoryWeights ?? this.categoryWeights,
      explicitPreferences: explicitPreferences ?? this.explicitPreferences,
      implicitPreferences: implicitPreferences ?? this.implicitPreferences,
      lastUpdated: DateTime.now(),
    );
  }
}
