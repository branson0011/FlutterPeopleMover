import '../models/venue.dart';
import 'base_repository.dart';

class VenueRepository extends BaseRepository {
  static const String table = 'venues';

  Future<int> insertVenue(Venue venue) async {
    return await insert(table, venue.toMap());
  }

  Future<Venue?> getVenue(String id) async {
    final maps = await query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Venue.fromMap(maps.first);
  }

  Future<List<Venue>> getNearbyVenues(
    double latitude,
    double longitude,
    double radiusKilometers,
  ) async {
    // Using Haversine formula in SQL
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
    ''';

    final results = await rawQuery(
      sql,
      [latitude, longitude, latitude, radiusKilometers],
    );

    return results.map((map) => Venue.fromMap(map)).toList();
  }

  Future<List<Venue>> searchVenues(String query) async {
    return (await this.query(
      table,
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    )).map((map) => Venue.fromMap(map)).toList();
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
}
