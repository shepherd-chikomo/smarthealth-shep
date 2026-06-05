import type pg from 'pg';
import { env } from '../config.js';
import {
  buildFacilityAddressQuery,
  buildNameCityQuery,
  cacheGeocode,
  facilityInputSignature,
  getCachedGeocode,
  haversineKm,
  isWithinZimbabwe,
  passesGeocodePlausibility,
  type CityCentroidMap,
  type FacilityAddressInput,
  type StructuredAddressParams,
} from './geocode.js';
import { logger } from './logger.js';
import { provinceForGeocodeQuery } from './province_resolve.js';
import type {
  GeocodeQuality,
  GeocodeResult,
  GoogleGeocodeStrategy,
} from './types.js';

const GEOCODE_BASE = 'https://maps.googleapis.com/maps/api/geocode/json';
const PLACES_TEXT_BASE = 'https://maps.googleapis.com/maps/api/place/textsearch/json';

const HEALTHCARE_TYPES = new Set([
  'hospital',
  'doctor',
  'pharmacy',
  'health',
  'dentist',
  'physiotherapist',
  'veterinary_care',
  'point_of_interest',
  'establishment',
]);

const LOCATION_TYPE_SCORE: Record<string, number> = {
  ROOFTOP: 0.35,
  RANGE_INTERPOLATED: 0.25,
  GEOMETRIC_CENTER: -0.15,
  APPROXIMATE: -0.3,
};

export function getGoogleMapsApiKey(): string {
  const key = process.env.GOOGLE_MAPS_API_KEY ?? env.GOOGLE_MAPS_API_KEY;
  if (!key) {
    throw new Error(
      'GOOGLE_MAPS_API_KEY is required for Google geocoding. Set it in backend/.env',
    );
  }
  return key;
}

export interface GoogleGeocodeHit {
  latitude: number;
  longitude: number;
  formattedAddress: string;
  locationType: string;
  types: string[];
  partialMatch: boolean;
}

export function scoreGoogleHit(hit: GoogleGeocodeHit): number {
  let score = 0.5;
  score += LOCATION_TYPE_SCORE[hit.locationType] ?? 0;
  if (hit.types.some((t) => HEALTHCARE_TYPES.has(t))) score += 0.2;
  if (hit.partialMatch) score -= 0.5;
  if (hit.types.includes('locality') || hit.types.includes('administrative_area_level_1')) {
    score -= 0.4;
  }
  return score;
}

function googleCacheKey(strategy: GoogleGeocodeStrategy, key: string): string {
  return `google:${strategy}:${key}`;
}

function acceptGoogleResult(
  query: string,
  result: GeocodeResult | null,
): GeocodeResult | null {
  if (!result) return null;
  if (!isWithinZimbabwe(result.latitude, result.longitude)) {
    logger.warn(`Google geocode result outside Zimbabwe for: ${query}`, {
      latitude: result.latitude,
      longitude: result.longitude,
    });
    return null;
  }
  return result;
}

function hitToGoogleResult(
  hit: GoogleGeocodeHit,
  quality: GeocodeQuality,
  strategy: GoogleGeocodeStrategy,
  fromCache: boolean,
): GeocodeResult {
  return {
    latitude: hit.latitude,
    longitude: hit.longitude,
    formattedAddress: hit.formattedAddress,
    fromCache,
    quality,
    provider: 'google',
    googleStrategy: strategy,
  };
}

function pickBestGoogleHit(
  hits: GoogleGeocodeHit[],
  quality: GeocodeQuality,
  cityCentroid: { lat: number; lon: number } | null,
): GoogleGeocodeHit | null {
  let best: GoogleGeocodeHit | null = null;
  let bestScore = -Infinity;

  for (const hit of hits) {
    if (
      !passesGeocodePlausibility(
        hit.latitude,
        hit.longitude,
        quality,
        cityCentroid,
      )
    ) {
      continue;
    }
    const score = scoreGoogleHit(hit);
    if (score > bestScore) {
      bestScore = score;
      best = hit;
    }
  }
  return best;
}

function parseGeocodingRow(row: {
  formatted_address: string;
  geometry: { location: { lat: number; lng: number }; location_type?: string };
  types?: string[];
  partial_match?: boolean;
}): GoogleGeocodeHit {
  return {
    latitude: row.geometry.location.lat,
    longitude: row.geometry.location.lng,
    formattedAddress: row.formatted_address,
    locationType: row.geometry.location_type ?? 'APPROXIMATE',
    types: row.types ?? [],
    partialMatch: row.partial_match ?? false,
  };
}

