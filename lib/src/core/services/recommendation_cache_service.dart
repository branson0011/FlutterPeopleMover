import '../cache/cache_manager.dart';
import '../cache/cache_config.dart';
import '../models/recommendation.dart';
import 'package:shared_preferences.dart';

class RecommendationCacheService {
  final CacheManager<List<Recommendation>> _recommendationCache;
  final CacheConfig _config;
  
  RecommendationCacheService(SharedPreferences prefs)
      : _config = const CacheConfig(
          maxSize: 50,
          maxAge: Duration(hours: 1),
          persistToDisk: true,
          cacheKey: 'user_recommendations',
          enableCompression: true,
        ),
        _recommendationCache = CacheManager<List<Recommendation>>(
          config: _config,
          prefs: prefs,
          fromJson: (json) => (json['recommendations'] as List)
              .map((r) => Recommendation.fromMap(r))
              .toList(),
          toJson: (recommendations) => {
            'recommendations': recommendations.map((r) => r.toMap()).toList(),
          },
        );

  // ...rest of the code...
}
