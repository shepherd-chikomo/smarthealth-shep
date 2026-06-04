import { describe, expect, it } from 'vitest';
import {
  inferFacilityTypeFromName,
  inferFacilityTypeFromSpecialtySignals,
  resolveFacilityType,
} from '../src/import/infer_facility_type.js';

describe('inferFacilityTypeFromName', () => {
  it('classifies hospitals from name', () => {
    expect(inferFacilityTypeFromName('Healthpoint Hospital')).toBe('hospital');
  });

  it('classifies pharmacies from name', () => {
    expect(inferFacilityTypeFromName('City Pharmacy')).toBe('pharmacy');
    expect(inferFacilityTypeFromName('Green Cross Chemist')).toBe('pharmacy');
  });

  it('returns null for generic surgery names', () => {
    expect(inferFacilityTypeFromName('Sachikonye / Wazara Surgery')).toBeNull();
    expect(inferFacilityTypeFromName('Dr Smith Medical Centre')).toBeNull();
  });

  it('does not match lab inside labour', () => {
    expect(inferFacilityTypeFromName('Labour Ward Unit')).toBeNull();
  });
});

describe('inferFacilityTypeFromSpecialtySignals', () => {
  it('maps dentistry to dental', () => {
    expect(inferFacilityTypeFromSpecialtySignals(['dentistry'])).toBe('dental');
  });

  it('returns null when only clinic-level specialties', () => {
    expect(
      inferFacilityTypeFromSpecialtySignals(['general-practice', 'cardiology']),
    ).toBeNull();
  });
});

describe('resolveFacilityType', () => {
  it('uses name over specialty when both present', () => {
    expect(
      resolveFacilityType({
        name: 'ABC Pharmacy',
        specialtyTexts: ['general-practice'],
      }),
    ).toBe('pharmacy');
  });

  it('uses specialty for generic surgery names', () => {
    expect(
      resolveFacilityType({
        name: 'Dr X Surgery',
        specialtyTexts: ['dentistry'],
      }),
    ).toBe('dental');
  });

  it('defaults to clinic', () => {
    expect(
      resolveFacilityType({
        name: 'Wellness Medical Centre',
      }),
    ).toBe('clinic');
  });
});
