/// Internal FHIR R4-oriented models for future interoperability.

enum FhirResourceType {
  patient,
  practitioner,
  encounter,
  observation,
  medicationStatement,
  medicationRequest,
  allergyIntolerance,
  condition,
  appointment,
  diagnosticReport,
  claim,
}

class FhirIdentifier {
  const FhirIdentifier({required this.system, required this.value});

  final String system;
  final String value;

  Map<String, dynamic> toJson() => {'system': system, 'value': value};

  static const smartHealthPatientSystem =
      'https://smarthealth.co.zw/fhir/sid/patient-id';
  static const smartHealthPractitionerSystem =
      'https://smarthealth.co.zw/fhir/sid/practitioner-id';
  static const smartHealthFacilitySystem =
      'https://smarthealth.co.zw/fhir/sid/facility-id';
}

class FhirHumanName {
  const FhirHumanName({this.given, this.family});

  final List<String>? given;
  final String? family;

  Map<String, dynamic> toJson() => {
        if (given != null) 'given': given,
        if (family != null) 'family': family,
      };
}

class FhirCoding {
  const FhirCoding({this.system, this.code, this.display});

  final String? system;
  final String? code;
  final String? display;

  Map<String, dynamic> toJson() => {
        if (system != null) 'system': system,
        if (code != null) 'code': code,
        if (display != null) 'display': display,
      };
}

class FhirPatient {
  const FhirPatient({
    required this.id,
    required this.identifiers,
    this.name,
    this.birthDate,
    this.gender,
  });

  final String id;
  final List<FhirIdentifier> identifiers;
  final List<FhirHumanName>? name;
  final String? birthDate;
  final String? gender;

  Map<String, dynamic> toJson() => {
        'resourceType': 'Patient',
        'id': id,
        'identifier': identifiers.map((i) => i.toJson()).toList(),
        if (name != null) 'name': name!.map((n) => n.toJson()).toList(),
        if (birthDate != null) 'birthDate': birthDate,
        if (gender != null) 'gender': gender,
      };
}

class FhirPractitioner {
  const FhirPractitioner({
    required this.id,
    required this.identifiers,
    this.name,
  });

  final String id;
  final List<FhirIdentifier> identifiers;
  final List<FhirHumanName>? name;

  Map<String, dynamic> toJson() => {
        'resourceType': 'Practitioner',
        'id': id,
        'identifier': identifiers.map((i) => i.toJson()).toList(),
        if (name != null) 'name': name!.map((n) => n.toJson()).toList(),
      };
}

class FhirEncounter {
  const FhirEncounter({
    required this.id,
    required this.status,
    required this.patientId,
    required this.practitionerId,
    required this.facilityId,
    this.periodStart,
    this.periodEnd,
  });

  final String id;
  final String status;
  final String patientId;
  final String practitionerId;
  final String facilityId;
  final String? periodStart;
  final String? periodEnd;

  Map<String, dynamic> toJson() => {
        'resourceType': 'Encounter',
        'id': id,
        'status': status,
        'subject': {'reference': 'Patient/$patientId'},
        'participant': [
          {'individual': {'reference': 'Practitioner/$practitionerId'}},
        ],
        'serviceProvider': {'reference': 'Organization/$facilityId'},
        if (periodStart != null)
          'period': {
            'start': periodStart,
            if (periodEnd != null) 'end': periodEnd,
          },
      };
}

class FhirAppointment {
  const FhirAppointment({
    required this.id,
    required this.status,
    required this.start,
    this.patientId,
    this.practitionerId,
    this.locationId,
  });

  final String id;
  final String status;
  final String start;
  final String? patientId;
  final String? practitionerId;
  final String? locationId;

