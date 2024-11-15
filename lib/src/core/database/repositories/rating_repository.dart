import 'package:sqflite/sqflite.dart';
import '../models/rating.dart';
import 'base_repository.dart';

class RatingRepository extends BaseRepository {
  static const String table = 'venue_ratings';

  Future<void> addRating({
    required String userId,
    required String venueId,
    required double rating,
    String? comment,
  }) async {
    final ratingData = {
      'user_id': userId,
      'venue_id': venueId,
      'rating': rating,
      'comment': comment,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };

    await insert(
      table,
      ratingData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Rating>> getVenueRatings(String venueId) async {
    final results = await query(
      table,
      where: 'venue_id = ?',
      whereArgs: [venueId],
      orderBy: 'created_at DESC',
    );

    return results.map((map) => Rating.fromMap(map)).toList();
  }

  Future<double> getAverageRating(String venueId) async {
    final result = await rawQuery('''
      SELECT AVG(rating) as average_rating
      FROM $table
      WHERE venue_id = ?
    ''', [venueId]);

    return result.first['average_rating'] as double? ?? 0.0;
  }

  Future<Map<String, int>> getRatingDistribution(String venueId) async {
    final results = await rawQuery('''
      SELECT rating, COUNT(*) as count
      FROM $table
      WHERE venue_id = ?
      GROUP BY rating
    ''', [venueId]);

    return Map.fromEntries(
      results.map((row) => MapEntry(
        row['rating'].toString(),
        row['count'] as int,
      )),
    );
  }

  Future<void> updateRating({
    required String userId,
    required String venueId,
    required double rating,
    String? comment,
  }) async {
    final ratingData = {
      'rating': rating,
      'comment': comment,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };

    await update(
      table,
      ratingData,
      'user_id = ? AND venue_id = ?',
      [userId, venueId],
    );
  }

  Future<void> deleteRating({
    required String userId,
    required String venueId,
  }) async {
    await delete(
      table,
      'user_id = ? AND venue_id = ?',
      [userId, venueId],
    );
  }
}
