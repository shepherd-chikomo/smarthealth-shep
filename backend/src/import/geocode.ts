import { createHash } from 'node:crypto';
import type pg from 'pg';
import type {
  GeocodeQuality,
  GeocodeResult,
  NormalizedFacility,
  NormalizedProvider,
} from './types.js';
import { logger } from './logger.js';
import { provinceForGeocodeQuery } from './province_resolve.js';

const NOMINATIM_BASE = 'https://nominatim.openstreetmap.org/search';
const RATE_LIMIT_MS = 1100;
const MAX_CITY_DISTANCE_KM = 35;

/** Typical Zimbabwe bounding box (matches import validate.ts warnings). */
const ZIMBABWE_LAT_MIN = -25;
const ZIMBABWE_LAT_MAX = -15;
const ZIMBABWE_LON_MIN = 25;
const ZIMBABWE_LON_MAX = 34;

const PREFERRED_TYPES = new Set([
  'clinic',
  'hospital',
  'pharmacy',
  'doctors',
  'dentist',
  'healthcare',
  'medical',
  'commercial',
  'retail',
  'yes',
]);

const PREFERRED_CLASSES = new Set([
  'amenity',
  'healthcare',
  'building',
  'shop',
  'office',
]);

export function isWithinZimbabwe(lat: number, lon: number): boolean {
  return (
    lat >= ZIMBABWE_LAT_MIN &&
    lat <= ZIMBABWE_LAT_MAX &&
    lon >= ZIMBABWE_LON_MIN &&
    lon <= ZIMBABWE_LON_MAX
  );
}

