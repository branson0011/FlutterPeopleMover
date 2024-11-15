import 'dart:convert';
import '../models/analytics_event.dart';
import 'base_repository.dart';

class AnalyticsRepository extends BaseRepository {
  static const String table = 'analytics_events';

  Future<void> trackEvent(AnalyticsEvent event) async {
    final map = event.toMap();
    map['properties'] = jsonEncode(map['properties']);
    
    await insert(table, map);
  }

  Future<List<AnalyticsEvent>> getEvents({
    String? eventType,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (eventType != null) {
      whereClause += ' AND event_type = ?';
      whereArgs.add(eventType);
    }

    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }

    if (startDate != null) {
      whereClause += ' AND timestamp >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      whereClause += ' AND timestamp <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    final results = await query(
      table,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return results.map((map) {
      final eventMap = Map<String, dynamic>.from(map);
      eventMap['properties'] = jsonDecode(map['properties'] as String);
      return AnalyticsEvent.fromMap(eventMap);
    }).toList();
  }

  Future<Map<String, int>> getEventCounts(
    String eventType,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final sql = '''
      SELECT date(timestamp/1000, 'unixepoch') as date, COUNT(*) as count
      FROM $table
      WHERE event_type = ?
      AND timestamp BETWEEN ? AND ?
      GROUP BY date
      ORDER BY date
    ''';

    final results = await rawQuery(sql, [
      eventType,
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
    ]);

    return Map.fromEntries(
      results.map((row) => MapEntry(
        row['date'] as String,
        row['count'] as int,
      )),
    );
  }

  Future<void> pruneOldEvents(Duration age) async {
    final cutoff = DateTime.now().subtract(age).millisecondsSinceEpoch;
    await delete(table, 'timestamp < ?', [cutoff]);
  }
}
