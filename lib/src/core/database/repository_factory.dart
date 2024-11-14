import 'repositories/venue_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/interaction_repository.dart';
import 'repositories/recommendation_repository.dart';
import 'cache/cache_manager.dart';

class RepositoryFactory {
  static final RepositoryFactory _instance = RepositoryFactory._internal();
  factory RepositoryFactory() => _instance;
  RepositoryFactory._internal();

  final CacheManager<Venue> _venues = CacheManager<Venue>();
  final CacheManager<Category> _categories = CacheManager<Category>();
  final CacheManager<Recommendation> _recommendations = CacheManager<Recommendation>();

  late final VenueRepository venueRepository;
  late final CategoryRepository categoryRepository;
  late final InteractionRepository interactionRepository;
  late final RecommendationRepository recommendationRepository;

  void initialize() {
    venueRepository = VenueRepository(_venues);
    categoryRepository = CategoryRepository(_categories);
    interactionRepository = InteractionRepository();
    recommendationRepository = RecommendationRepository(_recommendations);
  }

  void clearCache() {
    _venues.clear();
    _categories.clear();
    _recommendations.clear();
  }
}
