import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/core/sync/sync_providers.dart';
import 'package:smarthealth_shep/features/booking/data/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(
    syncService: ref.watch(syncServiceProvider),
    api: ApiService(ref.watch(dioProvider)),
  );
});
