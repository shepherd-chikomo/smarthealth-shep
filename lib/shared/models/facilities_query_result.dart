import 'package:smarthealth_shep/shared/models/facility_model.dart';

class FacilitiesQueryResult {
  const FacilitiesQueryResult({
    required this.facilities,
    required this.isOffline,
  });

  final List<FacilityModel> facilities;
  final bool isOffline;
}