  Map<String, dynamic> toJson() => {
        'resourceType': 'Appointment',
        'id': id,
        'status': status,
        'start': start,
        if (patientId != null)
          'participant': [
            {'actor': {'reference': 'Patient/$patientId'}},
            if (practitionerId != null)
              {'actor': {'reference': 'Practitioner/$practitionerId'}},
            if (locationId != null)
              {'actor': {'reference': 'Location/$locationId'}},
          ],
      };
}

class FhirCondition {
  const FhirCondition({
    required this.id,
    required this.code,
    required this.subjectPatientId,
    this.icd11Coding,
  });

  final String id;
  final String code;
  final String subjectPatientId;
  final FhirCoding? icd11Coding;

  Map<String, dynamic> toJson() => {
        'resourceType': 'Condition',
        'id': id,
        'code': {
          'text': code,
          if (icd11Coding != null) 'coding': [icd11Coding!.toJson()],
        },
        'subject': {'reference': 'Patient/$subjectPatientId'},
      };
}

class FhirAllergyIntolerance {
  const FhirAllergyIntolerance({
    required this.id,
    required this.substance,
    required this.patientId,
  });

  final String id;
  final String substance;
  final String patientId;

  Map<String, dynamic> toJson() => {
        'resourceType': 'AllergyIntolerance',
        'id': id,
        'code': {'text': substance},
        'patient': {'reference': 'Patient/$patientId'},
      };
}

class FhirMedicationStatement {
  const FhirMedicationStatement({
    required this.id,
    required this.medication,
    required this.patientId,
  });

  final String id;
  final String medication;
  final String patientId;

  Map<String, dynamic> toJson() => {
        'resourceType': 'MedicationStatement',
        'id': id,
        'medicationCodeableConcept': {'text': medication},
        'subject': {'reference': 'Patient/$patientId'},
      };
}

class FhirMedicationRequest {
  const FhirMedicationRequest({
    required this.id,
    required this.medication,
    required this.patientId,
    required this.requesterId,
    this.dosageInstruction,
    this.status = 'active',
  });

  final String id;
  final String medication;
  final String patientId;
  final String requesterId;
  final String? dosageInstruction;
  final String status;

  Map<String, dynamic> toJson() => {
        'resourceType': 'MedicationRequest',
        'id': id,
        'status': status,
        'medicationCodeableConcept': {'text': medication},
        'subject': {'reference': 'Patient/$patientId'},
        'requester': {'reference': 'Practitioner/$requesterId'},
        if (dosageInstruction != null)
          'dosageInstruction': [
            {'text': dosageInstruction},
          ],
      };
}

class FhirObservation {
  const FhirObservation({
    required this.id,
    required this.code,
    required this.value,
    required this.subjectPatientId,
  });

  final String id;
  final String code;
  final String value;
  final String subjectPatientId;

  Map<String, dynamic> toJson() => {
        'resourceType': 'Observation',
        'id': id,
        'code': {'text': code},
        'valueString': value,
        'subject': {'reference': 'Patient/$subjectPatientId'},
      };
}

class FhirDiagnosticReport {
  const FhirDiagnosticReport({
    required this.id,
    required this.status,
    required this.patientId,
    this.conclusion,
  });

  final String id;
  final String status;
  final String patientId;
  final String? conclusion;

  Map<String, dynamic> toJson() => {
        'resourceType': 'DiagnosticReport',
        'id': id,
        'status': status,
        'subject': {'reference': 'Patient/$patientId'},
        if (conclusion != null) 'conclusion': conclusion,
      };
}

class FhirClaim {
  const FhirClaim({
    required this.id,
    required this.status,
    required this.patientId,
    required this.providerId,
    required this.facilityId,
  });

  final String id;
  final String status;
  final String patientId;
  final String providerId;
  final String facilityId;

  Map<String, dynamic> toJson() => {
        'resourceType': 'Claim',
        'id': id,
        'status': status,
        'patient': {'reference': 'Patient/$patientId'},
        'provider': {'reference': 'Practitioner/$providerId'},
        'facility': {'reference': 'Organization/$facilityId'},
      };
}
