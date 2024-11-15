import 'package:collection/collection.dart';
import '../database/repositories/recommendation_repository.dart';
import '../database/repositories/venue_repository.dart';
import '../database/repositories/interaction_repository.dart';
import '../models/recommendation.dart';
import '../models/venue.dart';
import '../models/user_interaction.dart';
import 'dart:math';

class RecommendationService {
  final RecommendationRepository _recommendationRepository;
  final VenueRepository _venueRepository;
  final InteractionRepository _interactionRepository;

  RecommendationService({
    required RecommendationRepository recommendationRepository,
    required VenueRepository venueRepository,
    required InteractionRepository interactionRepository,
  })  : _recommendationRepository = recommendationRepository,
        _venueRepository = venueRepository,
        _interactionRepository = interactionRepository;

  Future<List<Venue>> getRecommendations(
    String userId,
    double latitude,
    double longitude, {
    int limit = 10,
    double radiusKilometers = 5.0,
  }) async {
    // Get nearby venues
    final nearbyVenues = await _venueRepository.getNearbyVenues(
      latitude,
      longitude,
      radiusKilometers,
      limit: limit * 2, // Get more venues than needed for better filtering
    );

    // Get user interactions
    final interactions = await _interactionRepository.getUserInteractions(userId);
    
    // Calculate scores for each venue
    final scoredVenues = await Future.wait(
      nearbyVenues.map((venue) async {
        final score = await _calculateVenueScore(
          venue,
          userId,
          interactions,
          latitude,
          longitude,
        );
        return MapEntry(venue, score);
      }),
    );

    // Sort by score and take top venues
    final sortedVenues = scoredVenues
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Save recommendations
    await _saveRecommendations(
      userId,
      sortedVenues.take(limit).toList(),
    );

    return sortedVenues
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  Future<double> _calculateVenueScore(
    Venue venue,
    String userId,
    List<UserInteraction> interactions,
    double userLatitude,
    double userLongitude,
  ) async {
    double score = 0.0;

    // Distance score (closer venues get higher scores)
    final distance = _calculateDistance(
      userLatitude,
      userLongitude,
      venue.latitude,
      venue.longitude,
    );
    score += _calculateDistanceScore(distance);

    // Rating score
    if (venue.rating != null) {
      score += venue.rating! * 0.3; // 30% weight for ratings
    }

    // Interaction score
    final venueInteractions = interactions
        .where((interaction) => interaction.venueId == venue.id)
        .toList();
    score += _calculateInteractionScore(venueInteractions);

    // Category preference score
    score += await _calculateCategoryScore(userId, venue.categoryIds);

    return score;
  }

  double _calculateDistance(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    // Haversine formula implementation
    const radius = 6371.0; // Earth's radius in km
    final deltaLatitude = _toRadians(latitude2 - latitude1);
    final deltaLongitude = _toRadians(longitude2 - longitude1);
    final a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
        cos(_toRadians(latitude1)) *
            cos(_toRadians(latitude2)) *
            sin(deltaLongitude / 2) *
            sin(deltaLongitude / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  double _calculateDistanceScore(double distance) {
    // Convert distance to a score between 0 and 1
    // Closer venues get higher scores
    const maxDistance = 5.0; // 5km
    return max(0, 1 - (distance / maxDistance));
  }

  double _calculateInteractionScore(List<UserInteraction> interactions) {
    if (interactions.isEmpty) return 0;

    double score = 0;
    for (var interaction in interactions) {
      switch (interaction.interactionType) {
        case 'view':
          score += 0.1;
          break;
        case 'like':
          score += 0.3;
          break;
        case 'visit':
          score += 0.5;
          break;
      }
    }

    return min(score, 1.0); // Cap at 1.0
  }

  Future<double> _calculateCategoryScore(
    String userId,
    List<String> categoryIds,
  ) async {
    // Implementation would depend on how you store user preferences
    // This is a placeholder that returns a random score
    return 0.5;
  }

  Future<void> _saveRecommendations(
    String userId,
    List<MapEntry<Venue, double>> scoredVenues,
  ) async {
    final recommendations = scoredVenues.map((entry) {
      return Recommendation(
        id: '${userId}_${entry.key.id}',
        userId: userId,
        venueId: entry.key.id,
        score: entry.value,
        reason: _generateRecommendationReason(entry.value),
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
    }).toList();

    await _recommendationRepository.saveRecommendations(recommendations);
  }

  String _generateRecommendationReason(double score) {
    if (score > 0.8) {
      return 'Highly recommended based on your preferences';
    } else if (score > 0.6) {
      return 'Recommended based on location and ratings';
    } else {
      return 'You might be interested in this venue';
    }
  }
}
