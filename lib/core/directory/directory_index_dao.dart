import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:smarthealth_shep/core/storage/app_database.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';

class DirectoryIndexEntry {
  const DirectoryIndexEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.name,
    required this.searchBlob,
    this.facilityType,
    this.latitude,
    this.longitude,
    required this.payloadJson,
    required this.updatedAt,
  });

  final String id;
  final String entityType;
  final String entityId;
  final String name;
  final String searchBlob;
  final String? facilityType;
  final double? latitude;
  final double? longitude;
  final String payloadJson;
  final DateTime updatedAt;
}

class DirectoryIndexDao {
  Future<void> upsertProvider(ProviderModel provider) async {
    final blob = [
      provider.name,
      provider.specialty,
      provider.facilityName,
      provider.address,
      provider.categoryId,
    ].whereType<String>().join(' ').toLowerCase();

    await _upsert(
      id: 'provider:${provider.id}',
      entityType: 'provider',
      entityId: provider.id,
      name: provider.name,
      searchBlob: blob,
      facilityType: provider.categoryId,
      latitude: provider.latitude,
      longitude: provider.longitude,
      payloadJson: jsonEncode(provider.toJson()),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> upsertFacility(FacilityModel facility) async {
    final blob = [
      facility.name,
      facility.city,
      facility.addressLine1,
      facility.slug,
      facility.facilityType,
    ].whereType<String>().join(' ').toLowerCase();

    await _upsert(
      id: 'facility:${facility.id}',
      entityType: 'facility',
      entityId: facility.id,
      name: facility.name,
      searchBlob: blob,
      facilityType: facility.facilityType,
      latitude: facility.latitude,
      longitude: facility.longitude,
      payloadJson: jsonEncode(facility.toJson()),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> _upsert({
    required String id,
    required String entityType,
    required String entityId,
    required String name,
    required String searchBlob,
    String? facilityType,
    double? latitude,
    double? longitude,
    required String payloadJson,
    required DateTime updatedAt,
  }) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'directory_index',
      {
        'id': id,
        'entity_type': entityType,
        'entity_id': entityId,
        'name_lower': name.toLowerCase(),
        'search_blob_lower': searchBlob,
        'facility_type': facilityType,
        'latitude': latitude,
        'longitude': longitude,
        'payload_json': payloadJson,
        'updated_at': updatedAt.toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DirectoryIndexEntry>> search({
    required String query,
    Set<String> entityTypes = const {'facility', 'provider'},
    int limit = 50,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final db = await AppDatabase.instance.database;
    final placeholders = List.filled(entityTypes.length, '?').join(',');
    final rows = await db.query(
      'directory_index',
      where:
          'entity_type IN ($placeholders) AND (name_lower LIKE ? OR search_blob_lower LIKE ?)',
      whereArgs: [...entityTypes, '%$q%', '%$q%'],
      orderBy: 'name_lower ASC',
      limit: limit,
    );

    return rows
        .map(
          (row) => DirectoryIndexEntry(
            id: row['id'] as String,
            entityType: row['entity_type'] as String,
            entityId: row['entity_id'] as String,
            name: row['name_lower'] as String,
            searchBlob: row['search_blob_lower'] as String,
            facilityType: row['facility_type'] as String?,
            latitude: row['latitude'] as double?,
            longitude: row['longitude'] as double?,
            payloadJson: row['payload_json'] as String,
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
        )
        .toList();
  }
}
