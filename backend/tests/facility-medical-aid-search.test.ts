import { describe, expect, it } from 'vitest';

function acceptsYourMedicalAid(
  acceptedKeys: string[],
  userSchemeKey?: string,
): boolean | undefined {
  const userScheme = userSchemeKey?.trim();
  if (!userScheme) return undefined;
  return acceptedKeys.includes(userScheme);
}

function matchesMedicalAidFilter(
  acceptedKeys: string[],
  filterKeys: string[],
): boolean {
  if (filterKeys.length === 0) return true;
  return filterKeys.some((key) => acceptedKeys.includes(key));
}

describe('facility medical aid search', () => {
  it('flags acceptsYourMedicalAid when user scheme is accepted', () => {
    expect(acceptsYourMedicalAid(['cimas', 'psmas'], 'cimas')).toBe(true);
    expect(acceptsYourMedicalAid(['psmas'], 'cimas')).toBe(false);
  });

  it('omits acceptsYourMedicalAid when user scheme is not provided', () => {
    expect(acceptsYourMedicalAid(['cimas'], undefined)).toBeUndefined();
    expect(acceptsYourMedicalAid(['cimas'], '   ')).toBeUndefined();
  });

  it('filters facilities accepting any listed scheme key', () => {
    expect(matchesMedicalAidFilter(['cimas'], ['cimas', 'psmas'])).toBe(true);
    expect(matchesMedicalAidFilter(['cellmed'], ['cimas', 'psmas'])).toBe(false);
    expect(matchesMedicalAidFilter(['cimas'], [])).toBe(true);
  });
});
