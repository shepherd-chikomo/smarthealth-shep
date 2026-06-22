import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/domain/models/facility_hour.dart';

final teamListProvider = FutureProvider<List<Practitioner>>((ref) {
  return ref.watch(facilityRepositoryProvider).getTeam();
});

final facilityHoursProvider = FutureProvider.autoDispose<List<FacilityHour>>((ref) {
  return ref.watch(facilityRepositoryProvider).getFacilityHours();
});
