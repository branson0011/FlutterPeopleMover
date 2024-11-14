import 'dart:convert';
import 'base_repository.dart';

class PreferenceRepository extends BaseRepository {
  static const String table = 'user_preferences';

  Future<void> savePreferences(String userId, Map<String, dynamic> preferences) async {
    final row = {
      'user_id': userId,
      'preferences': jsonEncode(preferences),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };

    await insert(
      table,
      row,
    );
  }

  Future<Map<String, dynamic>?> getPreferences(String userId) async {
    final maps = await query(
      table,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return jsonDecode(maps.first['preferences'] as String);
  }

  Future<void> updatePreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    final row = {
      'preferences': jsonEncode(preferences),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };

    await update(
      table,
      row,
      'user_id = ?',
      [userId],
    );
  }

  Future<void> deletePreferences(String userId) async {
    await delete(table, 'user_id = ?', [userId]);
  }
}
