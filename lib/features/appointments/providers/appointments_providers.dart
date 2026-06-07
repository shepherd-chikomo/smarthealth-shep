import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/network/dio_client.dart';
import 'package:smarthealth_shep/features/appointments/data/appointments_repository.dart';
import 'package:smarthealth_shep/features/appointments/models/appointment_model.dart';

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return AppointmentsRepository(dio: ref.watch(dioProvider));
});

final nextUpcomingAppointmentProvider =
    FutureProvider<AppointmentModel?>((ref) async {
  final repository = ref.watch(appointmentsRepositoryProvider);
  await repository.syncFromRemote();
  return repository.getNextUpcoming();
});

void invalidateUpcomingAppointment(WidgetRef ref) {
  ref.invalidate(nextUpcomingAppointmentProvider);
}
