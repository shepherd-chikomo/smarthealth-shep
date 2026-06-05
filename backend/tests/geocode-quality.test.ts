import { describe, expect, it } from 'vitest';
import { isGeocodedUpToDate, isTrustedGeocodeQuality, getGeocodeStatus } from '../src/lib/geocode-quality.js';

describe('isTrustedGeocodeQuality', () => {
  it('accepts address, name, and manual', () => {
    expect(isTrustedGeocodeQuality('address')).toBe(true);
    expect(isTrustedGeocodeQuality('name')).toBe(true);
    expect(isTrustedGeocodeQuality('manual')).toBe(true);
  });

  it('rejects city fallbacks', () => {
    expect(isTrustedGeocodeQuality('city_only')).toBe(false);
    expect(isTrustedGeocodeQuality('city_centre')).toBe(false);
  });
});

describe('isGeocodedUpToDate', () => {
  it('returns true for coords with trusted quality', () => {
    expect(
      isGeocodedUpToDate({
        latitude: -17.8,
        longitude: 31.0,
        geocode_quality: 'address',
      }),
    ).toBe(true);
  });

  it('returns true for coords with null quality (legacy rows)', () => {
    expect(
      isGeocodedUpToDate({
        latitude: -17.8,
        longitude: 31.0,
        geocode_quality: null,
      }),
    ).toBe(true);
  });

  it('returns false when coordinates are missing', () => {
    expect(
      isGeocodedUpToDate({
        latitude: null,
        longitude: null,
        geocode_quality: 'address',
      }),
    ).toBe(false);
  });

  it('returns false for city-centre fallback coords', () => {
    expect(
      isGeocodedUpToDate({
        latitude: -17.8,
        longitude: 31.0,
        geocode_quality: 'city_centre',
      }),
    ).toBe(false);
  });

  it('returns false for city_only quality', () => {
    expect(
      isGeocodedUpToDate({
        latitude: -17.8,
        longitude: 31.0,
        geocode_quality: 'city_only',
      }),
    ).toBe(false);
  });
});

describe('getGeocodeStatus', () => {
  it('returns ok when geocoded up to date', () => {
    expect(
      getGeocodeStatus({
        latitude: -17.8,
        longitude: 31.0,
        geocode_quality: 'address',
      }),
    ).toBe('ok');
  });

  it('returns missing when coordinates are absent', () => {
    expect(
      getGeocodeStatus({
        latitude: null,
        longitude: null,
        geocode_quality: null,
      }),
    ).toBe('missing');
  });

  it('returns low_quality for city-centre coords', () => {
    expect(
      getGeocodeStatus({
        latitude: -17.8,
        longitude: 31.0,
        geocode_quality: 'city_centre',
      }),
    ).toBe('low_quality');
  });
});
