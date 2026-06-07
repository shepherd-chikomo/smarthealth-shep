import { query } from '../lib/db.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { searchEmergencyNearby } from './search.service.js';

const GRID_SERVICE_TYPES = new Set(['ambulance', 'police', 'fire', 'disaster_response']);

const GOV_HOSPITAL_SQL = `(
  f.ownership_type ILIKE '%government%'
  OR f.ownership_type ILIKE '%public%'
  OR f.ownership_type ILIKE '%ministry%'
  OR f.facility_category ILIKE '%central%'
  OR f.facility_category ILIKE '%provincial%'
  OR f.facility_category ILIKE '%district%'
  OR f.facility_category ILIKE '%referral%'
)`;

const PROFILE_EMERGENCY_SQL = `(
  COALESCE((f.settings->'profile'->'emergency'->>'department')::boolean, false)
  OR COALESCE((f.settings->'profile'->'emergency'->>'ambulance')::boolean, false)
  OR COALESCE((f.settings->'profile'->'emergency'->>'trauma')::boolean, false)
  OR COALESCE((f.settings->'profile'->'emergency'->>'icu')::boolean, false)
  OR COALESCE((f.settings->'profile'->'emergency'->>'is24Hour')::boolean, false)
)`;

export type EmergencyHubFacilitySource =
  | 'emergency_directory'
  | 'government_hospital'
  | 'profile_emergency';

export interface EmergencyHubFacility {
  id: string;
  name: string;
  serviceType: string;
  phone: string;
  alternatePhone: string | null;
  address: string | null;
  city: string;
  province: string;
  latitude: number;
  longitude: number;
  distanceKm: number;
  is24Hours: boolean;
  source: EmergencyHubFacilitySource;
  referralLabel: string | null;
}

const SOURCE_PRIORITY: Record<EmergencyHubFacilitySource, number> = {
  emergency_directory: 0,
  profile_emergency: 1,
  government_hospital: 2,
};

export function dedupeFacilities(items: EmergencyHubFacility[]): EmergencyHubFacility[] {
  const byKey = new Map<string, EmergencyHubFacility>();
  for (const item of items) {
    const key = item.id;
    const existing = byKey.get(key);
    if (!existing) {
      byKey.set(key, item);
      continue;
    }
    const keep =
      SOURCE_PRIORITY[item.source] < SOURCE_PRIORITY[existing.source]
        ? item
        : existing;
    byKey.set(key, keep);
  }
  return [...byKey.values()];
}

export function sortFacilities(items: EmergencyHubFacility[]): EmergencyHubFacility[] {
  return [...items].sort((a, b) => {
    if (a.is24Hours !== b.is24Hours) return a.is24Hours ? -1 : 1;
    if (a.distanceKm !== b.distanceKm) return a.distanceKm - b.distanceKm;
    return SOURCE_PRIORITY[a.source] - SOURCE_PRIORITY[b.source];
  });
}

async function searchGovernmentHospitals(options: {
  lat: number;
  lon: number;
  radiusKm: number;
  limit: number;
}): Promise<EmergencyHubFacility[]> {
  const result = await query<{
    id: string;
    name: string;
    phone: string | null;
    whatsapp_phone: string | null;
    address: string | null;
    city: string;
    province: string;
    latitude: number;
    longitude: number;
    facility_category: string | null;
    distance_km: number;
  }>(
    `SELECT f.id, f.name, f.phone, f.whatsapp_phone, f.address, f.city, f.province,
            f.latitude, f.longitude, f.facility_category,
            ST_Distance(
              ST_SetSRID(ST_MakePoint(f.longitude, f.latitude), 4326)::geography,
              ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
            ) / 1000.0 AS distance_km
     FROM public.facilities f
     WHERE f.is_active = true
       AND f.deleted_at IS NULL
       AND f.latitude IS NOT NULL
       AND f.longitude IS NOT NULL
       AND f.facility_type = 'hospital'
       AND ${GOV_HOSPITAL_SQL}
       AND ST_DWithin(
         ST_SetSRID(ST_MakePoint(f.longitude, f.latitude), 4326)::geography,
         ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
         $3 * 1000
       )
     ORDER BY distance_km ASC
     LIMIT $4`,
    [options.lon, options.lat, options.radiusKm, options.limit],
  );

  return result.rows.map((row) => ({
    id: row.id,
    name: row.name,
    serviceType: 'hospital_er',
    phone: row.phone ?? row.whatsapp_phone ?? '',
    alternatePhone: null,
    address: row.address,
    city: row.city,
    province: row.province,
    latitude: row.latitude,
    longitude: row.longitude,
    distanceKm: Number(row.distance_km),
    is24Hours: false,
    source: 'government_hospital' as const,
    referralLabel: row.facility_category,
  }));
}

