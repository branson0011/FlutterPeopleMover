class Recommendation {
  final Venue venue;
  final double score;
  final Map<String, double> scoreComponents;
  final double distanceInMeters;
  final List<String> matchingPreferences;
  final Map<String, dynamic> aiSuggestions;

  Recommendation({
    required this.venue,
    required this.score,
    required this.scoreComponents,
    required this.distanceInMeters,
    required this.matchingPreferences,
    this.aiSuggestions,
  });

  // ...rest of the code...
