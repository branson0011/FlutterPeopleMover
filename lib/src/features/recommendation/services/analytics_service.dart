import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/venue_model.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;
  
  AnalyticsService(this._analytics);
  
  Future<void> logVenueView(Venue venue) async {
    await _analytics.logEvent(
      name: 'venue_view',
      parameters: {
        'venue_id': venue.id,
        'venue_name': venue.name,
        'venue_type': venue.type,
        'rating': venue.rating,
      },
    );
  }
  
  Future<void> logSearchQuery(String query, int resultCount) async {
    await _analytics.logEvent(
      name: 'venue_search',
      parameters: {
        'query': query,
        'result_count': resultCount,
      },
    );
  }
  
  Future<void> logFilterUse(Map<String, dynamic> filters) async {
    await _analytics.logEvent(
      name: 'filter_use',
      parameters: {
        'filters': filters.toString(),
      },
    );
  }
  
  Future<void> logRecommendationClick(Venue venue, double score) async {
    await _analytics.logEvent(
      name: 'recommendation_click',
      parameters: {
        'venue_id': venue.id,
        'venue_name': venue.name,
        'recommendation_score': score,
      },
    );
  }
}
