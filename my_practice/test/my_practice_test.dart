import 'package:flutter_test/flutter_test.dart';
import 'package:my_practice/core/config/my_practice_config.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

void main() {
  group('MyPracticeConfig', () {
    test('FeatureFlagKeys includes future modules', () {
      expect(FeatureFlagKeys.all, contains('ENABLE_CONNECT'));
      expect(FeatureFlagKeys.all, contains('ENABLE_AI_COPILOT'));
    });
  });

  group('FHIR models', () {
    test('FhirEncounter includes mandatory references', () {
      const encounter = FhirEncounter(
        id: 'enc-1',
        status: 'finished',
        patientId: 'pat-1',
        practitionerId: 'prac-1',
        facilityId: 'fac-1',
      );
      final json = encounter.toJson();
      expect(json['resourceType'], 'Encounter');
      expect(json['subject'], {'reference': 'Patient/pat-1'});
    });

    test('FhirMedicationRequest maps prescribing', () {
      const rx = FhirMedicationRequest(
        id: 'rx-1',
        medication: 'Metformin',
        patientId: 'pat-1',
        requesterId: 'prac-1',
        dosageInstruction: '500mg BD',
      );
      expect(rx.toJson()['resourceType'], 'MedicationRequest');
    });
  });

  group('Auth validators', () {
    test('normalizeZimbabwePhone formats local numbers', () {
      expect(normalizeZimbabwePhone('0771234567'), '+263771234567');
    });
  });
}
