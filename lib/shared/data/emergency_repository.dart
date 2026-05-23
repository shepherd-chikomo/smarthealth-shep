import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/shared/data/mock_data.dart';
import 'package:smarthealth_shep/shared/models/emergency_service_model.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>(
  (ref) => EmergencyRepository(),
);

class EmergencyRepository {
  Future<List<EmergencyServiceModel>> getServices() async =>
      MockData.emergencyServices;
}
