import 'base_repository.dart';

class VenueCategoryRepository extends BaseRepository {
  static const String table = 'venue_categories';

  Future<void> addCategoryToVenue(String venueId, String categoryId) async {
    await insert(table, {
      'venue_id': venueId,
      'category_id': categoryId,
    });
  }

  Future<void> removeCategoryFromVenue(String venueId, String categoryId) async {
    await delete(
      table,
      'venue_id = ? AND category_id = ?',
      [venueId, categoryId],
    );
  }

  Future<List<String>> getVenueCategories(String venueId) async {
    final maps = await query(
      table,
      where: 'venue_id = ?',
      whereArgs: [venueId],
    );
    return maps.map((map) => map['category_id'] as String).toList();
  }

  Future<List<String>> getVenuesInCategory(String categoryId) async {
    final maps = await query(
      table,
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return maps.map((map) => map['venue_id'] as String).toList();
  }

  Future<void> updateVenueCategories(String venueId, List<String> categoryIds) async {
    // Start a transaction
    final database = await database;
    await database.transaction((transaction) async {
      // Delete existing categories
      await transaction.delete(
        table,
        where: 'venue_id = ?',
        whereArgs: [venueId],
      );

      // Insert new categories
      for (final categoryId in categoryIds) {
        await transaction.insert(table, {
          'venue_id': venueId,
          'category_id': categoryId,
        });
      }
    });
  }
}
