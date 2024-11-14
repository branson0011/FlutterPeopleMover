import 'package:sqflite/sqflite.dart';
import '../models/recommendation.dart';
import 'base_repository.dart';

class RecommendationRepository extends BaseRepository {
  static const String table = 'recommendations';

  Future<int> insertRecommendation(Recommendation recommendation) async {
    return await insert(table, recommendation.toMap());
  }

  Future<List<Recommendation>> getUserRecommendations(
    String userId, {
    int limit = 10,
    int offset = 0,
  }) async {
    final maps = await query(
      table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'score DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => Recommendation.fromMap(map)).toList();
  }

  Future<void> updateRecommendationScore(
    String userId,
    String venueId,
    double newScore,
  ) async {
    await update(
      table,
      {'score': newScore},
      'user_id = ? AND venue_id = ?',
      [userId, venueId],
    );
  }

  Future<void> batchUpdateRecommendations(
    List<Recommendation> recommendations,
  ) async {
    final batch = await database.then((db) => db.batch());
    
    for (var recommendation in recommendations) {
      batch.insert(
        table,
        recommendation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit();
  }

  Future<void> clearOldRecommendations(String userId) async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
    await delete(
      table,
      'user_id = ? AND created_at < ?',
      [userId, cutoffDate.millisecondsSinceEpoch],
    );
  }
}
