import 'package:sqflite/sqflite.dart';
import '../models/interaction.dart';
import 'base_repository.dart';

class InteractionRepository extends BaseRepository {
  static const String table = 'user_interactions';

  Future<int> insertInteraction(UserInteraction interaction) async {
    return await insert(table, interaction.toMap());
  }

  Future<List<UserInteraction>> getUserInteractions(String userId) async {
    final maps = await query(
      table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => UserInteraction.fromMap(map)).toList();
  }

  Future<List<UserInteraction>> getVenueInteractions(String venueId) async {
    final maps = await query(
      table,
      where: 'venue_id = ?',
      whereArgs: [venueId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => UserInteraction.fromMap(map)).toList();
  }

  Future<Map<String, int>> getInteractionCounts(String venueId) async {
    final sql = '''
      SELECT interaction_type, COUNT(*) as count
      FROM $table
      WHERE venue_id = ?
      GROUP BY interaction_type
    ''';

    final results = await rawQuery(sql, [venueId]);
    return Map.fromEntries(
      results.map((row) => MapEntry(
        row['interaction_type'] as String,
        row['count'] as int,
      )),
    );
  }

  Future<List<String>> getMostInteractedVenues(String userId, {int limit = 10}) async {
    final sql = '''
      SELECT venue_id, COUNT(*) as count
      FROM $table
      WHERE user_id = ?
      GROUP BY venue_id
      ORDER BY count DESC
      LIMIT ?
    ''';

    final results = await rawQuery(sql, [userId, limit]);
    return results.map((row) => row['venue_id'] as String).toList();
  }

  Future<void> deleteInteraction(String id) async {
    await delete(table, 'id = ?', [id]);
  }
}
