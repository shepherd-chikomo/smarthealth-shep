import 'package:smarthealth_shep/core/storage/app_database.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_storage.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite persistence for the offline mutation sync queue (legacy fallback).
class SyncQueueDao implements SyncQueueStorage {
  SyncQueueDao({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    final db = await _db;
    await db.insert(
      'sync_queue',
      item.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<SyncQueueItem>> getRunnableItems({DateTime? now}) async {
    final db = await _db;
    final cutoff = (now ?? DateTime.now()).toUtc().toIso8601String();
    final rows = await db.query(
      'sync_queue',
      where:
          "status IN ('pending', 'failed') AND (next_retry_at IS NULL OR next_retry_at <= ?)",
      whereArgs: [cutoff],
    );

    final items = rows.map(SyncQueueItem.fromRow).toList();
    items.sort((a, b) {
      final priority = a.entityType.priority.compareTo(b.entityType.priority);
      if (priority != 0) return priority;
      return a.createdAt.compareTo(b.createdAt);
    });
    return items;
  }

  @override
  Future<List<SyncQueueItem>> getManualRetryItems() async {
    final db = await _db;
    final rows = await db.query(
      'sync_queue',
      where:
          "status IN ('needsManualRetry', 'needsManualConflict')",
      orderBy: 'created_at ASC',
    );
    return rows.map(SyncQueueItem.fromRow).toList();
  }

  @override
  Future<List<SyncQueueItem>> getAllPending() async {
    final db = await _db;
    final rows = await db.query(
      'sync_queue',
      where: "status != 'completed' AND status != 'processing'",
    );
    return rows.map(SyncQueueItem.fromRow).toList();
  }

  @override
  Future<int> countPending() async {
    final db = await _db;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM sync_queue WHERE status IN "
            "('pending', 'failed', 'needsManualRetry', 'needsManualConflict')",
          ),
        ) ??
        0;
  }

  @override
  Future<void> updateItem(SyncQueueItem item) async {
    final db = await _db;
    await db.update(
      'sync_queue',
      item.toRow(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> markProcessing(String id) async {
    final db = await _db;
    await db.update(
      'sync_queue',
      {'status': SyncQueueStatus.processing.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markCompleted(String id) async {
    final db = await _db;
    await db.update(
      'sync_queue',
      {'status': SyncQueueStatus.completed.name, 'last_error': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteCompleted({
    Duration olderThan = const Duration(days: 7),
  }) async {
    final db = await _db;
    final cutoff =
        DateTime.now().toUtc().subtract(olderThan).toIso8601String();
    await db.delete(
      'sync_queue',
      where: "status = 'completed' AND created_at < ?",
      whereArgs: [cutoff],
    );
  }

  @override
  Future<void> resetManualRetryItems() async {
    final db = await _db;
    await db.update(
      'sync_queue',
      {
        'status': SyncQueueStatus.pending.name,
        'retry_count': 0,
        'next_retry_at': null,
        'last_error': null,
      },
      where: "status IN ('needsManualRetry', 'needsManualConflict')",
    );
  }
}
