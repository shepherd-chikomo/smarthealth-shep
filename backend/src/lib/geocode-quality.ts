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
