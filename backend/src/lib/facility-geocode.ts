import type pg from 'pg';
import {
  createCityCentroidMap,
  geocodeFacilityInput,
  isWithinZimbabwe,
} from '../import/geocode.js';
import { logger } from '../import/logger.js';
import type { GeocodeQuality, GeocodeResult } from '../import/types.js';
import { pool } from './db.js';

async function loadCityCentroids(
  client: pg.PoolClient,
): Promise<ReturnType<typeof createCityCentroidMap>> {
  const result = await client.query<{
    name: string;
    province: string;
    latitude: number;
    longitude: number;
  }>(
    `SELECT name, province, latitude, longitude
     FROM public.cities
     WHERE country_code = 'ZW'
       AND latitude IS NOT NULL
       AND longitude IS NOT NULL`,
  );
  return createCityCentroidMap(result.rows);
}

function cityCentroidFallback(
  city: string,
  province: string,
  cityCentroids: ReturnType<typeof createCityCentroidMap>,
): GeocodeResult | null {
  const centroid = cityCentroids.get(city, province);
  if (!centroid || !isWithinZimbabwe(centroid.lat, centroid.lon)) return null;

  return {
    latitude: centroid.lat,
    longitude: centroid.lon,
    formattedAddress: `${city}, ${province}, Zimbabwe (city centre)`,
    fromCache: false,
    quality: 'city_centre',
    provider: 'nominatim',
  };
}

async function applyGeocodeToFacility(
  client: pg.PoolClient,
  facilityId: string,
  geo: GeocodeResult,
): Promise<void> {
  const quality: GeocodeQuality = geo.quality ?? 'address';
  await client.query(
    `UPDATE public.facilities
     SET latitude = $1,
         longitude = $2,
         formatted_address = $3,
         geocode_quality = $4,
         geocoded_at = timezone('utc', now()),
         updated_at = timezone('utc', now())
     WHERE id = $5`,
    [geo.latitude, geo.longitude, geo.formattedAddress, quality, facilityId],
  );
}

async function clearFacilityGeocode(client: pg.PoolClient, facilityId: string): Promise<void> {
  await client.query(
    `UPDATE public.facilities
     SET latitude = NULL,
         longitude = NULL,
         formatted_address = NULL,
         geocode_quality = NULL,
         geocoded_at = NULL,
         updated_at = timezone('utc', now())
     WHERE id = $1`,
    [facilityId],
  );
}

export interface GeocodeFacilityRecordInput {
  facilityId: string;
  name: string;
  addressLine1: string | null;
  city: string | null;
  province: string | null;
  /** When true, clear coordinates if lookup fails (use after address edit). */
  clearOnFailure?: boolean;
}

export interface GeocodeFacilityRecordResult {
  geocoded: boolean;
  quality?: GeocodeQuality;
}

/**
 * Geocode a single facility (Nominatim + cache + city-centre fallback).
 * Non-blocking for callers: failures are logged, not thrown.
 */
export async function geocodeFacilityRecord(
  input: GeocodeFacilityRecordInput,
): Promise<GeocodeFacilityRecordResult> {
  const { facilityId, name, addressLine1, city, province, clearOnFailure = false } = input;

  if (!addressLine1 && !city) {
    return { geocoded: false };
  }

  const client = await pool.connect();
  try {
    const cityCentroids = await loadCityCentroids(client);
    const provinceValue = province ?? 'Harare';

    let geo = await geocodeFacilityInput(
      client,
      {
        name,
        addressLine1,
        city,
        province: provinceValue,
      },
      cityCentroids,
      false,
    );

    if (!geo && city) {
      geo = cityCentroidFallback(city, provinceValue, cityCentroids);
    }

    if (geo) {
      await applyGeocodeToFacility(client, facilityId, geo);
      logger.info('Facility geocoded', {
        facilityId,
        quality: geo.quality ?? 'address',
        fromCache: geo.fromCache,
      });
      return { geocoded: true, quality: geo.quality ?? 'address' };
    }

    if (clearOnFailure) {
      await clearFacilityGeocode(client, facilityId);
    }

    logger.warn('Facility geocode lookup failed', {
      facilityId,
      name,
      addressLine1,
      city,
      clearOnFailure,
    });
    return { geocoded: false };
  } catch (error) {
    logger.warn('Facility geocode error', {
      facilityId,
      error: error instanceof Error ? error.message : String(error),
    });
    if (clearOnFailure) {
      try {
        await clearFacilityGeocode(client, facilityId);
      } catch {
        // ignore secondary failure
      }
    }
    return { geocoded: false };
  } finally {
    client.release();
  }
}
