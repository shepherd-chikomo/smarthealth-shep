import { describe, expect, it } from 'vitest';
import { mergeMetadata, normalizeMetadata } from '../src/lib/family-metadata.js';

describe('family metadata merge', () => {
  it('merges nested emergency contact without dropping blood group', () => {
    const merged = mergeMetadata(
      { bloodGroup: 'O+', medications: [] },
      {
        emergencyContact: {
          name: 'Mary Doe',
          phone: '+263771234567',
        },
      },
    );

    expect(merged.bloodGroup).toBe('O+');
    expect((merged.emergencyContact as { name?: string }).name).toBe('Mary Doe');
  });

  it('normalizes stringified metadata payloads', () => {
    const parsed = normalizeMetadata('{"bloodGroup":"A+"}');
    expect(parsed.bloodGroup).toBe('A+');
  });
});
