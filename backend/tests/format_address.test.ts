import { describe, expect, it } from 'vitest';
import {
  formatAddressLine,
  needsAddressFormatting,
} from '../src/import/format_address.js';

describe('formatAddressLine', () => {
  it('splits camelCase tokens', () => {
    expect(formatAddressLine('LaneBorowdale')).toBe('Lane Borowdale');
  });

  it('splits digit-letter boundaries', () => {
    expect(formatAddressLine('11Madokero')).toBe('11 Madokero');
    expect(formatAddressLine('106Jason')).toBe('106 Jason');
  });

  it('handles combined jammed segments', () => {
    expect(formatAddressLine('LaneBorowdale, 11Madokero 106Jason')).toBe(
      'Lane Borowdale, 11 Madokero 106 Jason',
    );
  });

  it('leaves well-formed addresses unchanged aside from title case', () => {
    expect(formatAddressLine('11 Lanark Road')).toBe('11 Lanark Road');
  });

  it('preserves ordinals', () => {
    expect(formatAddressLine('3rd Street')).toBe('3rd Street');
    expect(formatAddressLine('2nd Avenue')).toBe('2nd Avenue');
  });

  it('formats P.O. box style text', () => {
    const result = formatAddressLine('P.O. Box 123');
    expect(result).toMatch(/P\.O\./i);
    expect(result).toContain('123');
  });
});

describe('needsAddressFormatting', () => {
  it('detects jammed addresses', () => {
    expect(needsAddressFormatting('LaneBorowdale')).toBe(true);
    expect(needsAddressFormatting('11 Lanark Road')).toBe(false);
  });
});