export function haversineKm(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number,
): number {
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

export interface NominatimHit {
  latitude: number;
  longitude: number;
  formattedAddress: string;
  class: string;
  type: string;
  importance: number;
  placeRank: number;
}

export function scoreNominatimHit(hit: NominatimHit): number {
  let score = hit.importance;

  if (PREFERRED_CLASSES.has(hit.class)) score += 0.15;
  if (PREFERRED_TYPES.has(hit.type)) score += 0.2;

  if (hit.class === 'place' && ['city', 'town', 'village', 'suburb'].includes(hit.type)) {
    score -= 0.35;
  }
  if (hit.class === 'boundary' || hit.type === 'administrative') {
    score -= 0.4;
  }
  if (hit.placeRank <= 8) {
    score -= 0.5;
  }

  return score;
}

function acceptGeocodeResult(
  query: string,
  result: GeocodeResult | null,
): GeocodeResult | null {
  if (!result) return null;
  if (!isWithinZimbabwe(result.latitude, result.longitude)) {
    logger.warn(`Geocode result outside Zimbabwe for: ${query}`, {
      latitude: result.latitude,
      longitude: result.longitude,
    });
    return null;
  }
  return result;
}

export interface FacilityAddressInput {
  name: string;
  addressLine1?: string | null;
  city?: string | null;
  province?: string | null;
}

export function buildFacilityAddressQuery(
  facility: FacilityAddressInput,
  options?: { includeName?: boolean },
): string | null {
  if (!facility.city && !facility.addressLine1) return null;

  const parts: string[] = [];
  if (options?.includeName && facility.name) parts.push(facility.name);
  if (facility.addressLine1) parts.push(facility.addressLine1);
  if (facility.city) parts.push(facility.city);
  const province = provinceForGeocodeQuery(facility.city, facility.province);
  if (province) parts.push(province);
  parts.push('Zimbabwe');

  const query = parts.filter(Boolean).join(', ');
  return query.length > 5 ? query : null;
}

export function buildNameCityQuery(facility: FacilityAddressInput): string | null {
  if (!facility.name || !facility.city) return null;
  const parts = [facility.name, facility.city];
  const province = provinceForGeocodeQuery(facility.city, facility.province);
  if (province) parts.push(province);
  parts.push('Zimbabwe');
  const query = parts.join(', ');
  return query.length > 5 ? query : null;
}

export function buildCityOnlyQuery(facility: FacilityAddressInput): string | null {
  if (!facility.city) return null;
  const parts = [facility.city];
  const province = provinceForGeocodeQuery(facility.city, facility.province);
  if (province) parts.push(province);
  parts.push('Zimbabwe');
  return parts.join(', ');
}

export function facilityInputSignature(facility: FacilityAddressInput): string {
  const payload = {
    name: facility.name.trim().toLowerCase(),
    address: (facility.addressLine1 ?? '').trim().toLowerCase(),
    city: (facility.city ?? '').trim().toLowerCase(),
    province: (facility.province ?? '').trim().toLowerCase(),
  };
  return createHash('sha256').update(JSON.stringify(payload)).digest('hex');
}

let lastRequestAt = 0;

function hashQuery(query: string): string {
  return createHash('sha256').update(query.toLowerCase().trim()).digest('hex');
}

async function rateLimit(): Promise<void> {
  const elapsed = Date.now() - lastRequestAt;
  if (elapsed < RATE_LIMIT_MS) {
    await new Promise((r) => setTimeout(r, RATE_LIMIT_MS - elapsed));
  }
  lastRequestAt = Date.now();
}

type RawNominatimRow = {
  lat: string;
  lon: string;
  display_name: string;
  class?: string;
  type?: string;
  importance?: string;
  place_rank?: string;
};

function parseNominatimRow(row: RawNominatimRow): NominatimHit {
  return {
    latitude: parseFloat(row.lat),
    longitude: parseFloat(row.lon),
    formattedAddress: row.display_name,
    class: row.class ?? '',
    type: row.type ?? '',
    importance: Number.parseFloat(row.importance ?? '0') || 0,
    placeRank: Number.parseInt(row.place_rank ?? '30', 10) || 30,
  };
}

async function nominatimRequest(
  params: URLSearchParams,
  cacheKey: string,
): Promise<NominatimHit[]> {
  await rateLimit();

  const response = await fetch(`${NOMINATIM_BASE}?${params}`, {
    headers: {
      'User-Agent': 'SmartHealth-Import/1.0 (healthcare directory; contact@smarthealth.co.zw)',
      Accept: 'application/json',
    },
  });

  if (!response.ok) {
    logger.warn(`Nominatim request failed: ${response.status}`, { cacheKey });
    return [];
  }

  const results = (await response.json()) as RawNominatimRow[];
  return results.map(parseNominatimRow).filter((h) => isWithinZimbabwe(h.latitude, h.longitude));
}

async function fetchFreeform(query: string, limit = 3): Promise<NominatimHit[]> {
  const params = new URLSearchParams({
    q: query,
    format: 'json',
    limit: String(limit),
    countrycodes: 'zw',
    addressdetails: '1',
  });
  return nominatimRequest(params, query);
}

export interface StructuredAddressParams {
  street?: string;
  city?: string;
  state?: string;
  country: string;
}

async function fetchStructured(params: StructuredAddressParams): Promise<NominatimHit[]> {
  const search = new URLSearchParams({
    format: 'json',
    limit: '3',
    countrycodes: 'zw',
    addressdetails: '1',
  });
  if (params.street) search.set('street', params.street);
  if (params.city) search.set('city', params.city);
  if (params.state) search.set('state', params.state);
  search.set('country', params.country);

  const cacheKey = `structured:${JSON.stringify(params)}`;
  return nominatimRequest(search, cacheKey);
}

function hitToResult(
  hit: NominatimHit,
  quality: GeocodeQuality,
  fromCache: boolean,
): GeocodeResult {
  return {
    latitude: hit.latitude,
    longitude: hit.longitude,
    formattedAddress: hit.formattedAddress,
    fromCache,
    quality,
    provider: 'nominatim',
  };
}

function passesPlausibility(
  hit: NominatimHit,
  quality: GeocodeQuality,
  cityCentroid: { lat: number; lon: number } | null,
): boolean {
  if (!cityCentroid) return true;
  if (quality === 'city_only' || quality === 'city_centre') return true;

  const dist = haversineKm(
    hit.latitude,
    hit.longitude,
    cityCentroid.lat,
    cityCentroid.lon,
  );
  return dist <= MAX_CITY_DISTANCE_KM;
}

function pickBestHit(
  hits: NominatimHit[],
  quality: GeocodeQuality,
  cityCentroid: { lat: number; lon: number } | null,
): NominatimHit | null {
  let best: NominatimHit | null = null;
  let bestScore = -Infinity;

  for (const hit of hits) {
    if (!passesPlausibility(hit, quality, cityCentroid)) continue;
    const score = scoreNominatimHit(hit);
    if (score > bestScore) {
      bestScore = score;
      best = hit;
    }
  }
  return best;
}

export async function getCachedGeocode(
  client: pg.PoolClient,
  query: string,
): Promise<GeocodeResult | null> {
  const queryHash = hashQuery(query);
  const result = await client.query<{
    latitude: number;
    longitude: number;
    formatted_address: string;
    provider: string;
  }>(
    `SELECT latitude, longitude, formatted_address, provider
     FROM public.geocode_cache WHERE query_hash = $1`,
    [queryHash],
  );

  if (!result.rows[0]?.latitude) return null;

  await client.query(
    `UPDATE public.geocode_cache SET last_used_at = timezone('utc', now()) WHERE query_hash = $1`,
    [queryHash],
  );

  return acceptGeocodeResult(query, {
    latitude: result.rows[0].latitude,
    longitude: result.rows[0].longitude,
    formattedAddress: result.rows[0].formatted_address,
    fromCache: true,
    provider: (result.rows[0].provider as 'nominatim') ?? 'nominatim',
  });
}

export async function cacheGeocode(
  client: pg.PoolClient,
  query: string,
  result: GeocodeResult,
): Promise<void> {
  const queryHash = hashQuery(query);
  await client.query(
    `INSERT INTO public.geocode_cache (
       query_hash, query_text, latitude, longitude, formatted_address, provider
     )
     VALUES ($1, $2, $3, $4, $5, $6)
     ON CONFLICT (query_hash) DO UPDATE SET
       latitude = EXCLUDED.latitude,
       longitude = EXCLUDED.longitude,
       formatted_address = EXCLUDED.formatted_address,
       provider = EXCLUDED.provider,
       last_used_at = timezone('utc', now())`,
    [
      queryHash,
      query,
      result.latitude,
      result.longitude,
      result.formattedAddress,
      result.provider ?? 'nominatim',
    ],
  );
}

async function geocodeFreeformAttempt(
  client: pg.PoolClient,
  query: string,
  quality: GeocodeQuality,
  cityCentroid: { lat: number; lon: number } | null,
  skipRemote: boolean,
): Promise<GeocodeResult | null> {
  const cached = await getCachedGeocode(client, query);
  if (cached) {
    const hit: NominatimHit = {
      latitude: cached.latitude,
      longitude: cached.longitude,
      formattedAddress: cached.formattedAddress,
      class: 'place',
      type: 'unknown',
      importance: 0.5,
      placeRank: 20,
    };
    if (!passesPlausibility(hit, quality, cityCentroid)) return null;
    return { ...cached, quality, provider: 'nominatim' };
  }

  if (skipRemote) return null;

  const hits = await fetchFreeform(query, 3);
  const best = pickBestHit(hits, quality, cityCentroid);
  if (!best) return null;

  const result = hitToResult(best, quality, false);
  const accepted = acceptGeocodeResult(query, result);
  if (accepted) {
    await cacheGeocode(client, query, accepted);
  }
  return accepted;
}

async function geocodeStructuredAttempt(
  client: pg.PoolClient,
  params: StructuredAddressParams,
  quality: GeocodeQuality,
  cityCentroid: { lat: number; lon: number } | null,
  skipRemote: boolean,
): Promise<GeocodeResult | null> {
  const cacheKey = `structured:${JSON.stringify(params)}`;
  const cached = await getCachedGeocode(client, cacheKey);
  if (cached) {
    return { ...cached, quality, provider: 'nominatim' };
  }

  if (skipRemote) return null;

  const hits = await fetchStructured(params);
  const best = pickBestHit(hits, quality, cityCentroid);
  if (!best) return null;

  const result = hitToResult(best, quality, false);
  const accepted = acceptGeocodeResult(cacheKey, result);
  if (accepted) {
    await cacheGeocode(client, cacheKey, accepted);
  }
  return accepted;
}

export interface CityCentroidMap {
  get(city: string, province: string): { lat: number; lon: number } | null;
}

export function createCityCentroidMap(
  rows: Array<{ name: string; province: string; latitude: number; longitude: number }>,
): CityCentroidMap {
  const map = new Map<string, { lat: number; lon: number }>();
  for (const row of rows) {
    map.set(`${row.name.toLowerCase()}|${row.province.toLowerCase()}`, {
      lat: row.latitude,
      lon: row.longitude,
    });
  }
  return {
    get(city: string, province: string) {
      return map.get(`${city.toLowerCase()}|${province.toLowerCase()}`) ?? null;
    },
  };
}

/**
 * Multi-strategy geocode for a facility: structured street, name+address, address, name+city, city-only.
 */
export async function geocodeFacilityInput(
  client: pg.PoolClient,
  facility: FacilityAddressInput,
  cityCentroids: CityCentroidMap,
  skipRemote: boolean,
): Promise<GeocodeResult | null> {
  const city = facility.city ?? '';
  const trustedProvince = provinceForGeocodeQuery(city, facility.province);
  const centroid =
    city && trustedProvince ? cityCentroids.get(city, trustedProvince) : null;

  const attempts: Array<() => Promise<GeocodeResult | null>> = [];

  if (facility.addressLine1 && city) {
    attempts.push(() =>
      geocodeStructuredAttempt(
        client,
        {
          street: facility.addressLine1!,
          city,
          state: trustedProvince || undefined,
          country: 'Zimbabwe',
        },
        'address',
        centroid,
        skipRemote,
      ),
    );
  }

  const withName = buildFacilityAddressQuery(facility, { includeName: true });
  if (withName) {
    attempts.push(() =>
      geocodeFreeformAttempt(client, withName, 'address', centroid, skipRemote),
    );
  }

  const addressOnly = buildFacilityAddressQuery(facility, { includeName: false });
  if (addressOnly && addressOnly !== withName) {
    attempts.push(() =>
      geocodeFreeformAttempt(client, addressOnly, 'address', centroid, skipRemote),
    );
  }

  const nameCity = buildNameCityQuery(facility);
  if (nameCity) {
    attempts.push(() =>
      geocodeFreeformAttempt(client, nameCity, 'name', centroid, skipRemote),
    );
  }

  const cityOnly = buildCityOnlyQuery(facility);
  if (cityOnly && !facility.addressLine1) {
    attempts.push(() =>
      geocodeFreeformAttempt(client, cityOnly, 'city_only', centroid, skipRemote),
    );
  }

  let best: GeocodeResult | null = null;
  let bestScore = -Infinity;

  for (const attempt of attempts) {
    const result = await attempt();
    if (!result) continue;

    const hit: NominatimHit = {
      latitude: result.latitude,
      longitude: result.longitude,
      formattedAddress: result.formattedAddress,
      class: 'amenity',
      type: 'yes',
      importance: result.quality === 'city_only' ? 0.2 : 0.6,
      placeRank: result.quality === 'city_only' ? 14 : 20,
    };
    const score = scoreNominatimHit(hit);
    const qualityPenalty =
      result.quality === 'city_only' ? -1 : result.quality === 'name' ? -0.1 : 0;

    if (score + qualityPenalty > bestScore) {
      bestScore = score + qualityPenalty;
      best = result;
    }
  }

  return best;
}

export async function geocodeFacilityBatch(
  client: pg.PoolClient,
  facilities: FacilityAddressInput[],
  cityCentroids: CityCentroidMap,
  skipRemote: boolean,
): Promise<Map<string, GeocodeResult>> {
  const results = new Map<string, GeocodeResult>();
  const signatureToFacilities = new Map<string, FacilityAddressInput[]>();

  for (const facility of facilities) {
    const sig = facilityInputSignature(facility);
    const list = signatureToFacilities.get(sig) ?? [];
    list.push(facility);
    signatureToFacilities.set(sig, list);
  }

  logger.info(`Geocoding ${signatureToFacilities.size} unique facility locations`, {
    skipRemote,
    totalFacilities: facilities.length,
  });

  for (const [sig, group] of signatureToFacilities) {
    const sample = group[0]!;
    try {
      const result = await geocodeFacilityInput(
        client,
        sample,
        cityCentroids,
        skipRemote,
      );
      if (result) results.set(sig, result);
    } catch (error) {
      logger.warn(`Geocoding failed for facility: ${sample.name}`, {
        error: error instanceof Error ? error.message : String(error),
        signature: sig,
      });
    }
  }

  return results;
}

export function buildGeocodeQuery(
  entity: NormalizedProvider | NormalizedFacility,
): string | null {
  if (!entity.city && !entity.address) return null;

  const parts: string[] = [];
  if ('facilityName' in entity && entity.facilityName) parts.push(entity.facilityName);
  if ('name' in entity && !('facilityName' in entity)) {
    parts.push(entity.name);
  }
  if (entity.address) parts.push(entity.address);
  if (entity.city) parts.push(entity.city);
  if (entity.province) parts.push(entity.province);
  parts.push('Zimbabwe');

  const query = parts.filter(Boolean).join(', ');
  return query.length > 5 ? query : null;
}

export async function geocodeEntity(
  client: pg.PoolClient,
  query: string,
  skipRemote: boolean,
): Promise<GeocodeResult | null> {
  return geocodeFreeformAttempt(client, query, 'address', null, skipRemote);
}

export async function geocodeBatch(
  client: pg.PoolClient,
  queries: string[],
  skipGeocoding: boolean,
): Promise<Map<string, GeocodeResult>> {
  const results = new Map<string, GeocodeResult>();
  const unique = [...new Set(queries)];

  logger.info(`Geocoding ${unique.length} unique locations`, { skipGeocoding });

  for (const query of unique) {
    try {
      const result = await geocodeEntity(client, query, skipGeocoding);
      if (result) results.set(query, result);
    } catch (error) {
      logger.warn(`Geocoding failed for: ${query}`, {
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }

  return results;
}

export { TRUSTED_GEOCODE_QUALITIES, isTrustedGeocodeQuality } from '../lib/geocode-quality.js';
