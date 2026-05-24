import { query } from '../lib/db.js';
import { buildPaginationMeta, paginationOffset } from '../lib/pagination.js';
import { normalizeSearchQuery } from '../lib/search-query.js';
import { searchEmergencyNearby } from './search.service.js';

interface EmergencyRow {
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
  distance_km: number | null;
  is_24_hours: boolean;
}

function mapEmergency(row: EmergencyRow, includeDistance = false) {
  return {
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
    ...(includeDistance && row.distance_km != null ? { distanceKm: Number(row.distance_km) } : {}),
    is24Hours: row.is_24_hours,
  };
}

export async function listEmergencyServices(options: {
  page: number;
  limit: number;
  q?: string;
  serviceType?: string;
  province?: string;
  city?: string;
}) {
  const conditions = ['deleted_at IS NULL', 'is_active = true'];
  const params: unknown[] = [];
  let idx = 1;

  const q = normalizeSearchQuery(options.q);
  if (q) {
    conditions.push(`(
      search_vector @@ websearch_to_tsquery('english', $${idx})
      OR name ILIKE $${idx + 1}
      OR similarity(name, $${idx}) > 0.25
    )`);
    params.push(q, `%${q}%`);
    idx += 2;
  }
  if (options.serviceType) {
    conditions.push(`service_type = $${idx++}::public.emergency_service_type`);
    params.push(options.serviceType);
  }
  if (options.province) {
    conditions.push(`province = $${idx++}::public.zimbabwe_province`);
    params.push(options.province);
  }
  if (options.city) {
    conditions.push(`city ILIKE $${idx++}`);
    params.push(`%${options.city}%`);
  }

  const where = conditions.join(' AND ');
  const offset = paginationOffset(options.page, options.limit);

  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.emergency_services WHERE ${where}`,
    params,
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const orderBy = q
    ? `GREATEST(
         ts_rank_cd(search_vector, websearch_to_tsquery('english', $1)),
         similarity(name, $1)
       ) DESC, name ASC`
    : 'name ASC';

  const result = await query<EmergencyRow>(
    `SELECT id, name, service_type, phone, alternate_phone, address, city, province,
            latitude, longitude, is_24_hours, NULL::float AS distance_km
     FROM public.emergency_services
     WHERE ${where}
     ORDER BY ${orderBy}
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, options.limit, offset],
  );

  return {
    services: result.rows.map((r) => mapEmergency(r)),
    pagination: buildPaginationMeta(options.page, options.limit, total),
  };
}

export async function nearestEmergencyServices(options: {
  lat: number;
  lon: number;
  radiusKm: number;
  page: number;
  limit: number;
  serviceType?: string;
  q?: string;
  openNow?: boolean;
}) {
  return searchEmergencyNearby({
    lat: options.lat,
    lon: options.lon,
    radiusKm: options.radiusKm,
    page: options.page,
    limit: options.limit,
    serviceType: options.serviceType,
    q: options.q,
    openNow: options.openNow,
  });
}
