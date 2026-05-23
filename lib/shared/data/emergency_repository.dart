import 'package:smarthealth_shep/features/emergency/data/emergency_hub_repository.dart';
import 'package:smarthealth_shep/features/emergency/models/emergency_service.dart';

/// Legacy wrapper — delegates to [EmergencyHubRepository].
class EmergencyRepository {
  EmergencyRepository({EmergencyHubRepository? hubRepository})
      : _hub = hubRepository ?? EmergencyHubRepository();

  final EmergencyHubRepository _hub;

  Future<List<EmergencyService>> getServices() async {
    final data = await _hub.loadHub();
    return data.services;
  }
}
