import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/domain/models/facility_hour.dart';

final teamListProvider = FutureProvider<List<Practitioner>>((ref) async {
  final team = await ref.watch(facilityRepositoryProvider).getTeam();
  debugPrint('[TeamProvider] DB team count: ${team.length}');
  if (team.isNotEmpty) return team;

  final auth = ref.watch(authStateProvider);
  final facilityId = ref.watch(facilityIdProvider);
  final profile = auth.profile;
  debugPrint('[TeamProvider] profile=${profile?.displayName}, facilityId=$facilityId');
  if (profile == null || facilityId == null) return team;

  final role = profile.facilities
          .where((f) => f.id == facilityId)
          .map((f) => f.role)
          .firstOrNull ??
      profile.role;
  final now = DateTime.now().toUtc();
  return [
    Practitioner(
      id: profile.id,
      facilityId: facilityId,
      name: profile.displayName,
      role: role,
      registrationNumber: profile.provider?.registrationNumber,
      serverId: profile.id,
      syncStatus: 'synced',
      updatedAt: now,
    ),
  ];
});

final facilityHoursProvider = FutureProvider.autoDispose<List<FacilityHour>>((ref) {
  return ref.watch(facilityRepositoryProvider).getFacilityHours();
});
