import { createHash } from 'node:crypto';
import type pg from 'pg';
import type { GeocodeResult, NormalizedFacility, NormalizedProvider } from './types.js';
import { logger } from './logger.js';

const NOMINATIM_BASE = 'https://nominatim.openstreetmap.org/search';
const RATE_LIMIT_MS = 1100;

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

async function fetchFromNominatim(query: string): Promise<GeocodeResult | null> {
  await rateLimit();
  const params = new URLSearchParams({
    q: query,
    format: 'json',
    limit: '1',
    countrycodes: 'zw',
  });

  const response = await fetch(`${NOMINATIM_BASE}?${params}`, {
    headers: {
      'User-Agent': 'SmartHealth-Import/1.0 (healthcare directory; contact@smarthealth.co.zw)',
      Accept: 'application/json',
    },
  });

  if (!response.ok) {
    logger.warn(`Nominatim request failed: ${response.status}`);
    return null;
  }

  const results = (await response.json()) as Array<{
    lat: string;
    lon: string;
    display_name: string;
  }>;

  if (!results.length) return null;

  const hit = results[0];
  return {
    latitude: parseFloat(hit.lat),
    longitude: parseFloat(hit.lon),
    formattedAddress: hit.display_name,
    fromCache: false,
  };
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
  }>(
    `SELECT latitude, longitude, formatted_address
     FROM public.geocode_cache WHERE query_hash = $1`,
    [queryHash],
  );

  if (!result.rows[0]?.latitude) return null;

  await client.query(
    `UPDATE public.geocode_cache SET last_used_at = timezone('utc', now()) WHERE query_hash = $1`,
    [queryHash],
  );

  return {
    latitude: result.rows[0].latitude,
    longitude: result.rows[0].longitude,
    formattedAddress: result.rows[0].formatted_address,
    fromCache: true,
  };
}

export async function cacheGeocode(
  client: pg.PoolClient,
  query: string,
  result: GeocodeResult,
): Promise<void> {
  const queryHash = hashQuery(query);
  await client.query(
    `INSERT INTO public.geocode_cache (query_hash, query_text, latitude, longitude, formatted_address)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (query_hash) DO UPDATE SET
       latitude = EXCLUDED.latitude,
       longitude = EXCLUDED.longitude,
       formatted_address = EXCLUDED.formatted_address,
       last_used_at = timezone('utc', now())`,
    [queryHash, query, result.latitude, result.longitude, result.formattedAddress],
  );
}

export function buildGeocodeQuery(
  entity: NormalizedProvider | NormalizedFacility,
): string | null {
  if (!entity.city && !entity.address) return null;

  const parts: string[] = [];
  if ('facilityName' in entity && entity.facilityName) parts.push(entity.facilityName);
  if ('name' in entity && !('facilityName' in entity)) {
    const providerName = typeof entity.name === 'string' ? entity.name : entity.name.fullName;
    parts.push(providerName);
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
  const cached = await getCachedGeocode(client, query);
  if (cached) return cached;

  if (skipRemote) return null;

  const remote = await fetchFromNominatim(query);
  if (remote) {
    await cacheGeocode(client, query, remote);
  }
  return remote;
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
