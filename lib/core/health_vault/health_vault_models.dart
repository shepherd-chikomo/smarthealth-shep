import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';
import 'package:smarthealth_shep/shared/models/family_member_model.dart';

/// Device-only encrypted health record for one subject (self or family member).
class HealthVaultRecord {
  const HealthVaultRecord({
    required this.subjectId,
    this.bloodGroup,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.medications = const [],
    this.vaccinations = const [],
    this.medicalHistory,
    this.familyHistory,
    this.emergencyContact = const EmergencyContactInfo(),
    this.medicalAid = const MedicalAidInfo(),
    this.primaryProvider = const PrimaryProviderInfo(),
    this.healthNotes = const [],
    this.healthSummary,
    required this.updatedAt,
  });

  final String subjectId;
  final String? bloodGroup;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<MedicationEntry> medications;
  final List<String> vaccinations;
  final String? medicalHistory;
  final String? familyHistory;
  final EmergencyContactInfo emergencyContact;
  final MedicalAidInfo medicalAid;
  final PrimaryProviderInfo primaryProvider;
  final List<String> healthNotes;
  final String? healthSummary;
  final DateTime updatedAt;

  bool get hasEmergencyData =>
      (bloodGroup?.isNotEmpty ?? false) ||
      allergies.isNotEmpty ||
      chronicConditions.isNotEmpty ||
      medications.isNotEmpty ||
      emergencyContact.hasAny;

  EmergencyMedicalMetadata toEmergencyMetadata() {
    return EmergencyMedicalMetadata(
      bloodGroup: bloodGroup,
      medications: medications,
      emergencyContact: emergencyContact,
      medicalAid: medicalAid,
      primaryProvider: primaryProvider,
    );
  }

  HealthVaultRecord copyWith({
    String? bloodGroup,
    List<String>? allergies,
    List<String>? chronicConditions,
    List<MedicationEntry>? medications,
    List<String>? vaccinations,
    String? medicalHistory,
    String? familyHistory,
    EmergencyContactInfo? emergencyContact,
    MedicalAidInfo? medicalAid,
    PrimaryProviderInfo? primaryProvider,
    List<String>? healthNotes,
    String? healthSummary,
    DateTime? updatedAt,
  }) {
    return HealthVaultRecord(
      subjectId: subjectId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      medications: medications ?? this.medications,
      vaccinations: vaccinations ?? this.vaccinations,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      familyHistory: familyHistory ?? this.familyHistory,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalAid: medicalAid ?? this.medicalAid,
      primaryProvider: primaryProvider ?? this.primaryProvider,
      healthNotes: healthNotes ?? this.healthNotes,
      healthSummary: healthSummary ?? this.healthSummary,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'subjectId': subjectId,
        'bloodGroup': bloodGroup,
        'allergies': allergies,
        'chronicConditions': chronicConditions,
        'medications': medications.map((m) => m.toJson()).toList(),
        'vaccinations': vaccinations,
        'medicalHistory': medicalHistory,
        'familyHistory': familyHistory,
        'emergencyContact': emergencyContact.toJson(),
        'medicalAid': medicalAid.toJson(),
        'primaryProvider': primaryProvider.toJson(),
        'healthNotes': healthNotes,
        'healthSummary': healthSummary,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory HealthVaultRecord.fromJson(Map<String, dynamic> json) {
    return HealthVaultRecord(
      subjectId: json['subjectId'] as String,
      bloodGroup: json['bloodGroup'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      chronicConditions: (json['chronicConditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => MedicationEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      vaccinations: (json['vaccinations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      medicalHistory: json['medicalHistory'] as String?,
      familyHistory: json['familyHistory'] as String?,
      emergencyContact: EmergencyContactInfo.fromJson(
        json['emergencyContact'] as Map<String, dynamic>?,
      ),
      medicalAid: MedicalAidInfo.fromJson(
        json['medicalAid'] as Map<String, dynamic>?,
      ),
      primaryProvider: PrimaryProviderInfo.fromJson(
        json['primaryProvider'] as Map<String, dynamic>?,
      ),
      healthNotes: (json['healthNotes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      healthSummary: json['healthSummary'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static HealthVaultRecord fromFamilyMember(FamilyMemberModel member) {
    final metadata = member.metadata ?? const EmergencyMedicalMetadata();
    final allergyList = member.allergies == null || member.allergies!.trim().isEmpty
        ? const <String>[]
        : member.allergies!
            .split(RegExp(r'[,;]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    return HealthVaultRecord(
      subjectId: member.id,
      bloodGroup: metadata.bloodGroup,
      allergies: allergyList,
      chronicConditions: List<String>.from(member.medicalConditions),
      medications: List<MedicationEntry>.from(metadata.medications),
      emergencyContact: metadata.emergencyContact,
      medicalAid: metadata.medicalAid,
      primaryProvider: metadata.primaryProvider,
      updatedAt: member.updatedAt ?? DateTime.now().toUtc(),
    );
  }

  FamilyMemberModel applyToFamilyMember(FamilyMemberModel member) {
    final metadata = toEmergencyMetadata();
    final allergyText =
        allergies.isEmpty ? null : allergies.join(', ');
    return member.copyWith(
      allergies: allergyText,
      medicalConditions: chronicConditions,
      metadata: metadata,
      updatedAt: updatedAt,
    );
  }
}
