import { query } from '../lib/db.js';
import { EMERGENCY_HOSPITAL_CLASSIFICATIONS } from '../lib/facility-classification.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { getNationalEmergencyServices } from './national-emergency.service.js';
import { searchEmergencyNearby } from './search.service.js';

const GRID_SERVICE_TYPES = new Set(['ambulance', 'police', 'fire', 'disaster_response']);

const EMERGENCY_OFFERED_SQL = `(
  COALESCE((f.settings->'profile'->'emergency'->>'department')::boolean, false)
  OR COALESCE((f.settings->'profile'->'emergency'->>'ambulance')::boolean, false)
  OR COALESCE((f.settings->'profile'->'emergency'->>'trauma')::boolean, false)
  OR COALESCE((f.settings->'profile'->'emergency'->>'icu')::boolean, false)
  OR COALESCE((f.settings->'profile'->'emergency'->>'is24Hour')::boolean, false)
)`;

const CLASSIFIED_HOSPITAL_SQL = `f.facility_category IN (${EMERGENCY_HOSPITAL_CLASSIFICATIONS.map((c) => `'${c.replace(/'/g, "''")}'`).join(', ')})`;

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
  pendingVerification: boolean;
}

export interface EmergencyHubGridService {
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
  isNational: boolean;
}

export interface EmergencyHubAmbulanceService {
  id: string;
  name: string;
  serviceType: 'ambulance';
  phone: string;
  alternatePhone: string | null;
  address: string | null;
  city: string;
  province: string;
  latitude: number;
  longitude: number;
  distanceKm: number;
  ambulanceServiceTypes: string[];
  is24Hours: boolean;
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

function normalizePhone(phone: string): string {
  return phone.replace(/\D/g, '');
}

function isUuid(id: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id);
}

export function dedupeGridServices(items: EmergencyHubGridService[]): EmergencyHubGridService[] {
  const byKey = new Map<string, EmergencyHubGridService>();
  for (const item of items) {
    const key = item.isNational
      ? `national:${item.serviceType}`
      : `local:${item.serviceType}:${normalizePhone(item.phone)}`;
    const existing = byKey.get(key);
    if (!existing) {
      byKey.set(key, item);
      continue;
    }
    if (item.isNational && !existing.isNational) {
      byKey.set(key, item);
      continue;
    }
    if (!item.isNational && !existing.isNational) {
      const preferItem = isUuid(existing.id) && !isUuid(item.id);
      if (preferItem) byKey.set(key, item);
    }
  }
  return [...byKey.values()];
}

type FacilityRow = {
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
  is_24_hour: boolean;
  is_verified: boolean;
  verification_status: string;
};

function mapClassifiedHospital(row: FacilityRow): EmergencyHubFacility {
  return {
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
    source: 'government_hospital' as const,
    referralLabel: row.facility_category,
    pendingVerification:
      row.verification_status !== 'verified' || row.is_verified !== true,
  };
}

async function searchClassifiedEmergencyHospitals(options: {
  lat: number;
  lon: number;
  radiusKm: number | null;
  limit: number;
}): Promise<EmergencyHubFacility[]> {
  const radiusClause =
    options.radiusKm != null
      ? `AND ST_DWithin(
           ST_SetSRID(ST_MakePoint(f.longitude, f.latitude), 4326)::geography,
           ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
           $3 * 1000
         )`
      : '';

  const params: unknown[] = [options.lon, options.lat];
  if (options.radiusKm != null) params.push(options.radiusKm);
  params.push(options.limit);

  const limitParam = options.radiusKm != null ? '$4' : '$3';

  const result = await query<FacilityRow>(
    `SELECT f.id, f.name, f.phone, f.whatsapp_phone, f.address_line1 AS address, f.city, f.province,
            f.latitude, f.longitude, f.facility_category,
            f.is_verified,
            f.verification_status::text AS verification_status,
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
       AND ${CLASSIFIED_HOSPITAL_SQL}
       AND (
         ${EMERGENCY_OFFERED_SQL}
         OR f.facility_category IN ('Central Hospital', 'Provincial Hospital')
       )
       ${radiusClause}
     ORDER BY distance_km ASC
     LIMIT ${limitParam}`,
    params,
  );

  return result.rows.map(mapClassifiedHospital);
}

async function searchAmbulanceFacilities(options: {
  lat: number;
  lon: number;
  radiusKm: number;
  limit: number;
}): Promise<EmergencyHubAmbulanceService[]> {
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
    ambulance_types: string[] | null;
    is_24_hour: boolean;
  }>(
    `SELECT f.id, f.name, f.phone, f.whatsapp_phone, f.address_line1 AS address, f.city, f.province,
            f.latitude, f.longitude,
            COALESCE(
              ARRAY(
                SELECT jsonb_array_elements_text(
                  COALESCE(f.settings->'profile'->'ambulanceServiceTypes', '[]'::jsonb)
                )
              ),
              ARRAY[]::text[]
            ) AS ambulance_types,
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
       AND f.facility_category = 'Ambulance Service'
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
    serviceType: 'ambulance' as const,
    phone: row.phone ?? row.whatsapp_phone ?? '',
    alternatePhone: null,
    address: row.address,
    city: row.city,
    province: row.province,
    latitude: row.latitude,
    longitude: row.longitude,
    distanceKm: Number(row.distance_km),
    ambulanceServiceTypes: row.ambulance_types ?? [],
    is24Hours: row.is_24_hour,
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
    const national = getNationalEmergencyServices().map((s) => ({
      id: s.id,
      name: s.name,
      serviceType: s.serviceType,
      phone: s.phone,
      alternatePhone: null,
      address: null,
      city: s.city,
      province: s.province,
      latitude: s.latitude,
      longitude: s.longitude,
      distanceKm: 0,
      is24Hours: true,
      isNational: s.isNational,
    }));

    return {
      services: national,
      facilities: [],
      ambulanceServices: [],
      expandedSearch: false,
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

  const nationalServices = getNationalEmergencyServices({ lat, lon }).map((s) => ({
    id: s.id,
    name: s.name,
    serviceType: s.serviceType,
    phone: s.phone,
    alternatePhone: null,
    address: null,
    city: s.city,
    province: s.province,
    latitude: s.latitude,
    longitude: s.longitude,
    distanceKm: 0,
    is24Hours: true,
    isNational: s.isNational,
  }));

  const nearbyGrid = directory.services
    .filter((s) => GRID_SERVICE_TYPES.has(s.serviceType))
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
      isNational: false,
    }));

  const gridServices = dedupeGridServices([...nationalServices, ...nearbyGrid]);

  let classifiedHospitals = await searchClassifiedEmergencyHospitals({
    lat,
    lon,
    radiusKm,
    limit: 100,
  });

  let expandedSearch = false;
  if (classifiedHospitals.length === 0) {
    classifiedHospitals = await searchClassifiedEmergencyHospitals({
      lat,
      lon,
      radiusKm: null,
      limit: 10,
    });
    expandedSearch = classifiedHospitals.length > 0;
  }

  // Hospitals section: classified facility tiers only.
  const hospitalFacilities = classifiedHospitals;

  const ambulanceServices = await searchAmbulanceFacilities({
    lat,
    lon,
    radiusKm,
    limit: 50,
  });

  const merged = sortFacilities(dedupeFacilities(hospitalFacilities));

  const offset = (page - 1) * limit;
  const pagedFacilities = merged.slice(offset, offset + limit);

  return {
    services: gridServices,
    facilities: pagedFacilities,
    ambulanceServices,
    expandedSearch,
    locationRequired: false,
    pagination: buildPaginationMeta(page, limit, merged.length),
  };
}
