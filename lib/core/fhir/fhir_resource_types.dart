/// Internal FHIR R4-oriented models for future interoperability.
/// Not a full FHIR server — mapping layer only.

enum FhirResourceType {
  patient,
  practitioner,
  encounter,
  observation,
  medicationStatement,
  allergyIntolerance,
  condition,
  appointment,
}

class FhirIdentifier {
  const FhirIdentifier({required this.system, required this.value});

  final String system;
  final String value;

  Map<String, dynamic> toJson() => {'system': system, 'value': value};
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
  });

  final String id;
  final String code;
  final String subjectPatientId;

  Map<String, dynamic> toJson() => {
        'resourceType': 'Condition',
        'id': id,
        'code': {'text': code},
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
