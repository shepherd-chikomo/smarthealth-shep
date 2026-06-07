import { query } from '../lib/db.js';
import { buildPaginationMeta, paginationOffset } from '../lib/pagination.js';
import { buildTextMatchCondition, normalizeSearchQuery } from '../lib/search-query.js';
import { effectiveFacilityTypes, sqlFacilityMatchesType } from '../lib/facility-types.js';

export interface ProviderSearchOptions {
  page: number;
  limit: number;
  q?: string;
  categoryId?: string;
  specialtyId?: string;
  specialties?: string[];
  conditions?: string[];
  ageGroups?: string[];
  lat?: number;
  lon?: number;
  radiusKm?: number;
  isVerified?: boolean;
  openNow?: boolean;
  hasQueue?: boolean;
  city?: string;
  province?: string;
  facilityId?: string;
}

interface ProviderSearchRow {
  id: string;
  name: string;
  category_id: string | null;
  specialty: string | null;
  specialty_id: string | null;
  facility_id: string;
  facility_name: string | null;
  facility_city: string | null;
  address: string | null;
  phone: string | null;
  latitude: number | null;
  longitude: number | null;
  distance_km: number | null;
  image_path: string | null;
  hero_image_path: string | null;
  is_verified: boolean;
  facility_verified: boolean;
  is_accepting_bookings: boolean;
  mdpcz_number: string | null;
  about: string | null;
  services: string[];
  conditions: string[];
  age_groups: string[];
  average_rating: number | null;
  review_count: number | null;
  is_open_now: boolean;
  has_queue: boolean;
  rank_score: number;
}

function mapProviderRow(row: ProviderSearchRow) {
  return {
    id: row.id,
    name: row.name,
    categoryId: row.category_id,
    specialty: row.specialty,
    specialtyId: row.specialty_id,
    facilityId: row.facility_id,
    facilityName: row.facility_name,
    facilityCity: row.facility_city,
    address: row.address,
    phone: row.phone,
    latitude: row.latitude,
    longitude: row.longitude,
    ...(row.distance_km != null ? { distanceKm: Number(row.distance_km) } : {}),
    imageUrl: row.image_path,
    heroImageUrl: row.hero_image_path,
    isVerified: row.is_verified,
    facilityVerified: row.facility_verified,
    isAcceptingBookings: row.is_accepting_bookings,
    mdpczNumber: row.mdpcz_number,
    about: row.about,
    services: row.services ?? [],
    conditions: row.conditions ?? [],
    ageGroups: row.age_groups ?? [],
    averageRating: row.average_rating != null ? Number(row.average_rating) : null,
    reviewCount: row.review_count ?? 0,
    isOpenNow: row.is_open_now,
    hasQueue: row.has_queue,
    relevanceScore: Number(row.rank_score),
  };
}

const BASE_FROM = `
  FROM public.providers p
  INNER JOIN public.provider_facility_links pfl ON pfl.provider_id = p.id AND pfl.is_primary = true
  JOIN public.facilities f ON f.id = pfl.facility_id
  LEFT JOIN (
    SELECT provider_id,
           AVG(rating)::numeric(3,2) AS avg_rating,
           COUNT(*)::int AS review_count
    FROM public.provider_reviews
    WHERE deleted_at IS NULL
    GROUP BY provider_id
  ) pr ON pr.provider_id = p.id
`;

