import { query } from '../lib/db.js';
import {
  buildFacilityLogoUrl,
  buildMedicalAidLogoUrl,
  buildProviderImageUrl,
} from '../lib/facility-assets.js';
import {
  parseProfileSettings,
  type FacilityProfileSettings,
} from '../lib/facility-profile-settings.js';
import { effectiveFacilityTypes } from '../lib/facility-types.js';
import { NotFoundError } from '../lib/errors.js';
import { getNextAvailableSlot, facilityHasBookableSlots } from './availability.service.js';

const HARARE_TZ = 'Africa/Harare';

type OpenStatus = 'open' | 'closed' | 'closes_soon' | 'open_24h';

interface HourRow {
  day_of_week: number;
  opens_at: string | null;
  closes_at: string | null;
  is_closed: boolean;
  is_24_hours: boolean;
}

function harareNow(): Date {
  return new Date(new Date().toLocaleString('en-US', { timeZone: HARARE_TZ }));
}

function parseTime(value: string): number {
  const [h, m] = value.split(':').map(Number);
  return h * 60 + (m ?? 0);
}

function computeOpenStatus(hours: HourRow[]): OpenStatus {
  if (hours.some((h) => h.is_24_hours)) return 'open_24h';

  const now = harareNow();
  const dow = now.getDay();
  const row = hours.find((h) => h.day_of_week === dow);
  if (!row || row.is_closed || !row.opens_at || !row.closes_at) return 'closed';

  const nowMin = now.getHours() * 60 + now.getMinutes();
  const open = parseTime(row.opens_at.slice(0, 5));
  const close = parseTime(row.closes_at.slice(0, 5));

  if (nowMin < open || nowMin >= close) return 'closed';
  if (close - nowMin <= 60) return 'closes_soon';
  return 'open';
}

function mapOperatingHours(hours: HourRow[]) {
  const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  return hours
    .sort((a, b) => a.day_of_week - b.day_of_week)
    .map((h) => {
      const day = dayNames[h.day_of_week] ?? `Day ${h.day_of_week}`;
      if (h.is_24_hours) {
        return { dayOfWeek: h.day_of_week, label: day, opensAt: null, closesAt: null, isClosed: false, is24Hours: true };
      }
      if (h.is_closed) {
        return { dayOfWeek: h.day_of_week, label: day, opensAt: null, closesAt: null, isClosed: true, is24Hours: false };
      }
      return {
        dayOfWeek: h.day_of_week,
        label: day,
        opensAt: h.opens_at?.slice(0, 5) ?? null,
        closesAt: h.closes_at?.slice(0, 5) ?? null,
        isClosed: false,
        is24Hours: false,
      };
    });
}

function buildFacilityInfo(profile: FacilityProfileSettings) {
  const emergencyAvailable =
    profile.emergency.department ||
    profile.emergency.ambulance ||
    profile.emergency.trauma ||
    profile.emergency.icu ||
    profile.emergency.is24Hour;

  return {
    emergencyAvailable: emergencyAvailable ? true : null,
    wheelchairAccessible: profile.accessibility.wheelchair ? true : null,
    parkingAvailable: profile.accessibility.parking ? true : null,
  };
}

async function loadFacilityRow(facilityId: string) {
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
    whatsapp_phone: string | null;
    email: string | null;
    website: string | null;
    latitude: string | null;
    longitude: string | null;
    logo_path: string | null;
    is_verified: boolean;
    settings: unknown;
    is_open_now: boolean;
  }>(
    `SELECT f.id, f.name, f.slug, f.facility_type, f.facility_types, f.description,
            f.address_line1, f.city, f.province::text AS province,
            f.phone, f.whatsapp_phone, f.email, f.website,
            f.latitude, f.longitude, f.logo_path, f.is_verified, f.settings,
            public.is_facility_open_now(f.id) AS is_open_now
     FROM public.facilities f
     WHERE f.id = $1 AND f.deleted_at IS NULL AND f.is_active = true`,
    [facilityId],
  );

  if (!result.rows[0]) throw new NotFoundError('Facility', facilityId);
  return result.rows[0];
}