async function searchProfileEmergencyFacilities(options: {
  lat: number;
  lon: number;
  radiusKm: number;
  limit: number;
}): Promise<EmergencyHubFacility[]> {
  const result = await query<{
    id: string;
    name: string;
    phone: string | null;
    whatsapp_phone: string | null;
    address: string | null;
    city: string;
    province: string;
    latitude: number;
    longitude: number;
    distance_km: number;
    is_24_hour: boolean;
  }>(
    `SELECT f.id, f.name, f.phone, f.whatsapp_phone, f.address, f.city, f.province,
            f.latitude, f.longitude,
            COALESCE((f.settings->'profile'->'emergency'->>'is24Hour')::boolean, false) AS is_24_hour,
            ST_Distance(
              ST_SetSRID(ST_MakePoint(f.longitude, f.latitude), 4326)::geography,
              ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
            ) / 1000.0 AS distance_km
     FROM public.facilities f
     WHERE f.is_active = true
       AND f.deleted_at IS NULL
       AND f.latitude IS NOT NULL
       AND f.longitude IS NOT NULL
       AND ${PROFILE_EMERGENCY_SQL}
       AND ST_DWithin(
         ST_SetSRID(ST_MakePoint(f.longitude, f.latitude), 4326)::geography,
         ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
         $3 * 1000
       )
     ORDER BY
       CASE WHEN COALESCE((f.settings->'profile'->'emergency'->>'is24Hour')::boolean, false) THEN 0 ELSE 1 END,
       distance_km ASC
     LIMIT $4`,
    [options.lon, options.lat, options.radiusKm, options.limit],
  );

  return result.rows.map((row) => ({
    id: row.id,
    name: row.name,
    serviceType: 'hospital_er',
    phone: row.phone ?? row.whatsapp_phone ?? '',
    alternatePhone: null,
    address: row.address,
    city: row.city,
    province: row.province,
    latitude: row.latitude,
    longitude: row.longitude,
    distanceKm: Number(row.distance_km),
    is24Hours: row.is_24_hour,
    source: 'profile_emergency' as const,
    referralLabel: null,
  }));
}

export async function getEmergencyHub(options: {
  lat?: number;
  lon?: number;
  radiusKm?: number;
  page?: number;
  limit?: number;
}) {
  const radiusKm = options.radiusKm ?? 50;
  const limit = Math.min(options.limit ?? 50, 100);
  const page = options.page ?? 1;
  const hasLocation = options.lat != null && options.lon != null;

  if (!hasLocation) {
    return {
      services: [],
      facilities: [],
      locationRequired: true,
      pagination: buildPaginationMeta(page, limit, 0),
    };
  }

  const lat = options.lat!;
  const lon = options.lon!;

  const directory = await searchEmergencyNearby({
    lat,
    lon,
    radiusKm,
    page: 1,
    limit: 200,
  });

  const gridServices = directory.services.filter((s) =>
    GRID_SERVICE_TYPES.has(s.serviceType),
  );

  const directoryFacilities: EmergencyHubFacility[] = directory.services
    .filter((s) => s.serviceType === 'hospital_er' || !GRID_SERVICE_TYPES.has(s.serviceType))
    .map((s) => ({
      id: s.id,
      name: s.name,
      serviceType: s.serviceType,
      phone: s.phone,
      alternatePhone: s.alternatePhone,
      address: s.address,
      city: s.city,
      province: s.province,
      latitude: s.latitude,
      longitude: s.longitude,
      distanceKm: s.distanceKm ?? 0,
      is24Hours: s.is24Hours,
      source: 'emergency_directory' as const,
      referralLabel: null,
    }));

  const [govHospitals, profileEmergency] = await Promise.all([
    searchGovernmentHospitals({ lat, lon, radiusKm, limit: 100 }),
    searchProfileEmergencyFacilities({ lat, lon, radiusKm, limit: 100 }),
  ]);

  const merged = sortFacilities(
    dedupeFacilities([...directoryFacilities, ...govHospitals, ...profileEmergency]),
  );

  const offset = (page - 1) * limit;
  const pagedFacilities = merged.slice(offset, offset + limit);

  return {
    services: gridServices,
    facilities: pagedFacilities,
    locationRequired: false,
    pagination: buildPaginationMeta(page, limit, merged.length),
  };
}
