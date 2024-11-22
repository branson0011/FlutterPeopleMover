import 'venue_details_model.dart';

class RecommendationResult {
  final VenueDetails venue;
  final double score;
  final Map<String, double> scoreComponents;
  final List<String> matchingPreferences;
  final double distance;
  final Map<String, dynamic>? aiInsights;
  final String? specialOffer;

  RecommendationResult({
    required this.venue,
    required this.score,
    required this.scoreComponents,
    required this.matchingPreferences,
    required this.distance,
    this.aiInsights,
    this.specialOffer,
  });

  factory RecommendationResult.fromMap(Map<String, dynamic> map) {
    return RecommendationResult(
      venue: VenueDetails.fromFirestore(map['venue']),
      score: map['score'].toDouble(),
      scoreComponents: Map<String, double>.from(map['scoreComponents']),
      matchingPreferences: List<String>.from(map['matchingPreferences']),
      distance: map['distance'].toDouble(),
      aiInsights: map['aiInsights'],
      specialOffer: map['specialOffer'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'venue': venue.toMap(),
      'score': score,
      'scoreComponents': scoreComponents,
      'matchingPreferences': matchingPreferences,
      'distance': distance,
      'aiInsights': aiInsights,
      'specialOffer': specialOffer,
    };
  }

  String getMainReason() {
    var maxComponent = scoreComponents.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    switch (maxComponent.key) {
      case 'rating':
        return 'Highly rated venue';
      case 'distance':
        return 'Conveniently located';
      case 'preferences':
        return 'Matches your preferences';
      case 'popularity':
        return 'Popular venue';
      case 'crowdLevel':
        return 'Optimal crowd level';
      default:
        return 'Recommended for you';
    }
  }

  List<String> getMatchingTags() {
    return venue.tags.where((tag) => matchingPreferences.contains(tag)).toList();
  }

  bool isHighlyRecommended() {
    return score >= 0.8;
  }
}
