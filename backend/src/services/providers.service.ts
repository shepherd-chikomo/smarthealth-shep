import { query } from '../lib/db.js';
import { NotFoundError } from '../lib/errors.js';
import { buildPaginationMeta, paginationOffset, parseSort } from '../lib/pagination.js';

interface ProviderRow {
  id: string;
  name: string;
  category_id: string | null;
  specialty: string | null;
  specialty_id: string | null;
  facility_id: string;
  facility_name: string | null;
  address: string | null;
  phone: string | null;
  latitude: number | null;
  longitude: number | null;
  distance_km: number | null;
  image_path: string | null;
  hero_image_path: string | null;
  is_verified: boolean;
  is_accepting_bookings: boolean;
  mdpcz_number: string | null;
  about: string | null;
  services: string[];
  conditions: string[];
  age_groups: string[];
  average_rating: number | null;
  review_count: number | null;
}

const PROVIDER_SELECT = `
  p.id, p.name, p.category_id, p.specialty, p.specialty_id, p.facility_id,
  f.name AS facility_name,
  COALESCE(f.address_line1, '') AS address,
  COALESCE(p.phone, f.phone) AS phone,
  f.latitude, f.longitude,
  p.image_path, p.hero_image_path,
  p.is_verified, p.is_accepting_bookings, p.mdpcz_number, p.about,
  p.services, p.conditions, p.age_groups,
  COALESCE(pr.avg_rating, 0)::float AS average_rating,
  COALESCE(pr.review_count, 0)::int AS review_count
`;

const PROVIDER_JOINS = `
  FROM public.providers p
  JOIN public.facilities f ON f.id = p.facility_id
  LEFT JOIN (
    SELECT provider_id,
           AVG(rating)::numeric(3,2) AS avg_rating,
           COUNT(*)::int AS review_count
    FROM public.provider_reviews
    WHERE deleted_at IS NULL
    GROUP BY provider_id
  ) pr ON pr.provider_id = p.id
`;

function mapProvider(row: ProviderRow, includeDistance = false) {
  return {
    id: row.id,
    name: row.name,
    categoryId: row.category_id,
    specialty: row.specialty,
    specialtyId: row.specialty_id,
    facilityId: row.facility_id,
    facilityName: row.facility_name,
    address: row.address,
    phone: row.phone,
    latitude: row.latitude,
    longitude: row.longitude,
    ...(includeDistance && row.distance_km != null ? { distanceKm: Number(row.distance_km) } : {}),
    imageUrl: row.image_path,
    heroImageUrl: row.hero_image_path,
    isVerified: row.is_verified,
    isAcceptingBookings: row.is_accepting_bookings,
    mdpczNumber: row.mdpcz_number,
    about: row.about,
    services: row.services ?? [],
    conditions: row.conditions ?? [],
    ageGroups: row.age_groups ?? [],
    averageRating: row.average_rating != null ? Number(row.average_rating) : null,
    reviewCount: row.review_count ?? 0,
  };
}

export async function listProviders(options: {
  page: number;
  limit: number;
  sortBy?: string;
  categoryId?: string;
  specialtyId?: string;
  isVerified?: boolean;
  province?: string;
  city?: string;
}) {
  const conditions = ['p.is_active = true', 'f.is_active = true'];
  const params: unknown[] = [];
  let idx = 1;

  if (options.categoryId) {
    conditions.push(`p.category_id = $${idx++}`);
    params.push(options.categoryId);
  }
  if (options.specialtyId) {
    conditions.push(`p.specialty_id = $${idx++}`);
    params.push(options.specialtyId);
  }
  if (options.isVerified !== undefined) {
    conditions.push(`p.is_verified = $${idx++}`);
    params.push(options.isVerified);
  }
  if (options.province) {
    conditions.push(`f.province = $${idx++}::public.zimbabwe_province`);
    params.push(options.province);
  }
  if (options.city) {
    conditions.push(`f.city ILIKE $${idx++}`);
    params.push(`%${options.city}%`);
  }

  const where = conditions.join(' AND ');
  const sort = parseSort(options.sortBy, { name: 'p.name', rating: 'average_rating', createdAt: 'p.created_at' }, 'name');

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count ${PROVIDER_JOINS} WHERE ${where}`,
    params,
  );
  const total = Number(countResult.rows[0]?.count ?? 0);
  const offset = paginationOffset(options.page, options.limit);

  const result = await query<ProviderRow>(
    `SELECT ${PROVIDER_SELECT}, NULL::float AS distance_km
     ${PROVIDER_JOINS}
     WHERE ${where}
     ORDER BY ${sort.column} ${sort.order}
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, options.limit, offset],
  );

  return {
    providers: result.rows.map((r) => mapProvider(r)),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}

export async function getProviderById(id: string) {
  const result = await query<ProviderRow>(
    `SELECT ${PROVIDER_SELECT}, NULL::float AS distance_km
     ${PROVIDER_JOINS}
     WHERE p.id = $1 AND p.is_active = true`,
    [id],
  );

  if (!result.rows[0]) throw new NotFoundError('Provider', id);
  return mapProvider(result.rows[0]);
}

export async function searchProviders(options: {
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
}) {
  const { searchProvidersRanked } = await import('./search.service.js');
  return searchProvidersRanked(options);
}

export async function nearbyProviders(options: {
  lat: number;
  lon: number;
  radiusKm: number;
  page: number;
  limit: number;
}) {
  return searchProviders({
    ...options,
    lat: options.lat,
    lon: options.lon,
    radiusKm: options.radiusKm,
  });
}

export async function topRatedProviders(options: { page: number; limit: number; minReviews?: number }) {
  const minReviews = options.minReviews ?? 1;
  const offset = paginationOffset(options.page, options.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM public.providers p
     JOIN (
       SELECT provider_id, COUNT(*) AS review_count, AVG(rating) AS avg_rating
       FROM public.provider_reviews
       WHERE deleted_at IS NULL
       GROUP BY provider_id
       HAVING COUNT(*) >= $1
     ) pr ON pr.provider_id = p.id
     WHERE p.is_active = true`,
    [minReviews],
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const result = await query<ProviderRow>(
    `SELECT ${PROVIDER_SELECT}, NULL::float AS distance_km
     ${PROVIDER_JOINS}
     JOIN (
       SELECT provider_id
       FROM public.provider_reviews
       WHERE deleted_at IS NULL
       GROUP BY provider_id
       HAVING COUNT(*) >= $1
     ) tr ON tr.provider_id = p.id
     WHERE p.is_active = true
     ORDER BY average_rating DESC NULLS LAST, review_count DESC
     LIMIT $2 OFFSET $3`,
    [minReviews, options.limit, offset],
  );

  return {
    providers: result.rows.map((r) => mapProvider(r)),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}