export async function getPublicProfile(facilityId: string, distanceKm?: number) {
  const row = await loadFacilityRow(facilityId);
  const profile = parseProfileSettings((row.settings as { profile?: unknown })?.profile);

  const hoursResult = await query<HourRow>(
    `SELECT day_of_week, opens_at::text, closes_at::text, is_closed, is_24_hours
     FROM public.facility_operating_hours WHERE facility_id = $1 ORDER BY day_of_week`,
    [facilityId],
  );

  const facilityTypes = effectiveFacilityTypes({
    facility_type: row.facility_type,
    facility_types: row.facility_types,
  });

  const openStatus = computeOpenStatus(hoursResult.rows);
  // Opt-out model (matches facility portal): booking is on unless explicitly disabled,
  // and onlineBooking must be enabled in SmartHealth features.
  const bookingRequested =
    profile.booking.enabled !== false &&
    profile.smarthealthFeatures.onlineBooking === true;
  const hasAvailableSlots = bookingRequested
    ? await facilityHasBookableSlots(facilityId)
    : false;
  const bookingEnabled = bookingRequested && hasAvailableSlots;

  return {
    facility: {
      id: row.id,
      name: row.name,
      slug: row.slug,
      facilityType: row.facility_type,
      facilityTypes,
      description: row.description,
      addressLine1: row.address_line1,
      city: row.city,
      province: row.province,
      phone: row.phone,
      whatsappPhone: row.whatsapp_phone,
      website: row.website,
      latitude: row.latitude != null ? Number(row.latitude) : null,
      longitude: row.longitude != null ? Number(row.longitude) : null,
      distanceKm: distanceKm ?? null,
      isVerified: row.is_verified,
    },
    logoUrl: buildFacilityLogoUrl(row.logo_path),
    openStatus,
    isOpenNow: row.is_open_now,
    operatingHours: hoursResult.rows.length > 0 ? mapOperatingHours(hoursResult.rows) : [],
    services: profile.services,
    medicalAids: profile.medicalAids.map((m) => ({
      schemeKey: m.schemeKey,
      name: m.name,
      logoUrl: buildMedicalAidLogoUrl(m.logoPath),
    })),
    accessibility: profile.accessibility,
    emergency: profile.emergency,
    facilityInfo: buildFacilityInfo(profile),
    smarthealthFeatures: {
      verified: row.is_verified,
      ...profile.smarthealthFeatures,
    },
    booking: {
      enabled: bookingEnabled,
      showSlots: profile.booking.showSlots !== false && bookingEnabled,
      slotDurationMinutes: profile.booking.slotDurationMinutes ?? 30,
      maxAdvanceDays: profile.booking.maxAdvanceDays ?? 30,
      cancellationPolicy: profile.booking.cancellationPolicy ?? null,
    },
  };
}

export async function getPublicSpecialists(
  facilityId: string,
  opts: { limit?: number; serviceId?: string },
) {
  await loadFacilityRow(facilityId);

  const limit = Math.min(Math.max(opts.limit ?? 5, 1), 20);
  const params: unknown[] = [facilityId];
  let serviceClause = '';

  if (opts.serviceId) {
    params.push(opts.serviceId);
    serviceClause = ` AND EXISTS (
      SELECT 1 FROM public.facility_service_providers fsp
      WHERE fsp.facility_id = $1
        AND fsp.provider_id = p.id
        AND fsp.service_id = $${params.length}
        AND fsp.is_active = true
    )`;
  }

  const rows = await query<{
    id: string;
    name: string;
    specialty: string | null;
    image_path: string | null;
  }>(
    `SELECT DISTINCT p.id, p.name, p.specialty, p.image_path
     FROM public.providers p
     LEFT JOIN public.provider_facility_links pfl
       ON pfl.provider_id = p.id AND pfl.facility_id = $1
     WHERE (p.facility_id = $1 OR pfl.facility_id = $1)
       AND p.is_active = true
       AND p.deleted_at IS NULL
       AND COALESCE(pfl.is_active, p.is_active) = true
       ${serviceClause}
     ORDER BY p.name ASC
     LIMIT $${params.length + 1}`,
    [...params, limit],
  );

  const specialists = await Promise.all(
    rows.rows.map(async (r) => {
      const nextSlot = await getNextAvailableSlot(facilityId, r.id, opts.serviceId);
      return {
        id: r.id,
        name: r.name,
        specialty: r.specialty,
        photoUrl: buildProviderImageUrl(r.image_path),
        nextAvailableAt: nextSlot,
      };
    }),
  );

  return { specialists };
}
