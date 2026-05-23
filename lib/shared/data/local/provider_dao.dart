import 'dart:convert';

import 'package:smarthealth_shep/core/storage/app_database.dart';
import 'package:smarthealth_shep/core/utils/haversine.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/models/provider_search_filter.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite access layer for cached providers.
class ProviderDao {
  ProviderDao({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  static const lastSyncKey = 'providers_last_sync';
  static const defaultStaleAfter = Duration(hours: 24);

  Future<Database> get _db => _database.database;

  Future<DateTime?> getLastSync() async {
    final db = await _db;
    final rows = await db.query(
      'sync_metadata',
      where: 'key = ?',
      whereArgs: [lastSyncKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final raw = rows.first['value'] as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastSync(DateTime timestamp) async {
    final db = await _db;
    await db.insert(
      'sync_metadata',
      {'key': lastSyncKey, 'value': timestamp.toUtc().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isStale(String id, {Duration? maxAge}) async {
    final db = await _db;
    final rows = await db.query(
      'providers',
      columns: ['cached_at'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return true;

    final cachedAt = DateTime.tryParse(rows.first['cached_at'] as String? ?? '');
    if (cachedAt == null) return true;

    final age = DateTime.now().toUtc().difference(cachedAt);
    return age > (maxAge ?? defaultStaleAfter);
  }

  Future<ProviderModel?> getById(String id) async {
    final db = await _db;
    final rows = await db.query(
      'providers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToModel(rows.first);
  }

  Future<List<ProviderModel>> getAll({String? categoryId}) async {
    final db = await _db;
    final rows = categoryId == null
        ? await db.query('providers', orderBy: 'name COLLATE NOCASE ASC')
        : await db.query(
            'providers',
            where: 'category_id = ?',
            whereArgs: [categoryId],
            orderBy: 'name COLLATE NOCASE ASC',
          );
    return rows.map(_rowToModel).toList();
  }

  /// Returns providers within [radiusKm] of ([lat], [lon]) using haversine.
  Future<List<ProviderModel>> getNearby(
    double lat,
    double lon,
    double radiusKm,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'providers',
      where: 'latitude IS NOT NULL AND longitude IS NOT NULL',
    );

    final nearby = <ProviderModel>[];
    for (final row in rows) {
      final provider = _rowToModel(row);
      final providerLat = provider.latitude;
      final providerLon = provider.longitude;
      if (providerLat == null || providerLon == null) continue;

      final distance = haversineDistanceKm(
        lat,
        lon,
        providerLat,
        providerLon,
      );
      if (distance <= radiusKm) {
        nearby.add(provider.copyWith(distanceKm: distance));
      }
    }

    nearby.sort(
      (a, b) => (a.distanceKm ?? double.infinity)
          .compareTo(b.distanceKm ?? double.infinity),
    );
    return nearby;
  }

  Future<List<ProviderModel>> search(ProviderSearchFilter filter) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];

    if (filter.categoryId != null) {
      where.add('category_id = ?');
      args.add(filter.categoryId);
    }

    final specialtyId = filter.specialtyId ??
        (filter.specialties.length == 1 ? filter.specialties.first : null);
    if (specialtyId != null) {
      where.add('specialty_id = ?');
      args.add(specialtyId);
    }

    final rows = await db.query(
      'providers',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    var results = rows.map(_rowToModel).toList();

    final q = filter.query.trim().toLowerCase();
    if (q.isNotEmpty) {
      results = results.where((provider) {
        final haystack = [
          provider.name,
          provider.specialty,
          provider.facilityName,
          provider.address,
        ].whereType<String>().join(' ').toLowerCase();
        return haystack.contains(q);
      }).toList();
    }

    if (filter.specialties.length > 1) {
      results = results
          .where((p) =>
              p.specialtyId != null && filter.specialties.contains(p.specialtyId))
          .toList();
    }

    if (filter.conditions.isNotEmpty) {
      results = results
          .where((p) => p.conditions.any(filter.conditions.contains))
          .toList();
    }

    if (filter.ageGroups.isNotEmpty) {
      results = results
          .where((p) => p.ageGroups.any(filter.ageGroups.contains))
          .toList();
    }

    if (filter.latitude != null &&
        filter.longitude != null &&
        filter.radiusKm != null) {
      final lat = filter.latitude!;
      final lon = filter.longitude!;
      final radius = filter.radiusKm!;

      results = results
          .where((p) => p.latitude != null && p.longitude != null)
          .map((p) {
        final distance = haversineDistanceKm(
          lat,
          lon,
          p.latitude!,
          p.longitude!,
        );
        return p.copyWith(distanceKm: distance);
      }).where((p) => (p.distanceKm ?? double.infinity) <= radius).toList();

      results.sort(
        (a, b) => (a.distanceKm ?? double.infinity)
            .compareTo(b.distanceKm ?? double.infinity),
      );
    }

    return results;
  }

  Future<void> upsertProvider(ProviderModel provider) async {
    await upsertProviders([provider]);
  }

  Future<void> upsertProviders(List<ProviderModel> providers) async {
    if (providers.isEmpty) return;

    final db = await _db;
    final now = DateTime.now().toUtc().toIso8601String();
    final batch = db.batch();

    for (final provider in providers) {
      batch.insert(
        'providers',
        _modelToRow(provider, cachedAt: now),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> deleteProviders(List<String> ids) async {
    if (ids.isEmpty) return;

    final db = await _db;
    final batch = db.batch();
    for (final id in ids) {
      batch.delete('providers', where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  ProviderModel _rowToModel(Map<String, Object?> row) {
    final json =
        jsonDecode(row['data_json']! as String) as Map<String, dynamic>;
    return ProviderModel.fromJson(json);
  }

  Map<String, Object?> _modelToRow(
    ProviderModel provider, {
    required String cachedAt,
  }) {
    return {
      'id': provider.id,
      'name': provider.name,
      'category_id': provider.categoryId,
      'specialty_id': provider.specialtyId,
      'latitude': provider.latitude,
      'longitude': provider.longitude,
      'data_json': jsonEncode(provider.toJson()),
      'updated_at': cachedAt,
      'cached_at': cachedAt,
    };
  }
}
