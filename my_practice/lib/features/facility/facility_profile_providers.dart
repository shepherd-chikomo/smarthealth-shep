import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/domain/constants/facility_profile_constants.dart';
import 'package:my_practice/domain/models/facility_profile_settings.dart';
import 'package:my_practice/domain/models/facility_service.dart';

final facilityProfileProvider =
    FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(facilityRepositoryProvider).getProfile();
});

final facilityServicesCatalogProvider =
    FutureProvider<List<FacilityServiceCatalogItem>>((ref) async {
  try {
    final raw = await ref.watch(facilityRepositoryProvider).getServicesCatalog();
    List<FacilityServiceCatalogItem> mapList(String key) {
      return (raw[key] ?? [])
          .map((m) => FacilityServiceCatalogItem.fromJson(m))
          .where((s) => s.id.isNotEmpty && s.label.isNotEmpty)
          .toList();
    }

    final items = [...mapList('preset'), ...mapList('other')];
    if (items.isNotEmpty) return items;
  } catch (_) {}

  return fallbackServiceCatalogItems
      .map(
        (e) => FacilityServiceCatalogItem(
          id: e.id,
          label: e.label,
          iconKey: e.iconKey,
        ),
      )
      .toList();
});

final facilityMedicalAidCatalogProvider =
    FutureProvider<List<MedicalAidCatalogItem>>((ref) async {
  try {
    final raw =
        await ref.watch(facilityRepositoryProvider).getMedicalAidCatalog();
    final items = raw
        .map(MedicalAidCatalogItem.fromJson)
        .where((s) => s.schemeKey.isNotEmpty)
        .toList();
    if (items.isNotEmpty) return items;
  } catch (_) {}

  return fallbackMedicalAidCatalogItems
      .map((e) => MedicalAidCatalogItem(schemeKey: e.schemeKey, name: e.name))
      .toList();
});

final facilityMedicalAidSubmissionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref
      .watch(facilityRepositoryProvider)
      .getMedicalAidSubmissions(status: 'pending');
});

final facilitySlotsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(facilityRepositoryProvider).getSlots();
});
