import 'package:sqflite/sqflite.dart';
import '../models/recommendation.dart';
import 'base_repository.dart';

class RecommendationRepository extends BaseRepository {
  static const String table = 'recommendations';

  Future<void> saveRecommendations(List<Recommendation> recommendations) async {
    final batch = await database.then((database) => database.batch());
    
    for (var recommendation in recommendations) {
      batch.insert(
        table,
        recommendation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit();
  }

  Future<List<Recommendation>> getUserRecommendations(
    String userId, {
    int limit = 20,
    double? minimumScore,
  }) async {
    String whereClause = 'user_id = ?';
    List<dynamic> whereArguments = [userId];

    if (minimumScore != null) {
      whereClause += ' AND score >= ?';
      whereArguments.add(minimumScore);
    }

    final results = await query(
      table,
      where: whereClause,
      whereArgs: whereArguments,
      orderBy: 'score DESC',
      limit: limit,
    );

    return results.map((map) => Recommendation.fromMap(map)).toList();
  }

  Future<void> updateRecommendationScore(
    String recommendationId,
    double newScore,
  ) async {
    await update(
      table,
      {'score': newScore},
      'id = ?',
      [recommendationId],
    );
  }

  Future<void> deleteExpiredRecommendations() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await delete(
      table,
      'expires_at < ?',
      [now],
    );
  }

  Future<void> clearUserRecommendations(String userId) async {
    await delete(
      table,
      'user_id = ?',
      [userId],
    );
  }
}
