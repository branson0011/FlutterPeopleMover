import 'package:sqflite/sqflite.dart';
import '../models/venue.dart';
import 'base_repository.dart';

class VenueRepository extends BaseRepository {
  static const String table = 'venues';

  Future<int> insertVenue(Venue venue) async {
    return await insert(table, venue.toMap());
  }

  Future<List<Venue>> getNearbyVenues(
    double latitude,
    double longitude,
    double radiusKilometers, {
    int limit = 20,
  }) async {
    // Using Haversine formula in SQLite
    final sql = '''
      SELECT *, (
        6371 * acos(
          cos(radians(?)) * 
          cos(radians(latitude)) * 
          cos(radians(longitude) - radians(?)) + 
          sin(radians(?)) * 
          sin(radians(latitude))
        )
      ) AS distance
      FROM $table
      HAVING distance <= ?
      ORDER BY distance
      LIMIT ?
    ''';

    final results = await rawQuery(
      sql,
      [latitude, longitude, latitude, radiusKilometers, limit],
    );

    return results.map((map) => Venue.fromMap(map)).toList();
  }

  Future<List<Venue>> searchVenues(String query) async {
    final results = await this.query(
      table,
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return results.map((map) => Venue.fromMap(map)).toList();
  }

  Future<List<Venue>> getVenuesByCategory(String categoryId) async {
    final sql = '''
      SELECT v.* 
      FROM $table v
      INNER JOIN venue_categories vc ON v.id = vc.venue_id
      WHERE vc.category_id = ?
    ''';

    final results = await rawQuery(sql, [categoryId]);
    return results.map((map) => Venue.fromMap(map)).toList();
  }

  Future<void> updateVenue(Venue venue) async {
    await update(
      table,
      venue.toMap(),
      'id = ?',
      [venue.id],
    );
  }

  Future<void> deleteVenue(String id) async {
    await delete(table, 'id = ?', [id]);
  }

  Future<List<Venue>> getPopularVenues({int limit = 10}) async {
    final sql = '''
      SELECT v.*, COUNT(ui.id) as interaction_count
      FROM $table v
      LEFT JOIN user_interactions ui ON v.id = ui.venue_id
      GROUP BY v.id
      ORDER BY interaction_count DESC
      LIMIT ?
    ''';

    final results = await rawQuery(sql, [limit]);
    return results.map((map) => Venue.fromMap(map)).toList();
  }
}
