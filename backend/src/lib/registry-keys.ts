import { createHash } from 'node:crypto';

function collapseWhitespace(value: string): string {
  return value.trim().replace(/\s+/g, ' ');
}

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

export function buildLocationDedupKey(
  facilityName: string,
  address: string,
  city: string | null | undefined,
): string {
  return `${normalizeAddress(facilityName)}|${normalizeAddress(address)}|${normalizeAddress(city ?? '')}`;
}

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

export function parseHpaRawRow(raw: Record<string, unknown>): {
  facilityName: string;
  address: string;
  city: string | null;
  practitionerFirstName: string | null;
  practitionerLastName: string | null;
  normalizedNameKey: string;
} {
  const facilityName = raw.facilityName ? String(raw.facilityName).trim() : '';
  const address = raw.address ? String(raw.address).trim() : '';
  const city = raw.city ? String(raw.city).trim() : null;
  const practitionerFirstName = raw.practitionerFirstName
    ? String(raw.practitionerFirstName).trim()
    : raw.practitionerName
      ? String(raw.practitionerName).split(/\s+/)[0] ?? null
      : null;
  const practitionerLastName = raw.practitionerLastName
    ? String(raw.practitionerLastName).trim()
    : null;
  return {
    facilityName,
    address,
    city,
    practitionerFirstName,
    practitionerLastName,
    normalizedNameKey: buildFullNameKey(practitionerFirstName, practitionerLastName),
  };
}

export function locationDedupKeyFromRawRows(rawRows: Record<string, unknown>[]): string | null {
  if (rawRows.length === 0) return null;
  const first = parseHpaRawRow(rawRows[0]);
  if (!first.facilityName || !first.address) return null;
  return buildLocationDedupKey(first.facilityName, first.address, first.city);
}