function parsePlacesRow(row: {
  formatted_address?: string;
  name?: string;
  geometry: { location: { lat: number; lng: number } };
  types?: string[];
}): GoogleGeocodeHit {
  const formattedAddress =
    row.formatted_address ?? row.name ?? `${row.geometry.location.lat},${row.geometry.location.lng}`;
  return {
    latitude: row.geometry.location.lat,
    longitude: row.geometry.location.lng,
    formattedAddress,
    locationType: 'ROOFTOP',
    types: row.types ?? [],
    partialMatch: false,
  };
}

async function googleGeocodeRequest(
  params: URLSearchParams,
  cacheKey: string,
): Promise<GoogleGeocodeHit[]> {
  const apiKey = getGoogleMapsApiKey();
  params.set('key', apiKey);
  params.set('region', 'zw');

  const response = await fetch(`${GEOCODE_BASE}?${params}`);
  if (!response.ok) {
    logger.warn(`Google Geocoding request failed: ${response.status}`, { cacheKey });
    return [];
  }

  const body = (await response.json()) as {
    status: string;
    results?: Array<{
      formatted_address: string;
      geometry: { location: { lat: number; lng: number }; location_type?: string };
      types?: string[];
      partial_match?: boolean;
    }>;
    error_message?: string;
  };

  if (body.status !== 'OK' && body.status !== 'ZERO_RESULTS') {
    logger.warn(`Google Geocoding status: ${body.status}`, {
      cacheKey,
      error: body.error_message,
    });
    return [];
  }

  return (body.results ?? [])
    .map(parseGeocodingRow)
    .filter((h) => isWithinZimbabwe(h.latitude, h.longitude));
}

async function googlePlacesTextRequest(
  query: string,
  cacheKey: string,
): Promise<GoogleGeocodeHit[]> {
  const apiKey = getGoogleMapsApiKey();
  const params = new URLSearchParams({
    query,
    key: apiKey,
    region: 'zw',
  });

  const response = await fetch(`${PLACES_TEXT_BASE}?${params}`);
  if (!response.ok) {
    logger.warn(`Google Places request failed: ${response.status}`, { cacheKey });
    return [];
  }

  const body = (await response.json()) as {
    status: string;
    results?: Array<{
      formatted_address?: string;
      name?: string;
      geometry: { location: { lat: number; lng: number } };
      types?: string[];
    }>;
    error_message?: string;
  };

  if (body.status !== 'OK' && body.status !== 'ZERO_RESULTS') {
    logger.warn(`Google Places status: ${body.status}`, {
      cacheKey,
      error: body.error_message,
    });
    return [];
  }

  return (body.results ?? [])
    .map(parsePlacesRow)
    .filter((h) => isWithinZimbabwe(h.latitude, h.longitude));
}

async function googlePlacesAttempt(
  client: pg.PoolClient,
  query: string,
  quality: GeocodeQuality,
  cityCentroid: { lat: number; lon: number } | null,
  skipRemote: boolean,
): Promise<GeocodeResult | null> {
  const cacheKey = googleCacheKey('places_text', query);
  const cached = await getCachedGeocode(client, cacheKey);
  if (cached) {
    if (
      !passesGeocodePlausibility(
        cached.latitude,
        cached.longitude,
        quality,
        cityCentroid,
      )
    ) {
      return null;
    }
    return {
      ...cached,
      quality,
      provider: 'google',
      googleStrategy: 'places_text',
    };
  }

  if (skipRemote) return null;

  const hits = await googlePlacesTextRequest(query, cacheKey);
  const best = pickBestGoogleHit(hits, quality, cityCentroid);
  if (!best) return null;

  const result = hitToGoogleResult(best, quality, 'places_text', false);
  const accepted = acceptGoogleResult(cacheKey, result);
  if (accepted) {
    await cacheGeocode(client, cacheKey, accepted);
  }
  return accepted;
}

async function googleGeocodeFreeformAttempt(
  client: pg.PoolClient,
  query: string,
  quality: GeocodeQuality,
  cityCentroid: { lat: number; lon: number } | null,
  skipRemote: boolean,
): Promise<GeocodeResult | null> {
  const cacheKey = googleCacheKey('geocoding_freeform', query);
  const cached = await getCachedGeocode(client, cacheKey);
  if (cached) {
    if (
      !passesGeocodePlausibility(
        cached.latitude,
        cached.longitude,
        quality,
        cityCentroid,
      )
    ) {
      return null;
    }
    return {
      ...cached,
      quality,
      provider: 'google',
      googleStrategy: 'geocoding_freeform',
    };
  }

  if (skipRemote) return null;

  const params = new URLSearchParams({
    address: query,
    components: 'country:ZW',
  });
  const hits = await googleGeocodeRequest(params, cacheKey);
  const best = pickBestGoogleHit(hits, quality, cityCentroid);
  if (!best) return null;

  const result = hitToGoogleResult(best, quality, 'geocoding_freeform', false);
  const accepted = acceptGoogleResult(cacheKey, result);
  if (accepted) {
    await cacheGeocode(client, cacheKey, accepted);
  }
  return accepted;
}

