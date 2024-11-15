import 'package:sqflite/sqflite.dart';
import '../cache/cache_manager.dart';
import 'base_repository.dart';

class InteractionTrackingRepository extends BaseRepository {
  static const String table = 'user_interactions';
  final CacheManager<Map<String, dynamic>> _cache;

  InteractionTrackingRepository()
      : _cache = CacheManager<Map<String, dynamic>>(
          maxSize: 1000,
          maxAge: const Duration(minutes: 60),
        );

  Future<void> trackInteraction({
    required String userId,
    required String venueId,
    required String interactionType,
    Map<String, dynamic>? metadata,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final interaction = {
      'user_id': userId,
      'venue_id': venueId,
      'interaction_type': interactionType,
      'timestamp': timestamp,
      'metadata': metadata,
    };

    // Cache the interaction
    _cache.set('$userId:$venueId:$timestamp', interaction);

    // Store in database
    await insert(table, interaction);
  }

  Future<List<Map<String, dynamic>>> getUserInteractions(
    String userId, {
    int limit = 50,
    String? interactionType,
  }) async {
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (interactionType != null) {
      whereClause += ' AND interaction_type = ?';
      whereArgs.add(interactionType);
    }

    return await query(
      table,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  Future<Map<String, int>> getInteractionCounts(String venueId) async {
    final results = await rawQuery('''
      SELECT interaction_type, COUNT(*) as count
      FROM $table
      WHERE venue_id = ?
      GROUP BY interaction_type
    ''', [venueId]);

    return Map.fromEntries(
      results.map((row) => MapEntry(
        row['interaction_type'] as String,
        row['count'] as int,
      )),
    );
  }

  Future<void> pruneOldInteractions(Duration age) async {
    final cutoff = DateTime.now().subtract(age).millisecondsSinceEpoch;
    await delete(table, 'timestamp < ?', [cutoff]);
  }
}
