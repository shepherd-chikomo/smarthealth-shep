import { beforeEach, describe, expect, it, vi } from 'vitest';

const mockQuery = vi.fn();

vi.mock('../src/lib/db.js', () => ({
  query: (...args: unknown[]) => mockQuery(...args),
}));

const { parseProfileSettings } = await import('../src/lib/facility-profile-settings.js');
const { getPublicProfile } = await import('../src/services/facility-public-profile.service.js');

describe('buildFacilityLogoUrl', () => {
  it('uses SUPABASE_PUBLIC_URL for browser-accessible logo URLs', async () => {
    vi.stubEnv('SUPABASE_URL', 'http://kong:8000');
    vi.stubEnv('SUPABASE_PUBLIC_URL', 'https://dev.smarthealth.co.zw');
    vi.resetModules();
    const { buildFacilityLogoUrl } = await import('../src/lib/facility-assets.js');
    const url = buildFacilityLogoUrl('fac-1/logo/test.png');
    expect(url).toBe(
      'https://dev.smarthealth.co.zw/storage/v1/object/public/facility-assets/fac-1/logo/test.png',
    );
    vi.unstubAllEnvs();
    vi.resetModules();
  });
});

describe('facility profile settings', () => {
  it('parses empty profile defaults', () => {
    const profile = parseProfileSettings(undefined);
    expect(profile.services).toEqual([]);
    expect(profile.booking.enabled).toBeUndefined();
  });

  it('merges services from stored settings', () => {
    const profile = parseProfileSettings({
      services: [
        {
          id: 'a1b2c3d4-e5f6-4789-a012-3456789abcde',
          name: 'General Practice',
          iconKey: 'gp',
          isCustom: false,
        },
      ],
      booking: { enabled: true, showSlots: true },
    });
    expect(profile.services).toHaveLength(1);
    expect(profile.booking.enabled).toBe(true);
  });
});

describe('getPublicProfile', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns public-safe profile payload', async () => {
    mockQuery
      .mockResolvedValueOnce({
        rows: [
          {
            id: 'fac-1',
            name: 'Newtown Hospital',
            slug: 'newtown-hospital',
            facility_type: 'hospital',
            facility_types: ['hospital'],
            description: 'Private hospital',
            address_line1: '19 Victoria Road',
            city: 'Harare',
            province: 'Harare',
            phone: '+263779999111',
            whatsapp_phone: '+263779999112',
            email: 'secret@hospital.co.zw',
            website: 'https://newtown.co.zw',
            latitude: '-17.81',
            longitude: '31.07',
            logo_path: 'fac-1/logo/test.png',
            is_verified: true,
            settings: {
              profile: {
                services: [
                  {
                    id: 'b2c3d4e5-f6a7-4890-b123-456789abcdef',
                    name: 'Emergency',
                    iconKey: 'emergency',
                    isCustom: false,
                  },
                ],
                medicalAids: [{ schemeKey: 'cimas', name: 'Cimas' }],
                accessibility: { wheelchair: true, parking: true },
                emergency: { department: true, is24Hour: true },
                smarthealthFeatures: { onlineBooking: true },
                booking: { enabled: true, showSlots: true },
              },
            },
            is_open_now: true,
          },
        ],
      })
      .mockResolvedValueOnce({
        rows: [
          {
            day_of_week: 1,
            opens_at: '08:00:00',
            closes_at: '17:00:00',
            is_closed: false,
            is_24_hours: false,
          },
        ],
      });

    const result = await getPublicProfile('fac-1', 3.4);

    expect(result.facility.name).toBe('Newtown Hospital');
    expect(result.facility.whatsappPhone).toBe('+263779999112');
    expect(result.facility.distanceKm).toBe(3.4);
    expect(result.logoUrl).toContain('fac-1/logo/test.png');
    expect(result.services).toHaveLength(1);
    expect(result.medicalAids[0]?.name).toBe('Cimas');
    expect(result.booking.enabled).toBe(true);
    expect(result.smarthealthFeatures.verified).toBe(true);
    expect((result as { settings?: unknown }).settings).toBeUndefined();
  });
});
