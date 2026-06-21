class PortalProfile {
  const PortalProfile({
    required this.id,
    required this.role,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.facilities = const [],
    this.linkedFacilities = const [],
    this.provider,
    this.portalMode,
  });

  factory PortalProfile.fromJson(Map<String, dynamic> json) {
    final facilitiesRaw = json['facilities'] as List<dynamic>? ?? [];
    final linkedRaw = json['linkedFacilities'] as List<dynamic>? ?? [];
    return PortalProfile(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? 'doctor',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      facilities: facilitiesRaw
          .map((f) => FacilityMembership.fromJson(f as Map<String, dynamic>))
          .toList(),
      linkedFacilities: linkedRaw
          .map((f) => LinkedFacility.fromJson(f as Map<String, dynamic>))
          .toList(),
      provider: json['provider'] != null
          ? ProviderSummary.fromJson(json['provider'] as Map<String, dynamic>)
          : null,
      portalMode: json['portalMode'] as String?,
    );
  }

  final String id;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final List<FacilityMembership> facilities;
  final List<LinkedFacility> linkedFacilities;
  final ProviderSummary? provider;
  final String? portalMode;

  bool get isProviderMode =>
      portalMode == 'provider' || (facilities.isEmpty && provider != null);

  String get displayName {
    final parts = [firstName, lastName]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    if (provider != null && provider!.name.isNotEmpty) return provider!.name;
    return 'Practitioner';
  }

  String? facilityNameFor(String? facilityId) {
    if (facilityId == null) return null;
    for (final f in facilities) {
      if (f.id == facilityId) return f.name;
    }
    for (final f in linkedFacilities) {
      if (f.id == facilityId) return f.name;
    }
    return null;
  }
}

class FacilityMembership {
  const FacilityMembership({
    required this.id,
    required this.name,
    required this.role,
    this.membershipId,
  });

  factory FacilityMembership.fromJson(Map<String, dynamic> json) {
    return FacilityMembership(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'doctor',
      membershipId: json['membershipId'] as String?,
    );
  }

  final String id;
  final String name;
  final String role;
  final String? membershipId;
}

class LinkedFacility {
  const LinkedFacility({
    required this.id,
    required this.name,
    this.city,
    this.isClaimed = false,
    this.isVerified = false,
    this.canClaimOwnership = false,
    this.isOwnedByMe = false,
  });

  factory LinkedFacility.fromJson(Map<String, dynamic> json) {
    return LinkedFacility(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String?,
      isClaimed: json['isClaimed'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      canClaimOwnership: json['canClaimOwnership'] as bool? ?? false,
      isOwnedByMe: json['isOwnedByMe'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String? city;
  final bool isClaimed;
  final bool isVerified;
  final bool canClaimOwnership;
  final bool isOwnedByMe;

  String get statusLabel {
    if (isOwnedByMe) return 'Owned by you';
    if (isClaimed) return 'Claimed by another';
    return 'Unclaimed';
  }
}

class ProviderSummary {
  const ProviderSummary({
    required this.id,
    required this.name,
    this.specialty,
    this.registrationNumber,
  });

  factory ProviderSummary.fromJson(Map<String, dynamic> json) {
    return ProviderSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      specialty: json['specialty'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
    );
  }

  final String id;
  final String name;
  final String? specialty;
  final String? registrationNumber;
}

class ProviderLookupResult {
  const ProviderLookupResult({
    required this.matched,
    this.alreadyClaimed,
    this.ambiguous,
    this.provider,
    this.linkedFacilities = const [],
  });

  factory ProviderLookupResult.fromJson(Map<String, dynamic> json) {
    final linkedRaw = json['linkedFacilities'] as List<dynamic>? ?? [];
    return ProviderLookupResult(
      matched: json['matched'] as bool? ?? false,
      alreadyClaimed: json['alreadyClaimed'] as bool?,
      ambiguous: json['ambiguous'] as bool?,
      provider: json['provider'] != null
          ? ProviderSummary.fromJson(json['provider'] as Map<String, dynamic>)
          : null,
      linkedFacilities: linkedRaw
          .map((f) => LinkedFacility.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  final bool matched;
  final bool? alreadyClaimed;
  final bool? ambiguous;
  final ProviderSummary? provider;
  final List<LinkedFacility> linkedFacilities;
}
