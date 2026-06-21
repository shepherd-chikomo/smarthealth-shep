import 'package:my_practice/domain/models/portal_profile.dart';

class ClaimRecord {
  const ClaimRecord({
    required this.id,
    required this.type,
    required this.status,
    this.facilityId,
    this.facilityName,
    this.providerId,
    this.providerName,
  });

  factory ClaimRecord.fromJson(Map<String, dynamic> json) {
    return ClaimRecord(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'facility',
      status: json['status'] as String? ?? 'draft',
      facilityId: json['facilityId'] as String?,
      facilityName: json['facilityName'] as String?,
      providerId: json['providerId'] as String?,
      providerName: json['providerName'] as String?,
    );
  }

  final String id;
  final String type;
  final String status;
  final String? facilityId;
  final String? facilityName;
  final String? providerId;
  final String? providerName;

  String get displayName => facilityName ?? providerName ?? 'Listing';

  String get statusLabel {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'submitted':
      case 'under_review':
        return 'Claim pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}

class ClaimableFacility {
  const ClaimableFacility({
    required this.id,
    required this.name,
    this.city,
    this.province,
    this.isClaimed = false,
    this.pendingClaims = 0,
  });

  factory ClaimableFacility.fromJson(Map<String, dynamic> json) {
    return ClaimableFacility(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String?,
      province: json['province'] as String?,
      isClaimed: json['isClaimed'] as bool? ?? false,
      pendingClaims: json['pendingClaims'] as int? ?? 0,
    );
  }

  final String id;
  final String name;
  final String? city;
  final String? province;
  final bool isClaimed;
  final int pendingClaims;

  String get locationLabel {
    final parts = [city, province].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? 'Zimbabwe' : parts.join(', ');
  }
}

class ClaimableProvider {
  const ClaimableProvider({
    required this.id,
    required this.name,
    required this.facilityName,
    this.specialty,
    this.facilityId,
    this.isClaimed = false,
    this.pendingClaims = 0,
  });

  factory ClaimableProvider.fromJson(Map<String, dynamic> json) {
    return ClaimableProvider(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      specialty: json['specialty'] as String?,
      facilityId: json['facilityId'] as String?,
      facilityName: json['facilityName'] as String? ?? '',
      isClaimed: json['isClaimed'] as bool? ?? false,
      pendingClaims: json['pendingClaims'] as int? ?? 0,
    );
  }

  final String id;
  final String name;
  final String? specialty;
  final String? facilityId;
  final String facilityName;
  final bool isClaimed;
  final int pendingClaims;
}

class OnboardingStatus {
  const OnboardingStatus({
    required this.phase,
    this.provider,
    this.linkedFacilities = const [],
  });

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    final linkedRaw = json['linkedFacilities'] as List<dynamic>? ?? [];
    return OnboardingStatus(
      phase: json['phase'] as String? ?? 'unclaimed',
      provider: json['provider'] != null
          ? ProviderSummary.fromJson(json['provider'] as Map<String, dynamic>)
          : null,
      linkedFacilities: linkedRaw
          .map((f) => LinkedFacility.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  final String phase;
  final ProviderSummary? provider;
  final List<LinkedFacility> linkedFacilities;
}

class RegistryEmailMatch {
  const RegistryEmailMatch({
    required this.matched,
    this.skipDocuments = false,
    this.provider,
    this.linkedFacilities = const [],
  });

  factory RegistryEmailMatch.fromJson(Map<String, dynamic> json) {
    final linkedRaw = json['linkedFacilities'] as List<dynamic>? ?? [];
    return RegistryEmailMatch(
      matched: json['matched'] as bool? ?? false,
      skipDocuments: json['skipDocuments'] as bool? ?? false,
      provider: json['provider'] != null
          ? ProviderSummary.fromJson(json['provider'] as Map<String, dynamic>)
          : null,
      linkedFacilities: linkedRaw
          .map((f) => LinkedFacility.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  final bool matched;
  final bool skipDocuments;
  final ProviderSummary? provider;
  final List<LinkedFacility> linkedFacilities;
}

class ClaimEvidenceFile {
  const ClaimEvidenceFile({
    required this.name,
    required this.type,
    required this.size,
    required this.dataUrl,
  });

  final String name;
  final String type;
  final int size;
  final String dataUrl;

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'size': size,
        'dataUrl': dataUrl,
      };
}

Map<String, dynamic> evidencePayload(
  List<ClaimEvidenceFile> files, {
  bool skipDocuments = false,
}) {
  if (skipDocuments) {
    return {
      'registryEmailMatch': true,
      'documentUploadSkipped': true,
    };
  }
  return {
    'documents': files.map((f) => f.toJson()).toList(),
  };
}
