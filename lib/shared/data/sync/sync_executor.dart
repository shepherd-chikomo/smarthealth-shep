import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:smarthealth_shep/shared/data/sync/delta_sync_coordinator.dart';
import 'package:smarthealth_shep/shared/data/sync/sync_queue_item.dart';

const _logName = 'SyncExecutor';

/// Applies queued mutations against the remote API.
class SyncExecutor {
  SyncExecutor({
    required Dio dio,
    DeltaSyncCoordinator? deltaCoordinator,
  })  : _dio = dio,
        _delta = deltaCoordinator ?? DeltaSyncCoordinator(dio: dio);

  final Dio _dio;
  final DeltaSyncCoordinator _delta;

  Future<void> runDeltaPulls() => _delta.runDeltaPulls();

  /// Processes a queue item and returns server response body when available.
  Future<Map<String, dynamic>?> processQueueItem(SyncQueueItem item) async {
    developer.log(
      'Processing ${item.mutationType.label} ${item.entityType.name}/${item.entityId}',
      name: _logName,
    );

    return switch (item.entityType) {
      SyncEntityType.family => _pushFamilyMutation(item),
      SyncEntityType.appointment => _pushAppointmentMutation(item),
      SyncEntityType.queueUpdate => _pushQueueUpdateMutation(item),
      SyncEntityType.provider => _pushProviderMutation(item),
      SyncEntityType.facility => _pushFacilityMutation(item),
      SyncEntityType.operatingHours => _pushOperatingHoursMutation(item),
      SyncEntityType.emergency => _pushEmergencyMutation(item),
    };
  }

  Future<Map<String, dynamic>?> _pushFamilyMutation(SyncQueueItem item) async {
    final path = '/patients/family/${item.entityId}';

    switch (item.mutationType) {
      case SyncMutationType.create:
        final response = await _dio.post<Map<String, dynamic>>(
          '/patients/family',
          data: item.payload,
        );
        return _extractBody(response.data, 'member');
      case SyncMutationType.update:
        final response = await _dio.patch<Map<String, dynamic>>(
          path,
          data: item.payload,
        );
        return _extractBody(response.data, 'member');
      case SyncMutationType.delete:
        await _dio.delete<void>(path);
        return null;
    }
  }

  Future<Map<String, dynamic>?> _pushAppointmentMutation(
    SyncQueueItem item,
  ) async {
    final path = '/appointments/${item.entityId}';

    switch (item.mutationType) {
      case SyncMutationType.create:
        final response = await _dio.post<Map<String, dynamic>>(
          '/appointments',
          data: item.payload,
        );
        return _extractBody(response.data, 'appointment');
      case SyncMutationType.update:
        final response = await _dio.patch<Map<String, dynamic>>(
          path,
          data: item.payload,
        );
        return _extractBody(response.data, 'appointment');
      case SyncMutationType.delete:
        await _dio.delete<void>(path);
        return null;
    }
  }

  Future<Map<String, dynamic>?> _pushQueueUpdateMutation(
    SyncQueueItem item,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/appointments/${item.entityId}',
      data: item.payload,
    );
    return _extractBody(response.data, 'appointment');
  }

  Future<Map<String, dynamic>?> _pushProviderMutation(SyncQueueItem item) async {
    final path = '/providers/${item.entityId}';
    switch (item.mutationType) {
      case SyncMutationType.create:
      case SyncMutationType.update:
        await _dio.patch<Map<String, dynamic>>(path, data: item.payload);
        return null;
      case SyncMutationType.delete:
        await _dio.delete<void>(path);
        return null;
    }
  }

  Future<Map<String, dynamic>?> _pushFacilityMutation(SyncQueueItem item) async {
    await _dio.get<Map<String, dynamic>>(
      '/facilities/${item.entityId}',
    );
    return null;
  }

  Future<Map<String, dynamic>?> _pushOperatingHoursMutation(
    SyncQueueItem item,
  ) async {
    await _dio.get<Map<String, dynamic>>(
      '/providers/${item.entityId}',
    );
    return null;
  }

  Future<Map<String, dynamic>?> _pushEmergencyMutation(SyncQueueItem item) async {
    await _dio.get<Map<String, dynamic>>(
      '/emergency/services',
    );
    return null;
  }

  Map<String, dynamic>? _extractBody(
    Map<String, dynamic>? data,
    String key,
  ) {
    if (data == null) return null;
    final nested = data[key];
    if (nested is Map<String, dynamic>) return nested;
    return data;
  }
}
