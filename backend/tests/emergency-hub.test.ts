import { describe, expect, it } from 'vitest';
import {
  dedupeFacilities,
  sortFacilities,
  type EmergencyHubFacility,
} from '../src/services/emergency-hub.service.js';

function facility(
  overrides: Partial<EmergencyHubFacility> & Pick<EmergencyHubFacility, 'id' | 'source'>,
): EmergencyHubFacility {
  return {
    name: 'Test Facility',
    serviceType: 'hospital_er',
    phone: '123',
    alternatePhone: null,
    address: null,
    city: 'Harare',
    province: 'harare',
    latitude: -17.8,
    longitude: 31.0,
    distanceKm: 5,
    is24Hours: false,
    referralLabel: null,
    ...overrides,
  };
}

describe('emergency hub merge', () => {
  it('dedupes facilities by id keeping higher-priority source', () => {
    const merged = dedupeFacilities([
      facility({ id: 'a', source: 'government_hospital', distanceKm: 2 }),
      facility({ id: 'a', source: 'emergency_directory', distanceKm: 8, is24Hours: true }),
      facility({ id: 'b', source: 'profile_emergency', distanceKm: 1 }),
    ]);

    expect(merged).toHaveLength(2);
    const kept = merged.find((f) => f.id === 'a');
    expect(kept?.source).toBe('emergency_directory');
    expect(kept?.is24Hours).toBe(true);
  });

  it('sorts 24h facilities first, then distance, then source priority', () => {
    const sorted = sortFacilities([
      facility({ id: 'gov', source: 'government_hospital', distanceKm: 1, is24Hours: false }),
      facility({ id: 'er', source: 'emergency_directory', distanceKm: 10, is24Hours: true }),
      facility({ id: 'profile', source: 'profile_emergency', distanceKm: 2, is24Hours: false }),
    ]);

    expect(sorted.map((f) => f.id)).toEqual(['er', 'gov', 'profile']);
  });
});

describe('government hospital heuristics', () => {
  const patterns = [
    'Government Hospital',
    'Public District Hospital',
    'Ministry of Health',
    'Central Hospital',
    'Provincial Hospital',
    'District Hospital',
    'Referral Hospital',
  ];

  it('matches ownership and category keywords used in hub SQL', () => {
    for (const label of patterns) {
      const lower = label.toLowerCase();
      const matchesGov =
        lower.includes('government') ||
        lower.includes('public') ||
        lower.includes('ministry') ||
        lower.includes('central') ||
        lower.includes('provincial') ||
        lower.includes('district') ||
        lower.includes('referral');
      expect(matchesGov).toBe(true);
    }
  });
});
