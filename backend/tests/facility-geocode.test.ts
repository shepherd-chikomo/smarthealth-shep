import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { GeocodeResult } from '../src/import/types.js';

const mockQuery = vi.fn();
const mockRelease = vi.fn();
const mockGeocodeFacilityInput = vi.fn();

vi.mock('../src/lib/db.js', () => ({
  pool: {
    connect: vi.fn(async () => ({
      query: mockQuery,
      release: mockRelease,
    })),
  },
}));

vi.mock('../src/import/geocode.js', async (importOriginal) => {
  const actual = await importOriginal<typeof import('../src/import/geocode.js')>();
  return {
    ...actual,
    geocodeFacilityInput: (...args: unknown[]) => mockGeocodeFacilityInput(...args),
  };
});

const { geocodeFacilityRecord } = await import('../src/lib/facility-geocode.js');

const sampleGeo: GeocodeResult = {
  latitude: -17.83,
  longitude: 31.05,
  formattedAddress: '11 Lanark Road, Harare, Zimbabwe',
  fromCache: false,
  quality: 'address',
  provider: 'nominatim',
};

describe('geocodeFacilityRecord', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockQuery.mockResolvedValue({ rows: [] });
  });

  it('returns early when address and city are both missing', async () => {
    const result = await geocodeFacilityRecord({
      facilityId: 'fac-1',
      name: 'Clinic',
      addressLine1: null,
      city: null,
      province: 'Harare',
    });

    expect(result.geocoded).toBe(false);
    expect(mockGeocodeFacilityInput).not.toHaveBeenCalled();
  });

  it('updates coordinates when geocode lookup succeeds', async () => {
    mockGeocodeFacilityInput.mockResolvedValue(sampleGeo);

    const result = await geocodeFacilityRecord({
      facilityId: 'fac-1',
      name: 'Test Clinic',
      addressLine1: '11 Lanark Road',
      city: 'Harare',
      province: 'Harare',
    });

    expect(result.geocoded).toBe(true);
    expect(result.quality).toBe('address');
    expect(mockQuery).toHaveBeenCalledWith(
      expect.stringContaining('UPDATE public.facilities'),
      expect.arrayContaining([-17.83, 31.05, '11 Lanark Road, Harare, Zimbabwe', 'address', 'fac-1']),
    );
    expect(mockRelease).toHaveBeenCalled();
  });

  it('does not clear coordinates on create when lookup fails', async () => {
    mockGeocodeFacilityInput.mockResolvedValue(null);

    const result = await geocodeFacilityRecord({
      facilityId: 'fac-2',
      name: 'Unknown Clinic',
      addressLine1: 'Nowhere',
      city: 'Harare',
      province: 'Harare',
      clearOnFailure: false,
    });

    expect(result.geocoded).toBe(false);
    const updateCalls = mockQuery.mock.calls.filter((call) =>
      String(call[0]).includes('UPDATE public.facilities'),
    );
    expect(updateCalls).toHaveLength(0);
  });

  it('clears coordinates when lookup fails and clearOnFailure is set', async () => {
    mockGeocodeFacilityInput.mockResolvedValue(null);

    const result = await geocodeFacilityRecord({
      facilityId: 'fac-3',
      name: 'Moved Clinic',
      addressLine1: 'Invalid address',
      city: 'Unknown City',
      province: 'Harare',
      clearOnFailure: true,
    });

    expect(result.geocoded).toBe(false);
    expect(mockQuery).toHaveBeenCalledWith(
      expect.stringContaining('latitude = NULL'),
      ['fac-3'],
    );
  });

  it('does not throw when geocode lookup throws', async () => {
    mockGeocodeFacilityInput.mockRejectedValue(new Error('Nominatim unavailable'));

    const result = await geocodeFacilityRecord({
      facilityId: 'fac-4',
      name: 'Clinic',
      addressLine1: '1 Main St',
      city: 'Harare',
      province: 'Harare',
    });

    expect(result.geocoded).toBe(false);
    expect(mockRelease).toHaveBeenCalled();
  });
});
