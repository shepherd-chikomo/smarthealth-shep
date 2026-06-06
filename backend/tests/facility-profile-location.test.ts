import { beforeEach, describe, expect, it, vi } from 'vitest';

const mockQuery = vi.fn();
const mockRelease = vi.fn();
const mockApplyManual = vi.fn();
const mockGeocodeRecord = vi.fn();
const mockRequireFacilityAdmin = vi.fn();
const mockGetFacilityOrThrow = vi.fn();

vi.mock('../src/lib/db.js', () => ({
  query: (...args: unknown[]) => mockQuery(...args),
  withTransaction: vi.fn(),
}));

vi.mock('../src/lib/facility-access.js', () => ({
  assertFacilityAccess: vi.fn(),
  requireFacilityAdmin: (...args: unknown[]) => mockRequireFacilityAdmin(...args),
  getFacilityOrThrow: (...args: unknown[]) => mockGetFacilityOrThrow(...args),
}));

vi.mock('../src/lib/facility-geocode.js', () => ({
  applyManualFacilityCoordinates: (...args: unknown[]) => mockApplyManual(...args),
  geocodeFacilityRecord: (...args: unknown[]) => mockGeocodeRecord(...args),
}));

const { updateFacilityProfile } = await import('../src/services/facility.service.js');

const user = { id: 'user-1', email: 'admin@test.com', role: 'facility_admin' } as const;

const facilityRow = {
  id: 'fac-1',
  name: 'Test Hospital',
  slug: 'test-hospital',
  facility_type: 'hospital',
  facility_types: ['hospital'],
  description: null,
  address_line1: '19 Victoria Road',
  address_line2: null,
  city: 'Harare',
  province: 'Harare',
  postal_code: null,
  phone: null,
  email: null,
  website: null,
  latitude: -17.81,
  longitude: 31.07,
  geocode_quality: 'manual',
  is_verified: false,
  is_active: true,
  settings: {},
  created_at: new Date(),
  updated_at: new Date(),
};

describe('updateFacilityProfile location', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockRequireFacilityAdmin.mockResolvedValue(undefined);
    mockQuery
      .mockResolvedValueOnce({
        rows: [{ address_line1: '19 Victoria Road', city: 'Harare', province: 'Harare', name: 'Test Hospital' }],
      })
      .mockResolvedValueOnce({ rows: [facilityRow] });
    mockGetFacilityOrThrow.mockResolvedValue(facilityRow);
    mockApplyManual.mockResolvedValue(undefined);
    mockGeocodeRecord.mockResolvedValue({ geocoded: true, quality: 'address' });
  });

  it('applies manual coordinates when locationMode is manual', async () => {
    await updateFacilityProfile(user, 'fac-1', {
      latitude: -17.82,
      longitude: 31.08,
      locationMode: 'manual',
    });

    expect(mockApplyManual).toHaveBeenCalledWith('fac-1', -17.82, 31.08);
    expect(mockGeocodeRecord).not.toHaveBeenCalled();
  });

  it('auto-geocodes when address changes without manual mode', async () => {
    mockQuery.mockReset();
    mockQuery
      .mockResolvedValueOnce({
        rows: [{ address_line1: '19 Victoria Road', city: 'Harare', province: 'Harare', name: 'Test Hospital' }],
      })
      .mockResolvedValueOnce({
        rows: [{ ...facilityRow, address_line1: '20 Victoria Road' }],
      });

    await updateFacilityProfile(user, 'fac-1', {
      addressLine1: '20 Victoria Road',
    });

    expect(mockGeocodeRecord).toHaveBeenCalledWith(
      expect.objectContaining({
        facilityId: 'fac-1',
        addressLine1: '20 Victoria Road',
        clearOnFailure: true,
      }),
    );
    expect(mockApplyManual).not.toHaveBeenCalled();
  });

  it('skips auto-geocode when manual coords are sent with address change', async () => {
    await updateFacilityProfile(user, 'fac-1', {
      addressLine1: '20 Victoria Road',
      latitude: -17.82,
      longitude: 31.08,
      locationMode: 'manual',
    });

    expect(mockApplyManual).toHaveBeenCalledWith('fac-1', -17.82, 31.08);
    expect(mockGeocodeRecord).not.toHaveBeenCalled();
  });

  it('auto-geocodes when locationMode is geocode after address change', async () => {
    await updateFacilityProfile(user, 'fac-1', {
      city: 'Bulawayo',
      locationMode: 'geocode',
    });

    expect(mockGeocodeRecord).toHaveBeenCalled();
    expect(mockApplyManual).not.toHaveBeenCalled();
  });
});
