class RecommendationScore {
  final String itemId;
  final double score;
  final Map<String, double> factors;
  final DateTime timestamp;

  RecommendationScore({
    required this.itemId,
    required this.score,
    required this.factors,
    required this.timestamp,
  });

  factory RecommendationScore.fromMap(Map<String, dynamic> map) {
    return RecommendationScore(
      itemId: map['itemId'],
      score: map['score'].toDouble(),
      factors: Map<String, double>.from(map['factors']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'score': score,
      'factors': factors,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
