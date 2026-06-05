import type { GeocodeQuality } from '../import/types.js';

/** Geocode quality levels trusted enough to show distance in the API. */
export const TRUSTED_GEOCODE_QUALITIES = new Set<GeocodeQuality>([
  'address',
  'name',
  'manual',
]);

export function isTrustedGeocodeQuality(quality: string | null | undefined): boolean {
  if (quality == null) return true;
  return TRUSTED_GEOCODE_QUALITIES.has(quality as GeocodeQuality);
}

export function isGeocodedUpToDate(row: {
  latitude: number | null;
  longitude: number | null;
  geocode_quality: string | null;
}): boolean {
  return (
    row.latitude != null &&
    row.longitude != null &&
    isTrustedGeocodeQuality(row.geocode_quality) &&
    row.geocode_quality !== 'city_only' &&
    row.geocode_quality !== 'city_centre'
  );
}

export type GeocodeStatus = 'ok' | 'missing' | 'low_quality';

export function getGeocodeStatus(row: {
  latitude: number | null;
  longitude: number | null;
  geocode_quality: string | null;
}): GeocodeStatus {
  if (isGeocodedUpToDate(row)) return 'ok';
  if (row.latitude == null || row.longitude == null) return 'missing';
  return 'low_quality';
}