async function googleGeocodeStructuredAttempt(
  client: pg.PoolClient,
  params: StructuredAddressParams,
  quality: GeocodeQuality,
  cityCentroid: { lat: number; lon: number } | null,
  skipRemote: boolean,
): Promise<GeocodeResult | null> {
  const cacheKey = googleCacheKey('geocoding_structured', JSON.stringify(params));
  const cached = await getCachedGeocode(client, cacheKey);
  if (cached) {
    return {
      ...cached,
      quality,
      provider: 'google',
      googleStrategy: 'geocoding_structured',
    };
  }

  if (skipRemote) return null;

  const components: string[] = ['country:ZW'];
  if (params.city) components.push(`locality:${params.city}`);
  if (params.state) components.push(`administrative_area:${params.state}`);

  const addressParts = [params.street].filter(Boolean).join(', ');
  const search = new URLSearchParams({
    address: addressParts || `${params.city ?? ''}, Zimbabwe`,
    components: components.join('|'),
  });

  const hits = await googleGeocodeRequest(search, cacheKey);
  const best = pickBestGoogleHit(hits, quality, cityCentroid);
  if (!best) return null;

  const result = hitToGoogleResult(best, quality, 'geocoding_structured', false);
  const accepted = acceptGoogleResult(cacheKey, result);
  if (accepted) {
    await cacheGeocode(client, cacheKey, accepted);
  }
  return accepted;
}

function buildPlacesTextQuery(facility: FacilityAddressInput): string | null {
  if (!facility.name || !facility.city) return null;
  return `${facility.name} ${facility.city} Zimbabwe`;
}

/**
 * Multi-strategy Google geocode: Places text search, structured geocoding, freeform address/name.
 */
export async function geocodeGoogleFacilityInput(
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

  const placesQuery = buildPlacesTextQuery(facility);
  if (placesQuery) {
    attempts.push(() =>
      googlePlacesAttempt(client, placesQuery, 'name', centroid, skipRemote),
    );
  }

  if (facility.addressLine1 && city) {
    attempts.push(() =>
      googleGeocodeStructuredAttempt(
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
      googleGeocodeFreeformAttempt(client, withName, 'address', centroid, skipRemote),
    );
  }

  const addressOnly = buildFacilityAddressQuery(facility, { includeName: false });
  if (addressOnly && addressOnly !== withName) {
    attempts.push(() =>
      googleGeocodeFreeformAttempt(client, addressOnly, 'address', centroid, skipRemote),
    );
  }

  const nameCity = buildNameCityQuery(facility);
  if (nameCity) {
    attempts.push(() =>
      googleGeocodeFreeformAttempt(client, nameCity, 'name', centroid, skipRemote),
    );
  }

  let best: GeocodeResult | null = null;
  let bestScore = -Infinity;

  for (const attempt of attempts) {
    const result = await attempt();
    if (!result) continue;

    const hit: GoogleGeocodeHit = {
      latitude: result.latitude,
      longitude: result.longitude,
      formattedAddress: result.formattedAddress,
      locationType: 'ROOFTOP',
      types: ['establishment'],
      partialMatch: false,
    };
    const score = scoreGoogleHit(hit);
    const qualityPenalty = result.quality === 'name' ? -0.05 : 0;

    if (score + qualityPenalty > bestScore) {
      bestScore = score + qualityPenalty;
      best = result;
    }
  }

  return best;
}

export async function geocodeGoogleFacilityBatch(
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

  logger.info(`Google geocoding ${signatureToFacilities.size} unique facility locations`, {
    skipRemote,
    totalFacilities: facilities.length,
  });

  for (const [sig, group] of signatureToFacilities) {
    const sample = group[0]!;
    try {
      const result = await geocodeGoogleFacilityInput(
        client,
        sample,
        cityCentroids,
        skipRemote,
      );
      if (result) results.set(sig, result);
    } catch (error) {
      logger.warn(`Google geocoding failed for facility: ${sample.name}`, {
        error: error instanceof Error ? error.message : String(error),
        signature: sig,
      });
    }
  }

  return results;
}

/** Distance in km between two geocode results, or null if either is missing. */
export function distanceBetweenResults(
  a: GeocodeResult | null,
  b: GeocodeResult | null,
): number | null {
  if (!a || !b) return null;
  return haversineKm(a.latitude, a.longitude, b.latitude, b.longitude);
}
