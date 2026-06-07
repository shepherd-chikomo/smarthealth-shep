import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/features/profile/utils/profile_none_sentinel.dart';

/// User selection for the emergency profile primary provider section.
class SelectedPrimaryProvider {
  const SelectedPrimaryProvider({
    this.facilityId,
    this.providerId,
    this.facilityName,
    this.doctorName,
    this.phone,
  });

  final String? facilityId;
  final String? providerId;
  final String? facilityName;
  final String? doctorName;
  final String? phone;

  bool get hasSelection =>
      isNone ||
      (facilityName?.isNotEmpty ?? false) ||
      (doctorName?.isNotEmpty ?? false);

  bool get isNone => isPrimaryProviderSelectionNone(facilityName);

  String get summaryLabel {
    if (isNone) return profileNoneDisplayLabel;
    final doctor = doctorName?.trim();
    final facility = facilityName?.trim();
    if (doctor != null &&
        doctor.isNotEmpty &&
        facility != null &&
        facility.isNotEmpty) {
      return '$doctor · $facility';
    }
    if (doctor != null && doctor.isNotEmpty) return doctor;
    if (facility != null && facility.isNotEmpty) return facility;
    return 'Select facility or doctor';
  }

  factory SelectedPrimaryProvider.none() {
    return const SelectedPrimaryProvider(
      facilityName: profilePrimaryProviderNoneSentinel,
    );
  }

  factory SelectedPrimaryProvider.fromInfo(PrimaryProviderInfo info) {
    if (isPrimaryProviderNone(info)) {
      return SelectedPrimaryProvider.none();
    }
    return SelectedPrimaryProvider(
      facilityId: info.facilityId,
      providerId: info.providerId,
      facilityName: info.facilityName,
      doctorName: info.doctorName,
      phone: info.phone,
    );
  }

  factory SelectedPrimaryProvider.fromProvider(ProviderModel provider) {
    return SelectedPrimaryProvider(
      providerId: provider.id,
      doctorName: provider.name,
      facilityName: provider.facilityName,
      phone: provider.phone,
    );
  }

  factory SelectedPrimaryProvider.fromFacility(FacilityModel facility) {
    return SelectedPrimaryProvider(
      facilityId: facility.id,
      facilityName: facility.name,
      phone: facility.phone ?? facility.whatsappPhone,
    );
  }

  PrimaryProviderInfo toInfo({String? phoneOverride}) {
    final resolvedPhone = phoneOverride?.trim().isNotEmpty == true
        ? phoneOverride!.trim()
        : phone?.trim();
    return PrimaryProviderInfo(
      facilityId: facilityId,
      providerId: providerId,
      facilityName: facilityName?.trim().isEmpty ?? true
          ? null
          : facilityName?.trim(),
      doctorName:
          doctorName?.trim().isEmpty ?? true ? null : doctorName?.trim(),
      phone: resolvedPhone?.isEmpty ?? true ? null : resolvedPhone,
    );
  }

  SelectedPrimaryProvider copyWith({
    String? facilityId,
    String? providerId,
    String? facilityName,
    String? doctorName,
    String? phone,
  }) {
    return SelectedPrimaryProvider(
      facilityId: facilityId ?? this.facilityId,
      providerId: providerId ?? this.providerId,
      facilityName: facilityName ?? this.facilityName,
      doctorName: doctorName ?? this.doctorName,
      phone: phone ?? this.phone,
    );
  }
}
