import { describe, expect, it } from 'vitest';
import {
  effectiveFacilityTypes,
  normalizeFacilityTypes,
  parseFacilityTypesField,
  sqlFacilityMatchesType,
} from '../src/lib/facility-types.js';

describe('normalizeFacilityTypes', () => {
  it('dedupes and preserves order', () => {
    expect(normalizeFacilityTypes(['dental', 'clinic', 'dental'])).toEqual(['dental', 'clinic']);
  });

  it('rejects empty selection', () => {
    expect(() => normalizeFacilityTypes([])).toThrow(/at least one/i);
  });

  it('rejects invalid values', () => {
    expect(() => normalizeFacilityTypes(['not-a-type'])).toThrow(/invalid/i);
  });
});

describe('effectiveFacilityTypes', () => {
  it('uses facility_types when set', () => {
    expect(
      effectiveFacilityTypes({ facility_type: 'clinic', facility_types: ['dental', 'clinic'] }),
    ).toEqual(['dental', 'clinic']);
  });

  it('falls back to primary facility_type', () => {
    expect(effectiveFacilityTypes({ facility_type: 'pharmacy', facility_types: [] })).toEqual([
      'pharmacy',
    ]);
  });

  it('parses Postgres text array representation from node-pg', () => {
    expect(
      effectiveFacilityTypes({ facility_type: 'clinic', facility_types: '{pharmacy,dental}' }),
    ).toEqual(['pharmacy', 'dental']);
  });
});

describe('parseFacilityTypesField', () => {
  it('handles null and empty', () => {
    expect(parseFacilityTypesField(null)).toEqual([]);
    expect(parseFacilityTypesField('{}')).toEqual([]);
  });
});

describe('sqlFacilityMatchesType', () => {
  it('matches primary or array membership', () => {
    expect(sqlFacilityMatchesType('f', '$4')).toContain('f.facility_type = $4');
    expect(sqlFacilityMatchesType('f', '$4')).toContain('ANY(f.facility_types)');
  });
});
