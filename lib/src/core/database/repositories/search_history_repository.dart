import 'package:sqflite/sqflite.dart';
import '../models/search_history.dart';
import 'base_repository.dart';

class SearchHistoryRepository extends BaseRepository {
  static const String table = 'search_history';

  Future<void> addSearch({
    required String userId,
    required String query,
    String? category,
    Map<String, dynamic>? filters,
  }) async {
    final searchData = {
      'user_id': userId,
      'query': query,
      'category': category,
      'filters': filters != null ? _encodeFilters(filters) : null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await insert(
      table,
      searchData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SearchHistory>> getUserSearchHistory(
    String userId, {
    int limit = 20,
  }) async {
    final results = await query(
      table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return results.map((map) => SearchHistory.fromMap(map)).toList();
  }

  Future<List<String>> getPopularSearches({
    int limit = 10,
    Duration? timeFrame,
  }) async {
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (timeFrame != null) {
      final cutoff = DateTime.now()
          .subtract(timeFrame)
          .millisecondsSinceEpoch;
      whereClause = 'timestamp >= ?';
      whereArgs = [cutoff];
    }

    final sql = '''
      SELECT query, COUNT(*) as count
      FROM $table
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
      GROUP BY query
      ORDER BY count DESC
      LIMIT ?
    ''';

    final results = await rawQuery(sql, [...whereArgs, limit]);
    return results.map((row) => row['query'] as String).toList();
  }

  Future<void> clearUserSearchHistory(String userId) async {
    await delete(
      table,
      'user_id = ?',
      [userId],
    );
  }

  Future<void> deleteOldSearches(Duration age) async {
    final cutoff = DateTime.now().subtract(age).millisecondsSinceEpoch;
    await delete(
      table,
      'timestamp < ?',
      [cutoff],
    );
  }

  String _encodeFilters(Map<String, dynamic> filters) {
    return filters.toString(); // Consider using json.encode for more complex filters
  }
}
