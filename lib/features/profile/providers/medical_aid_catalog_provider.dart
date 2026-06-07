import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/shared/models/medical_aid_scheme.dart';

final medicalAidCatalogProvider =
    FutureProvider<List<MedicalAidScheme>>((ref) async {
  final api = ApiService(createApiDio());
  try {
    return await api.fetchMedicalAidCatalog();
  } catch (_) {
    return defaultMedicalAidSchemes;
  }
});
