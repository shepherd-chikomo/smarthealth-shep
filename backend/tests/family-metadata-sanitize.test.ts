import { describe, expect, it } from 'vitest';
import {
  mergeMetadata,
  metadataForResponse,
  metadataForStorage,
  normalizeFamilyRelationship,
  sanitizeMetadataInput,
} from '../src/lib/family-metadata.js';

describe('family metadata sanitization', () => {
  it('drops invalid medication rows and UUIDs', () => {
    const sanitized = sanitizeMetadataInput({
      bloodGroup: 'O+',
      medications: [{ name: '  Metformin  ', frequency: 'BD' }, { name: '   ' }],
      primaryProvider: {
        facilityId: 'not-a-uuid',
        providerId: '550e8400-e29b-41d4-a716-446655440000',
        doctorName: 'Dr. Ncube',
      },
    });

    expect(sanitized.bloodGroup).toBe('O+');
    expect(sanitized.medications).toEqual([{ name: 'Metformin', frequency: 'BD' }]);
    expect(sanitized.primaryProvider).toEqual({
      providerId: '550e8400-e29b-41d4-a716-446655440000',
      doctorName: 'Dr. Ncube',
    });
  });

  it('returns schema-safe metadata for legacy DB payloads', () => {
    const response = metadataForResponse({
      medications: [{ frequency: 'BD' }],
      primaryProvider: { facilityName: 'ABC Clinic' },
    });

    expect(response).toEqual({
      medications: [],
      primaryProvider: { facilityName: 'ABC Clinic' },
    });
  });

  it('stores metadata as JSON text', () => {
    expect(metadataForStorage({ bloodGroup: 'A+' })).toBe(
      JSON.stringify({ bloodGroup: 'A+', medications: [] }),
    );
  });

  it('merges nested objects and sanitizes the result', () => {
    const merged = mergeMetadata(
      { bloodGroup: 'O+', medications: [] },
      {
        emergencyContact: { name: 'Mary Doe' },
        medications: [{ name: 'Amlodipine' }],
      },
    );

    expect(merged.bloodGroup).toBe('O+');
    expect(merged.emergencyContact).toEqual({ name: 'Mary Doe' });
    expect(merged.medications).toEqual([{ name: 'Amlodipine' }]);
  });

  it('maps unsupported relationships to other', () => {
    expect(normalizeFamilyRelationship('guardian')).toBe('other');
    expect(normalizeFamilyRelationship('self')).toBe('self');
  });
});
