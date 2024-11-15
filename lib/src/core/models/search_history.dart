class SearchHistory {
  final String userId;
  final String query;
  final String? category;
  final Map<String, dynamic>? filters;
  final DateTime timestamp;

  SearchHistory({
    required this.userId,
    required this.query,
    this.category,
    this.filters,
    required this.timestamp,
  });

  factory SearchHistory.fromMap(Map<String, dynamic> map) {
    return SearchHistory(
      userId: map['user_id'],
      query: map['query'],
      category: map['category'],
      filters: map['filters'] != null ? _decodeFilters(map['filters']) : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'query': query,
      'category': category,
      'filters': filters != null ? filters.toString() : null,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic>? _decodeFilters(String encodedFilters) {
    // Implement proper decoding logic based on your encoding method
    return null;
  }
}
