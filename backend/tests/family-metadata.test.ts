import { describe, expect, it } from 'vitest';
import { emergencyMedicalMetadataSchema } from '../src/schemas/common.js';

describe('emergencyMedicalMetadataSchema', () => {
  it('parses emergency profile metadata', () => {
    const parsed = emergencyMedicalMetadataSchema.parse({
      bloodGroup: 'O+',
      medications: [
        { name: 'Metformin 500mg', frequency: 'BD' },
        { name: 'Amlodipine 5mg', frequency: 'OD' },
      ],
      emergencyContact: {
        name: 'Mary Doe',
        relationship: 'Wife',
        phone: '+263771234567',
      },
      medicalAid: {
        provider: 'CIMAS',
        memberNumber: '12345678',
      },
      primaryProvider: {
        facilityName: 'ABC Medical Centre',
        doctorName: 'Dr. T. Ncube',
        phone: '+263242123456',
      },
    });

    expect(parsed.bloodGroup).toBe('O+');
    expect(parsed.medications).toHaveLength(2);
    expect(parsed.emergencyContact?.name).toBe('Mary Doe');
    expect(parsed.medicalAid?.provider).toBe('CIMAS');
    expect(parsed.primaryProvider?.facilityName).toBe('ABC Medical Centre');
  });
});
