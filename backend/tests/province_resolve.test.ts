import { describe, expect, it } from 'vitest';
import {
  buildCityOnlyQuery,
  buildFacilityAddressQuery,
  buildNameCityQuery,
} from '../src/import/geocode.js';
import {
  inferProvinceFromCitySync,
  isUntrustedProvince,
  normalizeOsmState,
  provinceForGeocodeQuery,
} from '../src/import/province_resolve.js';

describe('inferProvinceFromCitySync', () => {
  it('maps known cities without defaulting to Harare', () => {
    expect(inferProvinceFromCitySync('Banket')).toBe('Mashonaland West');
    expect(inferProvinceFromCitySync('Harare')).toBe('Harare');
  });

  it('returns null for unknown cities', () => {
    expect(inferProvinceFromCitySync('Smallville')).toBeNull();
    expect(inferProvinceFromCitySync(null)).toBeNull();
  });
});

describe('isUntrustedProvince', () => {
  it('flags Harare province on non-metro cities', () => {
    expect(isUntrustedProvince('Banket', 'Harare')).toBe(true);
    expect(isUntrustedProvince('Harare', 'Harare')).toBe(false);
    expect(isUntrustedProvince('Chitungwiza', 'Harare')).toBe(false);
  });

  it('trusts non-Harare provinces', () => {
    expect(isUntrustedProvince('Banket', 'Mashonaland West')).toBe(false);
  });
});

describe('normalizeOsmState', () => {
  it('parses Nominatim state strings to enum values', () => {
    expect(normalizeOsmState('Mashonaland West Province')).toBe('Mashonaland West');
    expect(normalizeOsmState('Manicaland')).toBe('Manicaland');
    expect(normalizeOsmState('')).toBeNull();
  });
});

describe('provinceForGeocodeQuery', () => {
  it('omits untrusted Harare province for rural cities', () => {
    expect(provinceForGeocodeQuery('Banket', 'Harare')).toBeNull();
  });

  it('keeps trusted province values', () => {
    expect(provinceForGeocodeQuery('Banket', 'Mashonaland West')).toBe('Mashonaland West');
    expect(provinceForGeocodeQuery('Harare', 'Harare')).toBe('Harare');
  });
});

describe('geocode queries with province trust', () => {
  it('omits Harare from Banket facility query', () => {
    expect(
      buildFacilityAddressQuery({
        name: 'Ayrshire Mine Clinic',
        addressLine1: 'Ayrshire Mine',
        city: 'Banket',
        province: 'Harare',
      }),
    ).toBe('Ayrshire Mine, Banket, Zimbabwe');
  });

  it('includes province when trusted', () => {
    expect(
      buildFacilityAddressQuery({
        name: 'Ayrshire Mine Clinic',
        addressLine1: 'Ayrshire Mine',
        city: 'Banket',
        province: 'Mashonaland West',
      }),
    ).toBe('Ayrshire Mine, Banket, Mashonaland West, Zimbabwe');
  });

  it('omits untrusted province from name+city query', () => {
    expect(
      buildNameCityQuery({
        name: 'Ayrshire Mine Clinic',
        city: 'Banket',
        province: 'Harare',
      }),
    ).toBe('Ayrshire Mine Clinic, Banket, Zimbabwe');
  });

  it('omits untrusted province from city-only query', () => {
    expect(
      buildCityOnlyQuery({
        name: 'X',
        city: 'Banket',
        province: 'Harare',
      }),
    ).toBe('Banket, Zimbabwe');
  });
});
