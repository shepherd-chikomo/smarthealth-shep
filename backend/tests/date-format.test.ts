import { describe, expect, it } from 'vitest';
import { formatDateOnly } from '../src/lib/date-format.js';

describe('formatDateOnly', () => {
  it('formats PostgreSQL Date objects as YYYY-MM-DD', () => {
    expect(formatDateOnly(new Date(Date.UTC(1992, 4, 15)))).toBe('1992-05-15');
  });

  it('passes through date strings', () => {
    expect(formatDateOnly('1992-05-15')).toBe('1992-05-15');
  });

  it('returns null for empty values', () => {
    expect(formatDateOnly(null)).toBeNull();
    expect(formatDateOnly('')).toBeNull();
  });
});
