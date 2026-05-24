import { query } from '../lib/db.js';
import { NotFoundError } from '../lib/errors.js';
import { buildPaginationMeta, paginationOffset, parseSort } from '../lib/pagination.js';
import { normalizeSearchQuery } from '../lib/search-query.js';
import { searchFacilitiesRanked } from './search.service.js';

interface FacilityRow {
  id: string;
  name: string;
  slug: string;
  facility_type: string;
  description: string | null;
  address_line1: string | null;
  city: string;
  province: string;
  phone: string | null;
  email: string | null;
  website: string | null;
  latitude: number | null;
  longitude: number | null;
  distance_km: number | null;
  is_verified: boolean;
  logo_path: string | null;
}

function mapFacility(row: FacilityRow, includeDistance = false) {
  return {
    id: row.id,
    name: row.name,
    slug: row.slug,
    facilityType: row.facility_type,
    description: row.description,
    addressLine1: row.address_line1,
    city: row.city,
    province: row.province,
    phone: row.phone,
    email: row.email,
    website: row.website,
    latitude: row.latitude,
    longitude: row.longitude,
    ...(includeDistance && row.distance_km != null ? { distanceKm: Number(row.distance_km) } : {}),
    isVerified: row.is_verified,
    logoPath: row.logo_path,
  };
}

export async function listFacilities(options: {
  page: number;
  limit: number;
  sortBy?: string;
  q?: string;
  province?: string;
  city?: string;
  facilityType?: string;
  isVerified?: boolean;
  openNow?: boolean;
  hasQueue?: boolean;
  lat?: number;
  lon?: number;
  radiusKm?: number;
}) {
  const q = normalizeSearchQuery(options.q);
  const useRankedSearch =
    q != null ||
    options.openNow === true ||
    options.hasQueue === true ||
    (options.lat != null && options.lon != null);

  if (useRankedSearch) {
    return searchFacilitiesRanked({
      page: options.page,
      limit: options.limit,
      q,
      province: options.province,
      city: options.city,
      facilityType: options.facilityType,
      isVerified: options.isVerified,
      openNow: options.openNow,
      hasQueue: options.hasQueue,
      lat: options.lat,
      lon: options.lon,
      radiusKm: options.radiusKm,
    });
  }

  const conditions = ['is_active = true'];
  const params: unknown[] = [];
  let idx = 1;

  if (options.q) {
    conditions.push(`search_vector @@ plainto_tsquery('english', $${idx++})`);
    params.push(options.q);
  }
  if (options.province) {
    conditions.push(`province = $${idx++}::public.zimbabwe_province`);
    params.push(options.province);
  }
  if (options.city) {
    conditions.push(`city ILIKE $${idx++}`);
    params.push(`%${options.city}%`);
  }
  if (options.facilityType) {
    conditions.push(`facility_type = $${idx++}::public.facility_type`);
    params.push(options.facilityType);
  }
  if (options.isVerified !== undefined) {
    conditions.push(`is_verified = $${idx++}`);
    params.push(options.isVerified);
  }

  const where = conditions.join(' AND ');
  const sort = parseSort(options.sortBy, { name: 'name', city: 'city', createdAt: 'created_at' }, 'name');
  const offset = paginationOffset(options.page, options.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.facilities WHERE ${where}`,
    params,
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const result = await query<FacilityRow>(
    `SELECT id, name, slug, facility_type, description, address_line1, city, province,
            phone, email, website, latitude, longitude, is_verified, logo_path,
            NULL::float AS distance_km
     FROM public.facilities
     WHERE ${where}
     ORDER BY ${sort.column} ${sort.order}
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, options.limit, offset],
  );

  return {
    facilities: result.rows.map((r) => mapFacility(r)),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}

export async function getFacilityById(id: string) {
  const result = await query<FacilityRow>(
    `SELECT id, name, slug, facility_type, description, address_line1, city, province,
            phone, email, website, latitude, longitude, is_verified, logo_path,
            NULL::float AS distance_km
     FROM public.facilities
     WHERE id = $1 AND is_active = true`,
    [id],
  );

  if (!result.rows[0]) throw new NotFoundError('Facility', id);
  return mapFacility(result.rows[0]);
}

export async function nearbyFacilities(options: {
  lat: number;
  lon: number;
  radiusKm: number;
  page: number;
  limit: number;
}) {
  const offset = paginationOffset(options.page, options.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM public.facilities f
     WHERE f.is_active = true
       AND f.latitude IS NOT NULL
       AND f.longitude IS NOT NULL
       AND ST_DWithin(
         ST_SetSRID(ST_MakePoint(f.longitude, f.latitude), 4326)::geography,
         ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
         $3 * 1000
       )`,
    [options.lon, options.lat, options.radiusKm],
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const result = await query<FacilityRow>(
    `SELECT id, name, slug, facility_type, description, address_line1, city, province,
            phone, email, website, latitude, longitude, is_verified, logo_path,
            ST_Distance(
              ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
              ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
            ) / 1000.0 AS distance_km
     FROM public.facilities f
     WHERE f.is_active = true
       AND f.latitude IS NOT NULL
       AND f.longitude IS NOT NULL
       AND ST_DWithin(
         ST_SetSRID(ST_MakePoint(f.longitude, f.latitude), 4326)::geography,
         ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
         $3 * 1000
       )
     ORDER BY distance_km ASC
     LIMIT $4 OFFSET $5`,
    [options.lon, options.lat, options.radiusKm, options.limit, offset],
  );

  return {
    facilities: result.rows.map((r) => mapFacility(r, true)),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}
