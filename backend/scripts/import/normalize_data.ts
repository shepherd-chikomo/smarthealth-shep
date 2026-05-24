import { createHash } from 'node:crypto';
import type { ParsedName, RawSpreadsheetRow, NormalizedProvider, VerifiedSource } from './types.js';

const TITLES = new Set(['dr', 'prof', 'professor', 'mr', 'mrs', 'ms', 'miss', 'sister', 'sr', 'rev']);

const CITY_ALIASES: Record<string, string> = {
  'harare cbd': 'Harare',
  harare: 'Harare',
  'capital city': 'Harare',
  bulawayo: 'Bulawayo',
  'byo': 'Bulawayo',
  mutare: 'Mutare',
  umtali: 'Mutare',
  gweru: 'Gweru',
  gwelo: 'Gweru',
  masvingo: 'Masvingo',
  'fort victoria': 'Masvingo',
  chinhoyi: 'Chinhoyi',
  sinoia: 'Chinhoyi',
  kwekwe: 'Kwekwe',
  queque: 'Kwekwe',
  kadoma: 'Kadoma',
  gatooma: 'Kadoma',
  chitungwiza: 'Chitungwiza',
  marondera: 'Marondera',
  'victoria falls': 'Victoria Falls',
  hwange: 'Hwange',
  wankie: 'Hwange',
  rusape: 'Rusape',
  norton: 'Norton',
  beitbridge: 'Beitbridge',
  bindura: 'Bindura',
  zvishavane: 'Zvishavane',
  epworth: 'Epworth',
};

const PROVINCE_ALIASES: Record<string, string> = {
  harare: 'Harare',
  bulawayo: 'Bulawayo',
  manicaland: 'Manicaland',
  'mashonaland central': 'Mashonaland Central',
  'mash central': 'Mashonaland Central',
  'mashonaland east': 'Mashonaland East',
  'mash east': 'Mashonaland East',
  'mashonaland west': 'Mashonaland West',
  'mash west': 'Mashonaland West',
  masvingo: 'Masvingo',
  'matabeleland north': 'Matabeleland North',
  'mat north': 'Matabeleland North',
  'matabeleland south': 'Matabeleland South',
  'mat south': 'Matabeleland South',
  midlands: 'Midlands',
};

export function collapseWhitespace(value: string): string {
  return value.replace(/\s+/g, ' ').trim();
}

export function toTitleCase(value: string): string {
  return collapseWhitespace(value)
    .split(' ')
    .map((word) => {
      const lower = word.toLowerCase();
      if (TITLES.has(lower.replace(/\./g, ''))) {
        return lower.charAt(0).toUpperCase() + lower.slice(1).replace(/^(\w)/, (m) => m.toUpperCase());
      }
      if (word.length <= 3 && word === word.toUpperCase()) return word;
      return lower.charAt(0).toUpperCase() + lower.slice(1);
    })
    .join(' ');
}

export function parseName(rawName: string | null): ParsedName | null {
  if (!rawName) return null;
  let name = collapseWhitespace(rawName);
  if (!name) return null;

  let title: string | null = null;
  const titleMatch = name.match(/^((?:Dr|Prof|Professor|Mr|Mrs|Ms|Miss|Sister|Sr|Rev)\.?)\s+/i);
  if (titleMatch) {
    title = toTitleCase(titleMatch[1].replace(/\.$/, ''));
    name = name.slice(titleMatch[0].length).trim();
  }

  const parts = name.split(/\s+/).filter(Boolean);
  if (parts.length === 0) return null;

  if (parts.length === 1) {
    return {
      title,
      firstName: toTitleCase(parts[0]),
      middleName: null,
      lastName: parts[0],
      fullName: title ? `${title} ${toTitleCase(parts[0])}` : toTitleCase(parts[0]),
    };
  }

  const firstName = toTitleCase(parts[0]);
  const lastName = toTitleCase(parts[parts.length - 1]);
  const middleName = parts.length > 2 ? toTitleCase(parts.slice(1, -1).join(' ')) : null;
  const fullName = title
    ? `${title} ${[firstName, middleName, lastName].filter(Boolean).join(' ')}`
    : [firstName, middleName, lastName].filter(Boolean).join(' ');

  return { title, firstName, middleName, lastName, fullName };
}

export function normalizeCity(raw: string | null): string | null {
  if (!raw) return null;
  const key = raw.trim().toLowerCase();
  return CITY_ALIASES[key] ?? toTitleCase(raw);
}

export function normalizeProvince(raw: string | null, city: string | null): string | null {
  if (raw) {
    const key = raw.trim().toLowerCase();
    if (PROVINCE_ALIASES[key]) return PROVINCE_ALIASES[key];
    const matched = Object.entries(PROVINCE_ALIASES).find(([alias]) => key.includes(alias));
    if (matched) return matched[1];
    return toTitleCase(raw);
  }

  const cityProvinceMap: Record<string, string> = {
    Harare: 'Harare',
    Bulawayo: 'Bulawayo',
    Chitungwiza: 'Harare',
    Epworth: 'Harare',
  };
  if (city && cityProvinceMap[city]) return cityProvinceMap[city];
  return null;
}

export function normalizePhoneLocal(raw: string | null): string | null {
  if (!raw) return null;
  let digits = raw.replace(/[^\d+]/g, '');
  if (!digits) return null;

  if (digits.startsWith('+263')) return digits;
  if (digits.startsWith('263')) return `+${digits}`;
  if (digits.startsWith('0') && digits.length >= 10) return `+263${digits.slice(1)}`;
  if (digits.length === 9) return `+263${digits}`;

  return digits.startsWith('+') ? digits : `+${digits}`;
}

