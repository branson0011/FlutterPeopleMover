import 'dart:convert';
import 'base_repository.dart';
import '../models/user_preferences.dart';

class UserPreferencesRepository extends BaseRepository {
  static const String table = 'user_preferences';

  Future<void> savePreferences(UserPreferences preferences) async {
    final map = preferences.toMap();
    map['preferences'] = jsonEncode(map['preferences']);
    
    await insert(
      table,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserPreferences?> getPreferences(String userId) async {
    final results = await query(
      table,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) return null;

    final map = Map<String, dynamic>.from(results.first);
    map['preferences'] = jsonDecode(map['preferences'] as String);
    return UserPreferences.fromMap(map);
  }

  Future<void> updatePreferences(String userId, Map<String, dynamic> updates) async {
    final existing = await getPreferences(userId);
    if (existing == null) {
      await savePreferences(
        UserPreferences(
          userId: userId,
          preferences: updates,
          updatedAt: DateTime.now(),
        ),
      );
      return;
    }

    final merged = {
      ...existing.preferences,
      ...updates,
    };

    await update(
      table,
      {
        'preferences': jsonEncode(merged),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      'user_id = ?',
      [userId],
    );
  }

  Future<List<String>> getUsersWithPreference(String key, dynamic value) async {
    final allPrefs = await query(table);
    return allPrefs
        .where((row) {
          final prefs = jsonDecode(row['preferences'] as String);
          return prefs[key] == value;
        })
        .map((row) => row['user_id'] as String)
        .toList();
  }
}
