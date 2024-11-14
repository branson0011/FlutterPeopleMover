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

class InitialMigration extends Migration {
  InitialMigration() : super(1);

  @override
  Future<void> migrate(Database db) async {
    // Venues table
    await db.execute('''
      CREATE TABLE venues (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        rating REAL,
        price_level INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_id TEXT,
        FOREIGN KEY (parent_id) REFERENCES categories (id)
      )
    ''');

    // User interactions table
    await db.execute('''
      CREATE TABLE user_interactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        venue_id TEXT NOT NULL,
        interaction_type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        data TEXT,
        FOREIGN KEY (venue_id) REFERENCES venues (id)
      )
    ''');

    // Recommendations table
    await db.execute('''
      CREATE TABLE recommendations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        venue_id TEXT NOT NULL,
        score REAL NOT NULL,
        reason TEXT,
        created_at INTEGER NOT NULL,
        expires_at INTEGER,
        FOREIGN KEY (venue_id) REFERENCES venues (id)
      )
    ''');

    // Create indices
    await db.execute(
      'CREATE INDEX idx_venues_location ON venues (latitude, longitude)');
    await db.execute(
      'CREATE INDEX idx_interactions_user ON user_interactions (user_id)');
    await db.execute(
      'CREATE INDEX idx_interactions_venue ON user_interactions (venue_id)');
    await db.execute(
      'CREATE INDEX idx_recommendations_user ON recommendations (user_id)');
  }
}
