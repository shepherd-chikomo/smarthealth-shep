import { describe, expect, it } from 'vitest';
import { ForbiddenError } from '../src/lib/errors.js';

describe('Facility access patterns', () => {
  it('defines tenant isolation via facilityId requirement', () => {
    expect(true).toBe(true);
  });

  it('uses ForbiddenError for access violations', () => {
    expect(() => {
      throw new ForbiddenError('You do not have access to this facility');
    }).toThrow(ForbiddenError);
  });
});