export async function searchProvidersRanked(options: ProviderSearchOptions) {
  const q = normalizeSearchQuery(options.q);
  const conditions = [
    'p.is_active = true',
    'p.is_verified = true',
    'f.is_active = true',
    'f.deleted_at IS NULL',
  ];
  const params: unknown[] = [];
  let idx = 1;

  let queryParamIdx: number | null = null;
  let specialtyParamIdx: number | null = null;
  let lonParamIdx: number | null = null;
  let latParamIdx: number | null = null;

  if (q) {
    conditions.push(
      buildTextMatchCondition({ query: q, queryParamIdx: idx }),
    );
    queryParamIdx = idx;
    params.push(q);
    idx++;
  }

  if (options.categoryId) {
    conditions.push(`p.category_id = $${idx++}`);
    params.push(options.categoryId);
  }
  if (options.specialtyId) {
    specialtyParamIdx = idx;
    conditions.push(`p.specialty_id = $${idx++}`);
    params.push(options.specialtyId);
  }
  if (options.specialties?.length) {
    conditions.push(`EXISTS (
      SELECT 1 FROM public.provider_specialties ps
      JOIN public.specialties s ON s.id = ps.specialty_id AND s.is_active = true
      WHERE ps.provider_id = p.id AND s.slug = ANY($${idx++})
    )`);
    params.push(options.specialties);
  }
  if (options.conditions?.length) {
    conditions.push(`EXISTS (
      SELECT 1 FROM unnest(p.conditions) AS c(val)
      WHERE lower(regexp_replace(trim(c.val), '[^a-zA-Z0-9]+', '_', 'g')) = ANY($${idx++})
    )`);
    params.push(options.conditions);
  }
  if (options.ageGroups?.length) {
    conditions.push(`EXISTS (
      SELECT 1 FROM unnest(p.age_groups) AS g(val)
      WHERE lower(regexp_replace(trim(g.val), '[^a-zA-Z0-9]+', '_', 'g')) = ANY($${idx++})
    )`);
    params.push(options.ageGroups);
  }
  if (options.isVerified !== undefined) {
    conditions.push(`(p.is_verified = $${idx} OR f.is_verified = $${idx})`);
    params.push(options.isVerified);
    idx++;
  }
  if (options.openNow) {
    conditions.push('public.is_facility_open_now(f.id) = true');
  }
  if (options.hasQueue) {
    conditions.push('public.facility_has_active_queue(f.id) = true');
  }
  if (options.city) {
    conditions.push(`f.city ILIKE $${idx++}`);
    params.push(`%${options.city}%`);
  }
  if (options.province) {
    conditions.push(`f.province = $${idx++}::public.zimbabwe_province`);
    params.push(options.province);
  }
  if (options.facilityId) {
    conditions.push(`p.facility_id = $${idx++}`);
    params.push(options.facilityId);
  }

  const hasGeo = options.lat != null && options.lon != null && !q;
  let distanceExpr = 'NULL::double precision';

  if (hasGeo) {
    lonParamIdx = idx;
    latParamIdx = idx + 1;
    distanceExpr = `
      ST_Distance(
        ST_SetSRID(ST_MakePoint(f.longitude, f.latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint($${lonParamIdx}, $${latParamIdx}), 4326)::geography
      ) / 1000.0`;
    params.push(options.lon, options.lat);
    idx += 2;

    if (options.radiusKm) {
      conditions.push(`
        f.latitude IS NOT NULL
        AND f.longitude IS NOT NULL
        AND ST_DWithin(
          ST_SetSRID(ST_MakePoint(f.longitude, f.latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint($${lonParamIdx}, $${latParamIdx}), 4326)::geography,
          $${idx++} * 1000
        )`);
      params.push(options.radiusKm);
    }
  }

  const rankExpr = `
    public.compute_provider_search_rank(
      ${queryParamIdx ? `$${queryParamIdx}` : 'NULL'},
      ${specialtyParamIdx ? `$${specialtyParamIdx}::uuid` : 'NULL'},
      p.specialty_id,
      p.specialty,
      public.is_facility_open_now(f.id),
      p.is_verified,
      f.is_verified,
      ${distanceExpr},
      public.facility_has_active_queue(f.id),
      pr.avg_rating,
      p.is_accepting_bookings,
      public.facility_completeness_score(f.id),
      p.search_vector,
      f.search_vector,
      p.name
    )`;

  const where = conditions.join(' AND ');
  const offset = paginationOffset(options.page, options.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count ${BASE_FROM} WHERE ${where}`,
    params,
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const result = await query<ProviderSearchRow>(
    `SELECT
       p.id, p.name, p.category_id, p.specialty, p.specialty_id, p.facility_id,
       f.name AS facility_name, f.city AS facility_city,
       COALESCE(f.address_line1, '') AS address,
       COALESCE(p.phone, f.phone) AS phone,
       f.latitude, f.longitude,
       p.image_path, p.hero_image_path,
       p.is_verified, f.is_verified AS facility_verified,
       p.is_accepting_bookings, p.mdpcz_number, p.about,
       p.services, p.conditions, p.age_groups,
       COALESCE(pr.avg_rating, 0)::float AS average_rating,
       COALESCE(pr.review_count, 0)::int AS review_count,
       public.is_facility_open_now(f.id) AS is_open_now,
       public.facility_has_active_queue(f.id) AS has_queue,
       (${distanceExpr})::float AS distance_km,
       (${rankExpr})::float AS rank_score
     ${BASE_FROM}
     WHERE ${where}
     ORDER BY rank_score DESC, p.name ASC
     LIMIT $${idx} OFFSET $${idx + 1}`,
    [...params, options.limit, offset],
  );

  return {
    providers: result.rows.map(mapProviderRow),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}

export interface FacilitySearchOptions {
  page: number;
  limit: number;
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
  medicalAidSchemeKeys?: string[];
  userMedicalAidSchemeKey?: string;
}

const ACCEPTED_MEDICAL_AID_KEYS_SQL = `(
  SELECT COALESCE(array_agg(elem->>'schemeKey'), ARRAY[]::text[])
  FROM jsonb_array_elements(COALESCE(f.settings->'profile'->'medicalAids', '[]'::jsonb)) elem
  WHERE elem->>'schemeKey' IS NOT NULL AND elem->>'schemeKey' <> ''
)`;

export async function searchFacilitiesRanked(options: FacilitySearchOptions) {
  const q = normalizeSearchQuery(options.q);
  const conditions = ['f.is_active = true', 'f.deleted_at IS NULL'];
  const params: unknown[] = [];
  let idx = 1;
  let queryParamIdx: number | null = null;
  let lonParamIdx: number | null = null;
  let latParamIdx: number | null = null;

  if (q) {
    queryParamIdx = idx;
    conditions.push(
      buildTextMatchCondition({
        query: q,
        queryParamIdx: idx,
        providerVectorCol: 'NULL::tsvector',
        providerNameCol: "''",
        providerSpecialtyCol: "''",
        facilityVectorCol: 'f.search_vector',
        facilityNameCol: 'f.name',
        facilityCityCol: 'f.city',
        facilityAddressCol: 'f.address_line1',
      }),
    );
    params.push(q);
    idx++;
  }
  if (options.province) {
    conditions.push(`f.province = $${idx++}::public.zimbabwe_province`);
    params.push(options.province);
  }
  if (options.city) {
    conditions.push(`f.city ILIKE $${idx++}`);
    params.push(`%${options.city}%`);
  }
  if (options.facilityType) {
    conditions.push(sqlFacilityMatchesType('f', `$${idx++}`));
    params.push(options.facilityType);
  }
  if (options.isVerified !== undefined) {
    conditions.push(`f.is_verified = $${idx++}`);
    params.push(options.isVerified);
  }
  if (options.openNow) {
    conditions.push('public.is_facility_open_now(f.id) = true');
  }
  if (options.hasQueue) {
    conditions.push('public.facility_has_active_queue(f.id) = true');
  }
  if (options.medicalAidSchemeKeys?.length) {
    conditions.push(`
      EXISTS (
        SELECT 1
        FROM jsonb_array_elements(COALESCE(f.settings->'profile'->'medicalAids', '[]'::jsonb)) elem
        WHERE elem->>'schemeKey' = ANY($${idx++}::text[])
      )`);
    params.push(options.medicalAidSchemeKeys);
  }

  const hasGeo = options.lat != null && options.lon != null && !q;
  let distanceExpr = 'NULL::double precision';
  if (hasGeo) {
    lonParamIdx = idx;
    latParamIdx = idx + 1;
    distanceExpr = `
      ST_Distance(
        ST_SetSRID(ST_MakePoint(f.longitude, f.latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint($${lonParamIdx}, $${latParamIdx}), 4326)::geography
      ) / 1000.0`;
    params.push(options.lon, options.lat);
    idx += 2;
    if (options.radiusKm) {
      conditions.push(`
        f.latitude IS NOT NULL
        AND f.longitude IS NOT NULL
        AND ST_DWithin(
          ST_SetSRID(ST_MakePoint(f.longitude, f.latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint($${lonParamIdx}, $${latParamIdx}), 4326)::geography,
          $${idx++} * 1000
        )`);
      params.push(options.radiusKm);
    }
  }

  const rankExpr = `
    (
      ${queryParamIdx ? `CASE WHEN f.search_vector @@ websearch_to_tsquery('english', $${queryParamIdx}) THEN 100 ELSE 0 END` : '0'}
      + CASE WHEN public.is_facility_open_now(f.id) THEN 500 ELSE 0 END
      + CASE WHEN f.is_verified THEN 200 ELSE 0 END
      + CASE WHEN public.facility_has_active_queue(f.id) THEN 100 ELSE 0 END
      + CASE WHEN ${distanceExpr} IS NOT NULL THEN GREATEST(0, 150 - (${distanceExpr}) * 5) ELSE 0 END
      + public.facility_completeness_score(f.id) * 20
      ${queryParamIdx ? `+ ts_rank_cd(f.search_vector, websearch_to_tsquery('english', $${queryParamIdx})) * 10` : ''}
      ${queryParamIdx ? `+ similarity(f.name, $${queryParamIdx}) * 5` : ''}
    )`;

  const where = conditions.join(' AND ');
  const offset = paginationOffset(options.page, options.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.facilities f WHERE ${where}`,
    params,
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const result = await query<{
    id: string;
    name: string;
    slug: string;
    facility_type: string;
    facility_types: string[] | null;
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
    is_open_now: boolean;
    has_queue: boolean;
    rank_score: number;
    provider_count: number;
    accepted_medical_aid_scheme_keys: string[];
  }>(
    `SELECT f.id, f.name, f.slug, f.facility_type, f.facility_types, f.description, f.address_line1,
            f.city, f.province, f.phone, f.email, f.website,
            f.latitude, f.longitude, f.is_verified, f.logo_path,
            public.is_facility_open_now(f.id) AS is_open_now,
            public.facility_has_active_queue(f.id) AS has_queue,
            (${distanceExpr})::float AS distance_km,
            (SELECT COUNT(*)::int FROM public.providers p WHERE p.facility_id = f.id AND p.is_active) AS provider_count,
            (${rankExpr})::float AS rank_score,
            ${ACCEPTED_MEDICAL_AID_KEYS_SQL} AS accepted_medical_aid_scheme_keys
     FROM public.facilities f
     WHERE ${where}
     ORDER BY rank_score DESC, f.name ASC
     LIMIT $${idx} OFFSET $${idx + 1}`,
    [...params, options.limit, offset],
  );

  return {
    facilities: result.rows.map((row) => {
      const acceptedMedicalAidSchemeKeys = row.accepted_medical_aid_scheme_keys ?? [];
      const userScheme = options.userMedicalAidSchemeKey?.trim();
      return {
        id: row.id,
        name: row.name,
        slug: row.slug,
        facilityType: row.facility_type,
        facilityTypes: effectiveFacilityTypes(row),
        description: row.description,
        addressLine1: row.address_line1,
        city: row.city,
        province: row.province,
        phone: row.phone,
        email: row.email,
        website: row.website,
        latitude: row.latitude,
        longitude: row.longitude,
        ...(row.distance_km != null ? { distanceKm: Number(row.distance_km) } : {}),
        isVerified: row.is_verified,
        logoPath: row.logo_path,
        isOpenNow: row.is_open_now,
        hasQueue: row.has_queue,
        providerCount: row.provider_count,
        relevanceScore: Number(row.rank_score),
        acceptedMedicalAidSchemeKeys,
        ...(userScheme
          ? {
              acceptsYourMedicalAid: acceptedMedicalAidSchemeKeys.includes(userScheme),
            }
          : {}),
      };
    }),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}

export async function searchSpecialties(options: {
  page: number;
  limit: number;
  q?: string;
  facilityId?: string;
}) {
  const q = normalizeSearchQuery(options.q);
  const conditions = ['s.is_active = true'];
  const params: unknown[] = [];
  let idx = 1;

  if (q) {
    conditions.push(`(
      s.search_vector @@ websearch_to_tsquery('english', $${idx})
      OR s.name ILIKE $${idx + 1}
      OR similarity(s.name, $${idx}) > 0.25
    )`);
    params.push(q, `%${q}%`);
    idx += 2;
  }
  if (options.facilityId) {
    conditions.push(`(s.tenant_id IS NULL OR s.tenant_id = $${idx++})`);
    params.push(options.facilityId);
  }

  const where = conditions.join(' AND ');
  const offset = paginationOffset(options.page, options.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.specialties s WHERE ${where}`,
    params,
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const rankOrder = q
    ? `GREATEST(
         ts_rank_cd(s.search_vector, websearch_to_tsquery('english', $1)),
         similarity(s.name, $1)
       ) DESC, s.name ASC`
    : 's.name ASC';

  const result = await query<{
    id: string;
    name: string;
    slug: string;
    category: string | null;
    description: string | null;
    icd_code: string | null;
  }>(
    `SELECT s.id, s.name, s.slug, s.category, s.description, s.icd_code
     FROM public.specialties s
     WHERE ${where}
     ORDER BY ${rankOrder}
     LIMIT $${idx} OFFSET $${idx + 1}`,
    [...params, options.limit, offset],
  );

  return {
    specialties: result.rows.map((row) => ({
      id: row.id,
      name: row.name,
      slug: row.slug,
      category: row.category,
      description: row.description,
      icdCode: row.icd_code,
    })),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}

export async function searchEmergencyNearby(options: {
  lat: number;
  lon: number;
  radiusKm: number;
  page: number;
  limit: number;
  q?: string;
  serviceType?: string;
  openNow?: boolean;
}) {
  const q = normalizeSearchQuery(options.q);
  const conditions = [
    'es.deleted_at IS NULL',
    'es.is_active = true',
    `ST_DWithin(
      es.location,
      ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
      $3 * 1000
    )`,
  ];
  const params: unknown[] = [options.lon, options.lat, options.radiusKm];
  let idx = 4;

  if (q) {
    conditions.push(`(
      es.search_vector @@ websearch_to_tsquery('english', $${idx})
      OR es.name ILIKE $${idx + 1}
      OR similarity(es.name, $${idx}) > 0.25
    )`);
    params.push(q, `%${q}%`);
    idx += 2;
  }
  if (options.serviceType) {
    conditions.push(`es.service_type = $${idx++}::public.emergency_service_type`);
    params.push(options.serviceType);
  }
  if (options.openNow) {
    conditions.push('es.is_24_hours = true');
  }

  const where = conditions.join(' AND ');
  const offset = paginationOffset(options.page, options.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.emergency_services es WHERE ${where}`,
    params,
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const result = await query<{
    id: string;
    name: string;
    service_type: string;
    phone: string;
    alternate_phone: string | null;
    address: string | null;
    city: string;
    province: string;
    latitude: number;
    longitude: number;
    is_24_hours: boolean;
    distance_km: number;
  }>(
    `SELECT es.id, es.name, es.service_type, es.phone, es.alternate_phone,
            es.address, es.city, es.province, es.latitude, es.longitude, es.is_24_hours,
            ST_Distance(es.location, ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography) / 1000.0 AS distance_km
     FROM public.emergency_services es
     WHERE ${where}
     ORDER BY
       CASE WHEN es.is_24_hours THEN 0 ELSE 1 END,
       distance_km ASC
     LIMIT $${idx} OFFSET $${idx + 1}`,
    [...params, options.limit, offset],
  );

  return {
    services: result.rows.map((row) => ({
      id: row.id,
      name: row.name,
      serviceType: row.service_type,
      phone: row.phone,
      alternatePhone: row.alternate_phone,
      address: row.address,
      city: row.city,
      province: row.province,
      latitude: row.latitude,
      longitude: row.longitude,
      distanceKm: Number(row.distance_km),
      is24Hours: row.is_24_hours,
    })),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}

export async function unifiedSearch(options: {
  q?: string;
  lat?: number;
  lon?: number;
  radiusKm?: number;
  limit?: number;
}) {
  const limit = Math.min(options.limit ?? 5, 20);
  const [providers, facilities, specialties] = await Promise.all([
    searchProvidersRanked({
      page: 1,
      limit,
      q: options.q,
      lat: options.lat,
      lon: options.lon,
      radiusKm: options.radiusKm,
    }),
    searchFacilitiesRanked({
      page: 1,
      limit,
      q: options.q,
      lat: options.lat,
      lon: options.lon,
      radiusKm: options.radiusKm,
    }),
    searchSpecialties({ page: 1, limit: Math.min(limit, 10), q: options.q }),
  ]);

  const emergency =
    options.lat != null && options.lon != null
      ? await searchEmergencyNearby({
          lat: options.lat,
          lon: options.lon,
          radiusKm: options.radiusKm ?? 50,
          page: 1,
          limit: Math.min(limit, 10),
          q: options.q,
        })
      : { services: [], pagination: buildPaginationMeta(1, 0, 0) };

  return { providers, facilities, specialties, emergency };
}
