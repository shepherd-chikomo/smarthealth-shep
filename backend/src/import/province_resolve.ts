import type pg from 'pg';
import { isWithinZimbabwe } from './geocode.js';
import { normalizeProvince } from './normalize_data.js';

export const ZIMBABWE_PROVINCES = [
  'Bulawayo',
  'Harare',
  'Manicaland',
  'Mashonaland Central',
  'Mashonaland East',
  'Mashonaland West',
  'Masvingo',
  'Matabeleland North',
  'Matabeleland South',
  'Midlands',
] as const;

export type ZimbabweProvince = (typeof ZIMBABWE_PROVINCES)[number];

const HARARE_METRO_CITIES = new Set(['harare', 'chitungwiza', 'epworth']);

const CITY_TO_PROVINCE: Record<string, ZimbabweProvince> = {
  harare: 'Harare',
  chitungwiza: 'Harare',
  epworth: 'Harare',
  bulawayo: 'Bulawayo',
  mutare: 'Manicaland',
  rusape: 'Manicaland',
  bindura: 'Mashonaland Central',
  chinhoyi: 'Mashonaland West',
  kadoma: 'Mashonaland West',
  norton: 'Mashonaland West',
  banket: 'Mashonaland West',
  marondera: 'Mashonaland East',
  gweru: 'Midlands',
  kwekwe: 'Midlands',
  masvingo: 'Masvingo',
  'victoria falls': 'Matabeleland North',
  hwange: 'Matabeleland North',
  beitbridge: 'Matabeleland South',
};

const NOMINATIM_BASE = 'https://nominatim.openstreetmap.org/search';
const RATE_LIMIT_MS = 1100;

let lastRequestAt = 0;

async function rateLimit(): Promise<void> {
  const elapsed = Date.now() - lastRequestAt;
  if (elapsed < RATE_LIMIT_MS) {
    await new Promise((r) => setTimeout(r, RATE_LIMIT_MS - elapsed));
  }
  lastRequestAt = Date.now();
}

export function isHarareMetroCity(city: string | null | undefined): boolean {
  if (!city) return false;
  return HARARE_METRO_CITIES.has(city.trim().toLowerCase());
}

/** Province is untrusted when Harare is stored for a non-metro city. */
export function isUntrustedProvince(
  city: string | null | undefined,
  province: string | null | undefined,
): boolean {
  if (!province || !city) return province == null;
  if (province !== 'Harare') return false;
  return !isHarareMetroCity(city);
}

/** Hardcoded map lookup — returns null for unknown cities (no Harare default). */
export function inferProvinceFromCitySync(city: string | null | undefined): ZimbabweProvince | null {
  if (!city?.trim()) return null;
  const key = city.trim().toLowerCase();
  return CITY_TO_PROVINCE[key] ?? null;
}

/** @deprecated Use resolveProvinceFromCity — sync map only, no Harare default. */
export function inferProvinceFromCity(city: string | null): ZimbabweProvince | null {
  return inferProvinceFromCitySync(city);
}

export function normalizeOsmState(raw: string | null | undefined): ZimbabweProvince | null {
  if (!raw?.trim()) return null;
  const normalized = normalizeProvince(raw.trim(), null);
  if (normalized && ZIMBABWE_PROVINCES.includes(normalized as ZimbabweProvince)) {
    return normalized as ZimbabweProvince;
  }

  const key = raw.trim().toLowerCase();
  for (const province of ZIMBABWE_PROVINCES) {
    if (key.includes(province.toLowerCase())) return province;
  }

  return null;
}

export function provinceForGeocodeQuery(
  city: string | null | undefined,
  province: string | null | undefined,
): string | null {
  if (!province?.trim()) return null;
  if (isUntrustedProvince(city, province)) return null;
  return province.trim();
}

export async function lookupProvinceFromDb(
  client: pg.Pool | pg.PoolClient,
  city: string,
): Promise<ZimbabweProvince | null> {
  const result = await client.query<{ province: string }>(
    `SELECT province
     FROM public.cities
     WHERE country_code = 'ZW'
       AND lower(name) = lower($1)
       AND province IS NOT NULL
     ORDER BY population DESC NULLS LAST, name
     LIMIT 1`,
    [city.trim()],
  );
  const province = result.rows[0]?.province;
  if (province && ZIMBABWE_PROVINCES.includes(province as ZimbabweProvince)) {
    return province as ZimbabweProvince;
  }
  return null;
}

export async function resolveProvinceFromCity(
  client: pg.Pool | pg.PoolClient,
  city: string | null | undefined,
): Promise<ZimbabweProvince | null> {
  if (!city?.trim()) return null;

  const fromDb = await lookupProvinceFromDb(client, city);
  if (fromDb) return fromDb;

  return inferProvinceFromCitySync(city);
}

export interface CityProvinceLookupResult {
  province: ZimbabweProvince;
  latitude: number;
  longitude: number;
  rawState: string | null;
  query: string;
}

type NominatimAddress = {
  state?: string;
  region?: string;
  county?: string;
};

type NominatimRow = {
  lat: string;
  lon: string;
  class?: string;
  type?: string;
  importance?: string;
  address?: NominatimAddress;
};

function pickBestCityHit(rows: NominatimRow[]): NominatimRow | null {
  const placeTypes = new Set(['city', 'town', 'village', 'hamlet', 'suburb', 'locality']);
  let best: NominatimRow | null = null;
  let bestScore = -Infinity;

  for (const row of rows) {
    const lat = Number.parseFloat(row.lat);
    const lon = Number.parseFloat(row.lon);
    if (!isWithinZimbabwe(lat, lon)) continue;

    let score = Number.parseFloat(row.importance ?? '0') || 0;
    if (row.class === 'place' && row.type && placeTypes.has(row.type)) score += 0.5;
    if (row.class === 'boundary') score -= 0.3;

    if (score > bestScore) {
      bestScore = score;
      best = row;
    }
  }

  return best;
}

export async function lookupCityProvinceFromNominatim(
  city: string,
): Promise<CityProvinceLookupResult | null> {
  const query = `${city.trim()}, Zimbabwe`;
  await rateLimit();

  const params = new URLSearchParams({
    q: query,
    format: 'json',
    limit: '5',
    countrycodes: 'zw',
    addressdetails: '1',
  });

  const response = await fetch(`${NOMINATIM_BASE}?${params}`, {
    headers: {
      'User-Agent': 'SmartHealth-Import/1.0 (healthcare directory; contact@smarthealth.co.zw)',
      Accept: 'application/json',
    },
  });

  if (!response.ok) return null;

  const rows = (await response.json()) as NominatimRow[];
  const hit = pickBestCityHit(rows);
  if (!hit) return null;

  const lat = Number.parseFloat(hit.lat);
  const lon = Number.parseFloat(hit.lon);
  const rawState = hit.address?.state ?? hit.address?.region ?? hit.address?.county ?? null;
  const province = normalizeOsmState(rawState);
  if (!province) return null;

  return { province, latitude: lat, longitude: lon, rawState, query };
}

/** NOT NULL fallback when province cannot be resolved (geocode queries omit untrusted values). */
export function provinceInsertFallback(city: string | null | undefined): ZimbabweProvince {
  return inferProvinceFromCitySync(city) ?? 'Harare';
}
