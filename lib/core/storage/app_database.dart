import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// SQLite database holder for offline provider storage.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'smarthealth.db'),
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createProviderTables(db);
    if (version >= 2) {
      await _createBookingTables(db);
    }
    if (version >= 3) {
      await _upgradeFamilyMembersTable(db);
    }
    if (version >= 4) {
      await _createSyncQueueTable(db);
    }
    if (version >= 5) {
      await _upgradeFamilyMembersMetadata(db);
    }
    if (version >= 6) {
      await _createPrivacyFirstTables(db);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createBookingTables(db);
    }
    if (oldVersion < 3) {
      await _upgradeFamilyMembersTable(db);
    }
    if (oldVersion < 4) {
      await _createSyncQueueTable(db);
    }
    if (oldVersion < 5) {
      await _upgradeFamilyMembersMetadata(db);
    }
    if (oldVersion < 6) {
      await _createPrivacyFirstTables(db);
    }
  }

  Future<void> _createProviderTables(Database db) async {
    await db.execute('''
      CREATE TABLE providers (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        category_id TEXT NOT NULL,
        specialty_id TEXT,
        latitude REAL,
        longitude REAL,
        data_json TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_providers_category ON providers(category_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_providers_specialty ON providers(specialty_id)
    ''');

    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY NOT NULL,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createBookingTables(Database db) async {
    await db.execute('''
      CREATE TABLE family_members (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        relationship TEXT NOT NULL,
        date_of_birth TEXT,
        gender TEXT,
        medical_conditions TEXT NOT NULL DEFAULT '[]',
        allergies TEXT,
        is_primary INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE booking_drafts (
        id TEXT PRIMARY KEY NOT NULL,
        provider_id TEXT NOT NULL,
        data_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY NOT NULL,
        reference TEXT NOT NULL,
        data_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE booking_ref_counter (
        date_key TEXT PRIMARY KEY NOT NULL,
        counter INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _upgradeFamilyMembersTable(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(family_members)');
    if (columns.isEmpty) {
      await db.execute('''
        CREATE TABLE family_members (
          id TEXT PRIMARY KEY NOT NULL,
          name TEXT NOT NULL,
          relationship TEXT NOT NULL,
          date_of_birth TEXT,
          gender TEXT,
          medical_conditions TEXT NOT NULL DEFAULT '[]',
          allergies TEXT,
          is_primary INTEGER NOT NULL DEFAULT 0
        )
      ''');
      return;
    }

    final names = columns.map((c) => c['name'] as String).toSet();
    if (!names.contains('gender')) {
      await db.execute('ALTER TABLE family_members ADD COLUMN gender TEXT');
    }
    if (!names.contains('medical_conditions')) {
      await db.execute(
        "ALTER TABLE family_members ADD COLUMN medical_conditions TEXT NOT NULL DEFAULT '[]'",
      );
    }
    if (!names.contains('allergies')) {
      await db.execute('ALTER TABLE family_members ADD COLUMN allergies TEXT');
    }
    if (!names.contains('is_primary')) {
      await db.execute(
        'ALTER TABLE family_members ADD COLUMN is_primary INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> _upgradeFamilyMembersMetadata(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(family_members)');
    if (columns.isEmpty) return;
    final names = columns.map((c) => c['name'] as String).toSet();
    if (!names.contains('metadata')) {
      await db.execute(
        "ALTER TABLE family_members ADD COLUMN metadata TEXT NOT NULL DEFAULT '{}'",
      );
    }
    if (!names.contains('updated_at')) {
      await db.execute('ALTER TABLE family_members ADD COLUMN updated_at TEXT');
    }
  }

  Future<void> _createPrivacyFirstTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS health_vault (
        subject_id TEXT PRIMARY KEY NOT NULL,
        encrypted_payload TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cloud_account (
        id TEXT PRIMARY KEY NOT NULL,
        payload_json TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS directory_index (
        id TEXT PRIMARY KEY NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        name_lower TEXT NOT NULL,
        search_blob_lower TEXT NOT NULL,
        facility_type TEXT,
        latitude REAL,
        longitude REAL,
        payload_json TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_directory_entity_type
      ON directory_index(entity_type, facility_type)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_directory_name
      ON directory_index(name_lower)
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS audit_log (
        id TEXT PRIMARY KEY NOT NULL,
        action TEXT NOT NULL,
        subject_id TEXT,
        details_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createSyncQueueTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id TEXT PRIMARY KEY NOT NULL,
        mutation_type TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        next_retry_at TEXT,
        last_error TEXT,
        client_updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_queue_status
      ON sync_queue(status, next_retry_at)
    ''');
  }
}
