import 'package:sqflite/sqflite.dart';

abstract class Migration {
  final int version;
  Migration(this.version);
  Future<void> migrate(Database db);
}

class MigrationManager {
  final List<Migration> _migrations = [];

  void register(Migration migration) {
    _migrations.add(migration);
    _migrations.sort((a, b) => a.version.compareTo(b.version));
  }

  Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    for (var migration in _migrations) {
      if (migration.version > oldVersion && migration.version <= newVersion) {
        await migration.migrate(db);
      }
    }
  }
}