export function parseGps(raw: string | null): { lat: number | null; lng: number | null } {
  if (!raw) return { lat: null, lng: null };
  const cleaned = raw.replace(/[^\d.,-\s]/g, ' ').trim();
  const parts = cleaned.split(/[\s,;]+/).filter(Boolean).map(Number);
  if (parts.length >= 2 && parts.every((n) => !Number.isNaN(n))) {
    const [a, b] = parts;
    if (Math.abs(a) <= 90 && Math.abs(b) <= 180) return { lat: a, lng: b };
    if (Math.abs(b) <= 90 && Math.abs(a) <= 180) return { lat: b, lng: a };
  }
  return { lat: null, lng: null };
}

export function detectSource(row: Record<string, unknown>): VerifiedSource {
  const source = String(row.source ?? row.registry ?? '').toUpperCase();
  if (source.includes('MDPCZ')) return 'MDPCZ';
  if (source.includes('HPA')) return 'HPA';
  if (row.mdpczNumber || row.mdpcz) return 'MDPCZ';
  return 'MDPCZ';
}

export function hashRow(row: Record<string, unknown>): string {
  const payload = JSON.stringify(row, Object.keys(row).sort());
  return createHash('sha256').update(payload).digest('hex').slice(0, 32);
}

export function normalizeSpreadsheetRow(
  row: RawSpreadsheetRow,
  specialtyNormalizer: (raw: string | null) => { name: string | null; slug: string | null; unmatched: boolean },
): NormalizedProvider {
  const raw = row.raw;
  const nameRaw = String(raw.practitionerName ?? raw.name ?? raw.doctor ?? '').trim() || null;
  const parsedName = parseName(nameRaw);
  const city = normalizeCity(String(raw.city ?? raw.town ?? ''));
  const province = normalizeProvince(String(raw.province ?? ''), city);
  const phone = normalizePhoneLocal(String(raw.phone ?? raw.mobile ?? raw.telephone ?? ''));
  const phone2 = normalizePhoneLocal(String(raw.phone2 ?? ''));
  const effectivePhone = phone ?? phone2;
  const gpsFromField = parseGps(String(raw.gps ?? ''));
  const lat = raw.latitude ? Number(raw.latitude) : gpsFromField.lat;
  const lng = raw.longitude ? Number(raw.longitude) : gpsFromField.lng;
  const specialtyRaw = String(raw.specialty ?? raw.speciality ?? '').trim() || null;
  const specialtyResult = specialtyNormalizer(specialtyRaw);
  const registrationNumber = String(
    raw.registrationNumber ?? raw.reg_number ?? raw.license_number ?? '',
  ).trim().toUpperCase() || null;
  const mdpczNumber = String(raw.mdpczNumber ?? raw.mdpcz ?? registrationNumber ?? '')
    .trim()
    .toUpperCase() || null;

  const normalized: NormalizedProvider = {
    rowNumber: row.rowNumber,
    rowHash: hashRow(raw),
    source: detectSource(raw),
    name: parsedName ?? {
      title: null,
      firstName: 'Unknown',
      middleName: null,
      lastName: 'Provider',
      fullName: nameRaw ?? 'Unknown Provider',
    },
    facilityName: raw.facilityName ? toTitleCase(String(raw.facilityName)) : null,
    registrationNumber,
    mdpczNumber,
    specialtyRaw,
    specialtyNormalized: specialtyResult.name,
    specialtySlug: specialtyResult.slug,
    profession: raw.profession ? toTitleCase(String(raw.profession)) : null,
    address: raw.address ? collapseWhitespace(String(raw.address)) : null,
    province,
    city,
    phone: effectivePhone,
    email: raw.email ? String(raw.email).trim().toLowerCase() : null,
    licenseStatus: raw.licenseStatus ? collapseWhitespace(String(raw.licenseStatus)) : null,
    practiceType: raw.practiceType ? toTitleCase(String(raw.practiceType)) : null,
    facilityCategory: raw.facilityCategory ? toTitleCase(String(raw.facilityCategory)) : null,
    ownershipType: raw.ownershipType ? toTitleCase(String(raw.ownershipType)) : null,
    latitude: lat && !Number.isNaN(lat) ? lat : null,
    longitude: lng && !Number.isNaN(lng) ? lng : null,
    gpsRaw: raw.gps ? String(raw.gps) : null,
    slug: null,
    searchKeywords: [],
    validationErrors: [],
    warnings: [],
  };

  if (specialtyResult.unmatched && specialtyRaw) {
    normalized.warnings.push(`Unmatched specialty: ${specialtyRaw}`);
  }
  if (!parsedName) {
    normalized.validationErrors.push('Missing or invalid practitioner name');
  }
  if (!normalized.facilityName && !normalized.address) {
    normalized.warnings.push('No facility name or address — will use independent practice placeholder');
  }

  return normalized;
}

export function buildFacilityKey(name: string, city: string | null, address: string | null): string {
  return [name, city ?? '', address ?? ''].join('|').toLowerCase().replace(/\s+/g, ' ');
}

export function inferFacilityType(
  category: string | null,
  practiceType: string | null,
): string {
  const combined = `${category ?? ''} ${practiceType ?? ''}`.toLowerCase();
  if (combined.includes('hospital')) return 'hospital';
  if (combined.includes('pharmacy')) return 'pharmacy';
  if (combined.includes('lab')) return 'laboratory';
  if (combined.includes('dental')) return 'dental';
  if (combined.includes('optom')) return 'optometry';
  if (combined.includes('imaging') || combined.includes('radiology')) return 'imaging';
  if (combined.includes('clinic')) return 'clinic';
  return 'clinic';
}
