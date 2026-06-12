class PortalProfile {
  const PortalProfile({
    required this.id,
    required this.role,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.facilities = const [],
    this.provider,
  });

  factory PortalProfile.fromJson(Map<String, dynamic> json) {
    final facilitiesRaw = json['facilities'] as List<dynamic>? ?? [];
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
      provider: json['provider'] != null
          ? ProviderSummary.fromJson(json['provider'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final List<FacilityMembership> facilities;
  final ProviderSummary? provider;

  String get displayName {
    final parts = [firstName, lastName].whereType<String>().toList();
    return parts.isEmpty ? 'Practitioner' : parts.join(' ');
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
