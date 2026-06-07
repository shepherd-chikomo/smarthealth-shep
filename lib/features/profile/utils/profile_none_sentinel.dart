import 'package:smarthealth_shep/shared/models/emergency_medical_metadata.dart';

/// Stored when the user explicitly selects "None" for a profile section.
const profileAllergiesNoneSentinel = '__none__';
const profileConditionsNoneSlug = 'none';
const profileMedicalAidNoneKey = '__none__';
const profilePrimaryProviderNoneSentinel = '__none__';

const profileNoneDisplayLabel = 'None';

bool isAllergiesNone(String? allergies) =>
    allergies == profileAllergiesNoneSentinel;

bool hasConditionsNone(Iterable<String> conditions) =>
    conditions.contains(profileConditionsNoneSlug);

bool isMedicalAidNone(String? schemeKey) =>
    schemeKey == profileMedicalAidNoneKey;

bool isPrimaryProviderNone(PrimaryProviderInfo info) =>
    info.facilityName == profilePrimaryProviderNoneSentinel;

bool isPrimaryProviderSelectionNone(String? facilityName) =>
    facilityName == profilePrimaryProviderNoneSentinel;

bool allergiesSectionComplete(String? allergies) =>
    isAllergiesNone(allergies) ||
    (allergies != null && allergies.trim().isNotEmpty);

bool conditionsSectionComplete(Iterable<String> conditions) =>
    hasConditionsNone(conditions) || conditions.isNotEmpty;

bool medicalAidSectionComplete(MedicalAidInfo medicalAid) =>
    isMedicalAidNone(medicalAid.schemeKey) || medicalAid.hasAny;

bool primaryProviderSectionComplete(PrimaryProviderInfo provider) =>
    isPrimaryProviderNone(provider) || provider.hasAny;
