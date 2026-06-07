import { describe, expect, it } from 'vitest';
import { listMedicalAidCatalog } from '../src/services/catalog.service.js';

describe('listMedicalAidCatalog', () => {
  it('returns default schemes when catalog is empty', async () => {
    const result = await listMedicalAidCatalog();
    expect(result.schemes.length).toBeGreaterThan(0);
    expect(result.schemes.some((s) => s.schemeKey === 'cimas')).toBe(true);
  });
});
