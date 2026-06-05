import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { passesGeocodePlausibility } from '../src/import/geocode.js';
import {
  distanceBetweenResults,
  scoreGoogleHit,
  type GoogleGeocodeHit,
} from '../src/import/geocode-google.js';
import type { GeocodeResult } from '../src/import/types.js';

describe('scoreGoogleHit', () => {
  const baseHit: GoogleGeocodeHit = {
    latitude: -17.8,
    longitude: 31.0,
    formattedAddress: 'Harare, Zimbabwe',
    locationType: 'ROOFTOP',
    types: ['hospital', 'point_of_interest'],
    partialMatch: false,
  };

  it('prefers rooftop and healthcare types', () => {
    const rooftop = scoreGoogleHit(baseHit);
    const approximate = scoreGoogleHit({
      ...baseHit,
      locationType: 'APPROXIMATE',
      types: ['locality'],
    });
    expect(rooftop).toBeGreaterThan(approximate);
  });

  it('penalizes partial matches', () => {
    const full = scoreGoogleHit(baseHit);
    const partial = scoreGoogleHit({ ...baseHit, partialMatch: true });
    expect(full).toBeGreaterThan(partial);
  });
});

describe('passesGeocodePlausibility', () => {
  const centroid = { lat: -17.83, lon: 31.05 };

  it('allows address results near city centroid', () => {
    expect(passesGeocodePlausibility(-17.84, 31.06, 'address', centroid)).toBe(true);
  });

  it('rejects address results far from city centroid', () => {
    expect(passesGeocodePlausibility(-18.5, 32.0, 'address', centroid)).toBe(false);
  });

  it('allows city_only without centroid distance check', () => {
    expect(passesGeocodePlausibility(-18.5, 32.0, 'city_only', centroid)).toBe(true);
  });
});

describe('distanceBetweenResults', () => {
  it('returns null when either result is missing', () => {
    const a: GeocodeResult = {
      latitude: -17.8,
      longitude: 31.0,
      formattedAddress: 'A',
      fromCache: false,
    };
    expect(distanceBetweenResults(a, null)).toBeNull();
    expect(distanceBetweenResults(null, a)).toBeNull();
  });

  it('returns zero for identical coordinates', () => {
    const a: GeocodeResult = {
      latitude: -17.8,
      longitude: 31.0,
      formattedAddress: 'A',
      fromCache: false,
    };
    const b: GeocodeResult = { ...a, formattedAddress: 'B' };
    expect(distanceBetweenResults(a, b)).toBe(0);
  });
});

describe('Google geocoding API parsing', () => {
  const originalFetch = globalThis.fetch;

  beforeEach(() => {
    vi.stubEnv('DATABASE_URL', 'postgresql://postgres:postgres@127.0.0.1:54322/postgres');
    vi.stubEnv('SUPABASE_URL', 'http://127.0.0.1:54321');
    vi.stubEnv('SUPABASE_ANON_KEY', 'test-anon-key');
    vi.stubEnv('SUPABASE_JWT_SECRET', 'test-jwt-secret-for-tests-only!!');
    vi.stubEnv('SUPABASE_SERVICE_ROLE_KEY', 'test-service-role-key');
    vi.stubEnv('GOOGLE_MAPS_API_KEY', 'test-google-key');
  });

  afterEach(() => {
    globalThis.fetch = originalFetch;
    vi.unstubAllEnvs();
  });

  it('rejects geocode results outside Zimbabwe', async () => {
    globalThis.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({
        status: 'OK',
        results: [
          {
            formatted_address: 'Nairobi, Kenya',
            geometry: {
              location: { lat: -1.286389, lng: 36.817223 },
              location_type: 'APPROXIMATE',
            },
            types: ['locality'],
          },
        ],
      }),
    });

    const { geocodeGoogleFacilityInput } = await import('../src/import/geocode-google.js');
    const mockClient = {
      query: vi.fn().mockResolvedValue({ rows: [] }),
    } as unknown as import('pg').PoolClient;

    const result = await geocodeGoogleFacilityInput(
      mockClient,
      {
        name: 'Test Clinic',
        addressLine1: '123 Main St',
        city: 'Harare',
        province: 'Harare',
      },
      { get: () => null },
      false,
    );

    expect(result).toBeNull();
  });
});
