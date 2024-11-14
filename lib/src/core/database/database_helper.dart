import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'migrations/migration_manager.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'recommendations.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE user_preferences (
        user_id TEXT PRIMARY KEY,
        preferences TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final migrationManager = MigrationManager();
    await migrationManager.migrate(db, oldVersion, newVersion);
  }
}
