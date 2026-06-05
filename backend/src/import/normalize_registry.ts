import { createHash } from 'node:crypto';
import { collapseWhitespace, toTitleCase } from './normalize_data.js';

const ADDRESS_ABBREVIATIONS: Record<string, string> = {
  st: 'street',
  str: 'street',
  rd: 'road',
  ave: 'avenue',
  av: 'avenue',
  blvd: 'boulevard',
  dr: 'drive',
  ln: 'lane',
  ct: 'court',
  pl: 'place',
  cnr: 'corner',
  ext: 'extension',
};

export function normalizeAddress(value: string | null | undefined): string {
  if (!value) return '';
  let normalized = collapseWhitespace(value).toLowerCase();
  normalized = normalized.replace(/\b(\w+)\./g, '$1');
  const words = normalized.split(' ').map((word) => ADDRESS_ABBREVIATIONS[word] ?? word);
  return words.join(' ');
}

export function normalizePersonName(value: string | null | undefined): string {
  if (!value) return '';
  return collapseWhitespace(value).toLowerCase();
}

export function buildFullNameKey(firstName: string | null, lastName: string | null): string {
  return normalizePersonName([firstName, lastName].filter(Boolean).join(' '));
}

/** HPA uses first-last while MDPCZ register often lists last-first — try both orderings. */
export function reverseNameKey(key: string): string {
  const parts = normalizePersonName(key).split(' ').filter(Boolean);
  if (parts.length < 2) return key;
  return parts.reverse().join(' ');
}

export function buildFacilityRegistryKey(
  name: string,
  address: string | null,
  city: string | null,
): string {
  const parts = [
    normalizePersonName(name),
    normalizeAddress(address),
    normalizePersonName(city),
  ];
  return createHash('sha256').update(parts.join('|')).digest('hex').slice(0, 32);
}

/** Location dedup key used when detecting ambiguous HPA facility groups. */
export function buildLocationDedupKey(
  facilityName: string,
  address: string,
  city: string | null | undefined,
): string {
  return `${normalizeAddress(facilityName)}|${normalizeAddress(address)}|${normalizeAddress(city ?? '')}`;
}

/** Registry key when the same address hosts multiple distinct role-holders. */
export function buildFacilityRegistryKeyWithRoleHolder(
  name: string,
  address: string | null,
  city: string | null,
  roleHolderKey: string,
): string {
  const parts = [
    normalizePersonName(name),
    normalizeAddress(address),
    normalizePersonName(city),
    normalizePersonName(roleHolderKey),
  ];
  return createHash('sha256').update(parts.join('|')).digest('hex').slice(0, 32);
}

export function normalizeMdpczNumber(raw: string): string {
  return collapseWhitespace(raw)
    .toUpperCase()
    .replace(/\s+/g, '')
    .replace(/[^A-Z0-9-]/g, '');
}

export function buildProviderRegistryKey(registrationNumber: string): string {
  return createHash('sha256')
    .update(normalizeMdpczNumber(registrationNumber))
    .digest('hex')
    .slice(0, 32);
}

export function formatFacilityName(raw: string): string {
  return toTitleCase(raw);
}

export function formatCity(raw: string | null): string | null {
  if (!raw) return null;
  return toTitleCase(raw);
}

export {
  inferProvinceFromCity,
  inferProvinceFromCitySync,
  isUntrustedProvince,
  provinceForGeocodeQuery,
  provinceInsertFallback,
  resolveProvinceFromCity,
} from './province_resolve.js';

export function requireCity(city: string | null): string {
  return city?.trim() ? toTitleCase(city) : 'Unknown';
}
