import { describe, expect, it } from 'vitest';
import {
  buildCityOnlyQuery,
  buildFacilityAddressQuery,
  buildNameCityQuery,
  haversineKm,
  isWithinZimbabwe,
  scoreNominatimHit,
  type NominatimHit,
} from '../src/import/geocode.js';

describe('buildFacilityAddressQuery', () => {
  it('builds address-first query without facility name by default', () => {
    const query = buildFacilityAddressQuery({
      name: 'Sachikonye / Wazara Surgery',
      addressLine1: '11 Lanark Road',
      city: 'Harare',
      province: 'Harare',
    });

    expect(query).toBe('11 Lanark Road, Harare, Harare, Zimbabwe');
    expect(query).not.toContain('Wazara');
  });

  it('includes facility name when includeName is set', () => {
    const query = buildFacilityAddressQuery(
      {
        name: 'Sachikonye / Wazara Surgery',
        addressLine1: '11 Lanark Road',
        city: 'Harare',
        province: 'Harare',
      },
      { includeName: true },
    );

    expect(query).toBe(
      'Sachikonye / Wazara Surgery, 11 Lanark Road, Harare, Harare, Zimbabwe',
    );
  });

  it('returns null when address and city are missing', () => {
    expect(
      buildFacilityAddressQuery({ name: 'Test Clinic', addressLine1: null, city: null }),
    ).toBeNull();
  });

  it('allows city-only query', () => {
    expect(
      buildFacilityAddressQuery({
        name: 'Clinic',
        addressLine1: null,
        city: 'Bulawayo',
        province: 'Bulawayo',
      }),
    ).toBe('Bulawayo, Bulawayo, Zimbabwe');
  });
});

describe('buildNameCityQuery', () => {
  it('builds name and city query', () => {
    expect(
      buildNameCityQuery({
        name: 'Avenues Clinic',
        city: 'Harare',
        province: 'Harare',
      }),
    ).toBe('Avenues Clinic, Harare, Harare, Zimbabwe');
  });
});

describe('buildCityOnlyQuery', () => {
  it('builds city-only query', () => {
    expect(
      buildCityOnlyQuery({ name: 'X', city: 'Mutare', province: 'Manicaland' }),
    ).toBe('Mutare, Manicaland, Zimbabwe');
  });
});

describe('isWithinZimbabwe', () => {
  it('accepts Harare coordinates', () => {
    expect(isWithinZimbabwe(-17.8252, 31.0335)).toBe(true);
  });

  it('accepts Bulawayo coordinates', () => {
    expect(isWithinZimbabwe(-20.1556, 28.5847)).toBe(true);
  });

  it('rejects coordinates outside Zimbabwe', () => {
    expect(isWithinZimbabwe(-33.8688, 151.2093)).toBe(false);
    expect(isWithinZimbabwe(51.5074, -0.1278)).toBe(false);
  });

  it('rejects coordinates at boundary edges', () => {
    expect(isWithinZimbabwe(-26, 31)).toBe(false);
    expect(isWithinZimbabwe(-17, 24)).toBe(false);
  });
});

describe('scoreNominatimHit', () => {
  const base: NominatimHit = {
    latitude: -17.82,
    longitude: 31.03,
    formattedAddress: 'Test',
    class: 'place',
    type: 'house',
    importance: 0.5,
    placeRank: 20,
  };

  it('prefers amenity healthcare over administrative place', () => {
    const clinic: NominatimHit = {
      ...base,
      class: 'amenity',
      type: 'clinic',
      importance: 0.45,
    };
    const city: NominatimHit = {
      ...base,
      class: 'place',
      type: 'city',
      importance: 0.6,
      placeRank: 8,
    };
    expect(scoreNominatimHit(clinic)).toBeGreaterThan(scoreNominatimHit(city));
  });
});

describe('haversineKm', () => {
  it('returns ~0 for same point', () => {
    expect(haversineKm(-17.8252, 31.0335, -17.8252, 31.0335)).toBeLessThan(0.01);
  });

  it('returns plausible Harare–CBD distance', () => {
    const km = haversineKm(-17.8252, 31.0335, -17.78, 31.05);
    expect(km).toBeGreaterThan(3);
    expect(km).toBeLessThan(15);
  });
});
