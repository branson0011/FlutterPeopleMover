import 'package:sqflite/sqflite.dart';
import '../models/interaction.dart';
import 'base_repository.dart';

class InteractionRepository extends BaseRepository {
  static const String table = 'user_interactions';

  Future<int> insertInteraction(UserInteraction interaction) async {
    return await insert(table, interaction.toMap());
  }

  Future<List<UserInteraction>> getUserInteractions(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final results = await query(
      table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
    return results.map((map) => UserInteraction.fromMap(map)).toList();
  }

  Future<List<UserInteraction>> getVenueInteractions(
    String venueId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final results = await query(
      table,
      where: 'venue_id = ?',
      whereArgs: [venueId],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
    return results.map((map) => UserInteraction.fromMap(map)).toList();
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

  Future<void> deleteInteraction(String id) async {
    await delete(table, 'id = ?', [id]);
  }

  Future<void> deleteUserInteractions(String userId) async {
    await delete(table, 'user_id = ?', [userId]);
  }
}
