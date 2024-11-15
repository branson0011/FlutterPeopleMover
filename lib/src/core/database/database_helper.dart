No content yet

    // Search history table
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        query TEXT NOT NULL,
        category TEXT,
        filters TEXT,
        timestamp INTEGER NOT NULL
      )
    ''');
