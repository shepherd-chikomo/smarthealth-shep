import { collapseWhitespace, toTitleCase } from './normalize_data.js';

/**
 * Insert missing spaces in jammed address tokens (Excel / import artifacts).
 */
function insertAddressTokenSpaces(value: string): string {
  let s = value;

  // camelCase: LaneBorowdale -> Lane Borowdale
  s = s.replace(/([a-z])([A-Z])/g, '$1 $2');

  // digit then letter: 11Madokero -> 11 Madokero (skip ordinals: 3rd, 2nd)
  s = s.replace(/(\d)([A-Za-z])/g, (match, digit: string, _letter: string, offset: number) => {
    const tail = s.slice(offset + digit.length);
    if (/^(st|nd|rd|th)\b/i.test(tail)) return match;
    return `${digit} ${_letter}`;
  });

  // letter then digit: 106Jason -> 106 Jason (skip when digit starts an ordinal suffix)
  s = s.replace(/([A-Za-z])(\d)/g, (match, letter: string, digit: string, offset: number) => {
    const tail = s.slice(offset + match.length - 1);
    if (/^\d(st|nd|rd|th)\b/i.test(tail)) return match;
    return `${letter} ${digit}`;
  });

  return s;
}

function normalizeAddressPunctuation(value: string): string {
  return value
    .replace(/\s*,\s*/g, ', ')
    .replace(/\s+/g, ' ')
    .trim();
}

export function formatAddressLine(raw: string): string {
  if (!raw) return '';

  const collapsed = collapseWhitespace(raw);
  const spaced = normalizeAddressPunctuation(insertAddressTokenSpaces(collapsed));
  return toTitleCase(spaced);
}

export function needsAddressFormatting(raw: string): boolean {
  if (!raw?.trim()) return false;
  return formatAddressLine(raw) !== raw.trim();
}
