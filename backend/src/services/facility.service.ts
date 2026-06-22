import { env } from '../config.js';
import { query, withTransaction } from '../lib/db.js';
import {
  assertCanManageProvider,
  assertFacilityAccess,
  getFacilityOrThrow,
  getUserFacilityMemberships,
  requireFacilityAdmin,
} from '../lib/facility-access.js';
import { AppError, ConflictError, NotFoundError, ValidationError } from '../lib/errors.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { adminOffset, buildSearchClause, type AdminListQuery } from '../lib/admin-query.js';
import { normalizeEmail, normalizeZimbabwePhone, ensureAuthUserEmail } from '../lib/supabase-auth.js';
import { sendEmail } from '../lib/email.js';
import { logAppointmentAudit, logPermissionAudit } from '../lib/audit-log.js';
import {
  applyManualFacilityCoordinates,
  geocodeFacilityRecord,
} from '../lib/facility-geocode.js';
import {
  buildFacilityLogoUrl,
  deleteStorageObject,
  uploadFacilityLogo,
} from '../lib/facility-assets.js';
import * as medicalAidSchemes from './medical-aid-schemes.service.js';
import {
  mergeProfileSettings,
  parseProfileSettings,
  type FacilityProfileSettings,
} from '../lib/facility-profile-settings.js';
import {
  effectiveFacilityTypes,
  normalizeFacilityTypes,
} from '../lib/facility-types.js';
import { normalizeFacilityClassification } from '../lib/facility-classification.js';
import { logMedicalAccess } from '../lib/medical-access-log.js';
import type { RequestContext } from '../lib/request-context.js';
import { assertCanAddStaffByEmail } from './practitioner-claim.service.js';

function mapFacility(row: Record<string, unknown>) {
  const facilityTypes = effectiveFacilityTypes({
    facility_type: String(row.facility_type),
    facility_types: row.facility_types as string[] | null,
  });
  return {
    id: row.id,
    name: row.name,
    slug: row.slug,
    facilityType: row.facility_type,
    facilityTypes,
    facilityCategory: row.facility_category != null ? String(row.facility_category) : null,
    description: row.description,
    addressLine1: row.address_line1,
    addressLine2: row.address_line2,
    city: row.city,
    province: row.province,
    postalCode: row.postal_code,
    phone: row.phone,
    whatsappPhone: row.whatsapp_phone ?? null,
    email: row.email,
    website: row.website,
    logoUrl: buildFacilityLogoUrl(row.logo_path as string | null),
    latitude: row.latitude != null ? Number(row.latitude) : null,
    longitude: row.longitude != null ? Number(row.longitude) : null,
    geocodeQuality: row.geocode_quality != null ? String(row.geocode_quality) : null,
    isVerified: row.is_verified,
    isActive: row.is_active,
    settings: row.settings,
    createdAt: (row.created_at as Date).toISOString(),
    updatedAt: (row.updated_at as Date).toISOString(),
  };
}

export async function getPortalProfile(userId: string) {
  const profile = await query<{
    id: string;
    primary_role: string;
    first_name: string | null;
    last_name: string | null;
    email: string | null;
    phone: string | null;
  }>(
    `SELECT id, primary_role, first_name, last_name, email, phone
     FROM public.profiles WHERE id = $1`,
    [userId],
  );
  if (!profile.rows[0]) throw new NotFoundError('Profile', userId);

  const facilities = await getUserFacilityMemberships(userId);
  const role = profile.rows[0].primary_role;

  if (facilities.length === 0 && role === 'super_admin') {
    const allFacilities = await query<{ id: string; name: string }>(
      `SELECT id, name FROM public.facilities
       WHERE deleted_at IS NULL AND is_active = true
       ORDER BY name ASC`,
    );
    if (allFacilities.rows.length === 0) {
      throw new AppError(403, 'NO_FACILITY_ACCESS', 'No active facilities found on the platform');
    }
    return {
      id: profile.rows[0].id,
      role,
      firstName: profile.rows[0].first_name,
      lastName: profile.rows[0].last_name,
      email: profile.rows[0].email,
      phone: profile.rows[0].phone,
      facilities: allFacilities.rows.map((f) => ({
        id: f.id,
        name: f.name,
        role: 'facility_admin',
        membershipId: f.id,
      })),
    };
  }

  if (facilities.length === 0) {
    const ownedProvider = await query<{
      id: string;
      name: string;
      specialty: string | null;
      registration_number: string | null;
    }>(
      `SELECT id, name, specialty, registration_number FROM public.providers
       WHERE owner_id = $1 AND is_claimed = true AND deleted_at IS NULL
       LIMIT 1`,
      [userId],
    );

    if (ownedProvider.rows[0]) {
      const { getMyPrimaryFacilities } = await import('./practitioner-claim.service.js');
      const linked = await getMyPrimaryFacilities(userId);
      return {
        id: profile.rows[0].id,
        role: profile.rows[0].primary_role,
        firstName: profile.rows[0].first_name,
        lastName: profile.rows[0].last_name,
        email: profile.rows[0].email,
        phone: profile.rows[0].phone,
        facilities: [],
        linkedFacilities: linked.facilities,
        provider: {
          id: ownedProvider.rows[0].id,
          name: ownedProvider.rows[0].name,
          specialty: ownedProvider.rows[0].specialty,
          registrationNumber: ownedProvider.rows[0].registration_number,
        },
        portalMode: 'provider' as const,
      };
    }

    throw new AppError(403, 'NO_FACILITY_ACCESS', 'No facility membership found for this account');
  }

  const ownedProvider = await query<{
    id: string;
    name: string;
    specialty: string | null;
    registration_number: string | null;
  }>(
    `SELECT id, name, specialty, registration_number FROM public.providers
     WHERE owner_id = $1 AND is_claimed = true AND deleted_at IS NULL
     LIMIT 1`,
    [userId],
  );

  let linkedFacilities: Awaited<
    ReturnType<typeof import('./practitioner-claim.service.js').getMyPrimaryFacilities>
  >['facilities'] = [];
  let provider: {
    id: string;
    name: string;
    specialty: string | null;
    registrationNumber: string | null;
  } | undefined;

  if (ownedProvider.rows[0]) {
    const { getMyPrimaryFacilities } = await import('./practitioner-claim.service.js');
    linkedFacilities = (await getMyPrimaryFacilities(userId)).facilities;
    provider = {
      id: ownedProvider.rows[0].id,
      name: ownedProvider.rows[0].name,
      specialty: ownedProvider.rows[0].specialty,
      registrationNumber: ownedProvider.rows[0].registration_number,
    };
  }

  return {
    id: profile.rows[0].id,
    role: profile.rows[0].primary_role,
    firstName: profile.rows[0].first_name,
    lastName: profile.rows[0].last_name,
    email: profile.rows[0].email,
    phone: profile.rows[0].phone,
    facilities: facilities.map((f) => ({
      id: f.facility_id,
      name: f.name,
      role: f.role,
      membershipId: f.membership_id,
    })),
    linkedFacilities,
    provider,
    portalMode: 'facility' as const,
  };
}

export async function getDashboard(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);

  const [appointments, walkIns, doctors, revenue, inventory] = await Promise.all([
    query<{ today: string; pending: string; cancelled_today: string }>(
      `SELECT
         COUNT(*) FILTER (WHERE scheduled_at >= date_trunc('day', now())
           AND scheduled_at < date_trunc('day', now()) + interval '1 day')::text AS today,
         COUNT(*) FILTER (WHERE status IN ('pending', 'confirmed'))::text AS pending,
         COUNT(*) FILTER (WHERE status = 'cancelled'
           AND updated_at >= date_trunc('day', now()))::text AS cancelled_today
       FROM public.appointments
       WHERE tenant_id = $1 AND deleted_at IS NULL`,
      [facilityId],
    ),
    query<{ waiting: string; avg_wait: string | null; walk_ins_today: string }>(
      `SELECT
         COUNT(*) FILTER (WHERE queue_status = 'waiting')::text AS waiting,
         AVG(estimated_wait_minutes) FILTER (WHERE queue_status = 'waiting')::text AS avg_wait,
         COUNT(*)::text AS walk_ins_today
       FROM public.walk_in_sessions
       WHERE tenant_id = $1 AND deleted_at IS NULL
         AND registered_at >= date_trunc('day', now())`,
      [facilityId],
    ),
    query<{ total: string; active: string }>(
      `SELECT COUNT(*)::text AS total,
              COUNT(*) FILTER (WHERE is_accepting_bookings)::text AS active
       FROM public.providers WHERE facility_id = $1 AND is_active = true`,
      [facilityId],
    ),
    query<{ total: string }>(
      `SELECT COALESCE(SUM(net_revenue_cents), 0)::text AS total
       FROM public.revenue_reports
       WHERE tenant_id = $1 AND report_date >= date_trunc('month', now())::date`,
      [facilityId],
    ),
    query<{ low_stock: string }>(
      `SELECT COUNT(*)::text AS low_stock
       FROM public.products
       WHERE tenant_id = $1 AND deleted_at IS NULL AND is_active = true
         AND current_stock <= reorder_level`,
      [facilityId],
    ),
  ]);

  return {
    appointmentsToday: Number(appointments.rows[0]?.today ?? 0),
    pendingAppointments: Number(appointments.rows[0]?.pending ?? 0),
    cancellationsToday: Number(appointments.rows[0]?.cancelled_today ?? 0),
    queueWaiting: Number(walkIns.rows[0]?.waiting ?? 0),
    walkInsToday: Number(walkIns.rows[0]?.walk_ins_today ?? 0),
    avgWaitMinutes: walkIns.rows[0]?.avg_wait ? Math.round(Number(walkIns.rows[0].avg_wait)) : null,
    doctorsTotal: Number(doctors.rows[0]?.total ?? 0),
    doctorsAcceptingBookings: Number(doctors.rows[0]?.active ?? 0),
    revenueMonthCents: Number(revenue.rows[0]?.total ?? 0),
    lowStockItems: Number(inventory.rows[0]?.low_stock ?? 0),
    updatedAt: new Date().toISOString(),
  };
}

export async function getFacilityProfile(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const row = await getFacilityOrThrow(facilityId);
  const settings = (row.settings ?? {}) as { profile?: unknown };
  return {
    facility: mapFacility(row),
    profileSettings: parseProfileSettings(settings.profile),
  };
}

export async function getMedicalAidCatalog() {
  return medicalAidSchemes.listMedicalAidSchemesCatalog();
}

export async function updateFacilityProfileSettings(
  user: AuthenticatedUser,
  facilityId: string,
  patch: Partial<FacilityProfileSettings>,
) {
  await requireFacilityAdmin(user, facilityId);
  const existing = await query<{ settings: unknown }>(
    `SELECT settings FROM public.facilities WHERE id = $1`,
    [facilityId],
  );
  if (!existing.rows[0]) throw new NotFoundError('Facility', facilityId);

  const currentSettings = (existing.rows[0].settings ?? {}) as Record<string, unknown>;
  const currentProfile = parseProfileSettings(currentSettings.profile);
  const merged = mergeProfileSettings(currentProfile, patch);
  const nextSettings = { ...currentSettings, profile: merged };

  await query(
    `UPDATE public.facilities SET settings = $2::jsonb, updated_at = now() WHERE id = $1`,
    [facilityId, JSON.stringify(nextSettings)],
  );

  return { profileSettings: merged };
}

export async function uploadFacilityLogoFile(
  user: AuthenticatedUser,
  facilityId: string,
  buffer: Buffer,
  mimeType: string,
) {
  await requireFacilityAdmin(user, facilityId);
  const existing = await query<{ logo_path: string | null }>(
    `SELECT logo_path FROM public.facilities WHERE id = $1`,
    [facilityId],
  );
  if (!existing.rows[0]) throw new NotFoundError('Facility', facilityId);

  const logoPath = await uploadFacilityLogo(facilityId, buffer, mimeType);
  await query(`UPDATE public.facilities SET logo_path = $2, updated_at = now() WHERE id = $1`, [
    facilityId,
    logoPath,
  ]);

  if (existing.rows[0].logo_path) {
    await deleteStorageObject('facility-assets', existing.rows[0].logo_path);
  }

  return { logoPath, logoUrl: buildFacilityLogoUrl(logoPath) };
}

export async function removeFacilityLogo(user: AuthenticatedUser, facilityId: string) {
  await requireFacilityAdmin(user, facilityId);
  const existing = await query<{ logo_path: string | null }>(
    `SELECT logo_path FROM public.facilities WHERE id = $1`,
    [facilityId],
  );
  if (!existing.rows[0]) throw new NotFoundError('Facility', facilityId);

  await query(
    `UPDATE public.facilities SET logo_path = NULL, updated_at = now() WHERE id = $1`,
    [facilityId],
  );

  if (existing.rows[0].logo_path) {
    await deleteStorageObject('facility-assets', existing.rows[0].logo_path);
  }

  return { message: 'Logo removed' };
}

export async function getDoctorServiceIds(
  user: AuthenticatedUser,
  facilityId: string,
  doctorId: string,
) {
  await assertFacilityAccess(user, facilityId);
  const rows = await query<{ service_id: string }>(
    `SELECT service_id FROM public.facility_service_providers
     WHERE facility_id = $1 AND provider_id = $2 AND is_active = true
     ORDER BY display_order ASC`,
    [facilityId, doctorId],
  );
  return { serviceIds: rows.rows.map((r) => r.service_id) };
}

export async function updateDoctorServiceIds(
  user: AuthenticatedUser,
  facilityId: string,
  doctorId: string,
  serviceIds: string[],
) {
  await assertCanManageProvider(user, facilityId, doctorId);

  const assoc = await query<{ id: string }>(
    `SELECT p.id
     FROM public.providers p
     LEFT JOIN public.provider_facility_links pfl
       ON pfl.provider_id = p.id AND pfl.facility_id = $1
     WHERE p.id = $2 AND (p.facility_id = $1 OR pfl.facility_id = $1)
       AND p.deleted_at IS NULL
     LIMIT 1`,
    [facilityId, doctorId],
  );
  if (!assoc.rows[0]) throw new NotFoundError('Doctor', doctorId);

  await withTransaction(async (client) => {
    await client.query(
      `DELETE FROM public.facility_service_providers
       WHERE facility_id = $1 AND provider_id = $2`,
      [facilityId, doctorId],
    );

    for (let i = 0; i < serviceIds.length; i++) {
      await client.query(
        `INSERT INTO public.facility_service_providers (
           facility_id, service_id, provider_id, display_order, is_active
         ) VALUES ($1, $2, $3, $4, true)`,
        [facilityId, serviceIds[i], doctorId, i],
      );
    }
  });

  return { serviceIds };
}

export async function updateFacilityProfile(
  user: AuthenticatedUser,
  facilityId: string,
  data: {
    name?: string;
    description?: string;
    addressLine1?: string;
    addressLine2?: string;
    city?: string;
    phone?: string;
    whatsappPhone?: string;
    email?: string;
    website?: string;
    facilityTypes?: string[];
    facilityCategory?: string | null;
    latitude?: number;
    longitude?: number;
    locationMode?: 'manual' | 'geocode';
  },
) {
  await requireFacilityAdmin(user, facilityId);

  const normalizedTypes =
    data.facilityTypes !== undefined ? normalizeFacilityTypes(data.facilityTypes) : null;

  const normalizedCategory =
    data.facilityCategory !== undefined
      ? data.facilityCategory === null
        ? null
        : normalizeFacilityClassification(data.facilityCategory)
      : undefined;

  const hasManualCoords =
    data.locationMode === 'manual' &&
    data.latitude !== undefined &&
    data.longitude !== undefined;

  const existing = await query<{
    address_line1: string | null;
    city: string | null;
    province: string | null;
    name: string;
  }>(
    `SELECT address_line1, city, province::text AS province, name
     FROM public.facilities WHERE id = $1`,
    [facilityId],
  );
  const prior = existing.rows[0];
  if (!prior) throw new NotFoundError('Facility', facilityId);

  const addressChanged =
    (data.addressLine1 !== undefined && data.addressLine1 !== prior.address_line1) ||
    (data.city !== undefined && data.city !== prior.city);

  const shouldAutoGeocode =
    addressChanged && !hasManualCoords && data.locationMode !== 'manual';

  const result = await query(
    `UPDATE public.facilities SET
       name = COALESCE($2, name),
       description = COALESCE($3, description),
       address_line1 = COALESCE($4, address_line1),
       address_line2 = COALESCE($5, address_line2),
       city = COALESCE($6, city),
       phone = COALESCE($7, phone),
       whatsapp_phone = COALESCE($8, whatsapp_phone),
       email = COALESCE($9, email),
       website = COALESCE($10, website),
       facility_type = COALESCE($11, facility_type),
       facility_types = COALESCE($12, facility_types),
       facility_category = CASE WHEN $13::text IS NOT NULL THEN $13 ELSE facility_category END,
       updated_at = now()
     WHERE id = $1
     RETURNING *`,
    [
      facilityId,
      data.name ?? null,
      data.description ?? null,
      data.addressLine1 ?? null,
      data.addressLine2 ?? null,
      data.city ?? null,
      data.phone ?? null,
      data.whatsappPhone ?? null,
      data.email ?? null,
      data.website ?? null,
      normalizedTypes ? normalizedTypes[0] : null,
      normalizedTypes ? normalizedTypes : null,
      normalizedCategory !== undefined ? normalizedCategory : null,
    ],
  );

  const row = result.rows[0];

  if (hasManualCoords) {
    await applyManualFacilityCoordinates(facilityId, data.latitude!, data.longitude!);
  } else if (shouldAutoGeocode) {
    await geocodeFacilityRecord({
      facilityId,
      name: String(row.name ?? prior.name),
      addressLine1: row.address_line1 ? String(row.address_line1) : null,
      city: row.city ? String(row.city) : null,
      province: row.province ? String(row.province) : prior.province,
      clearOnFailure: true,
    });
  }

  const refreshed = await getFacilityOrThrow(facilityId);
  return { facility: mapFacility(refreshed) };
}

// --- Doctors ---

export async function listDoctors(user: AuthenticatedUser, facilityId: string, opts: AdminListQuery) {
  await assertFacilityAccess(user, facilityId);
  // A provider belongs to this facility's roster if it is either homed here
  // (providers.facility_id) or affiliated via provider_facility_links. The
  // per-facility is_active / is_accepting_bookings flags come from the link
  // (falling back to the provider-level defaults for manually-added doctors).
  const params: unknown[] = [facilityId];
  let idx = 2;
  const conditions = ['(p.facility_id = $1 OR pfl.facility_id = $1)', 'p.is_active = true'];

  const search = buildSearchClause(['p.name', 'p.specialty', 'p.mdpcz_number'], opts.q, params, idx);
  idx = search.nextIdx;
  conditions.push(search.clause);

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(DISTINCT p.id)::text AS count
     FROM public.providers p
     LEFT JOIN public.provider_facility_links pfl
       ON pfl.provider_id = p.id AND pfl.facility_id = $1
     WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT p.id, p.name, p.specialty, p.mdpcz_number, p.phone, p.email,
            p.is_verified, p.created_at,
            COALESCE(pfl.is_accepting_bookings, p.is_accepting_bookings) AS is_accepting_bookings,
            COALESCE(pfl.is_active, p.is_active) AS facility_is_active,
            COALESCE(AVG(r.rating), 0) AS avg_rating,
            COUNT(r.id)::int AS review_count
     FROM public.providers p
     LEFT JOIN public.provider_facility_links pfl
       ON pfl.provider_id = p.id AND pfl.facility_id = $1
     LEFT JOIN public.provider_reviews r ON r.provider_id = p.id
     WHERE ${where}
     GROUP BY p.id, pfl.is_accepting_bookings, pfl.is_active
     ORDER BY p.name ASC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    doctors: await Promise.all(
      rows.rows.map(async (r) => {
        const services = await query<{ service_id: string }>(
          `SELECT service_id FROM public.facility_service_providers
           WHERE facility_id = $1 AND provider_id = $2 AND is_active = true`,
          [facilityId, r.id],
        );
        return {
          id: r.id,
          name: r.name,
          specialty: r.specialty,
          mdpczNumber: r.mdpcz_number,
          phone: r.phone,
          email: r.email,
          isVerified: r.is_verified,
          isActive: r.facility_is_active,
          isAcceptingBookings: r.is_accepting_bookings,
          serviceIds: services.rows.map((s) => s.service_id),
          avgRating: Number(r.avg_rating),
          reviewCount: r.review_count,
          createdAt: (r.created_at as Date).toISOString(),
        };
      }),
    ),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

function normalizeRegistrationNumber(value: string): string {
  return value.trim().toUpperCase().replace(/\s+/g, '');
}

/**
 * Look up a provider already in the registry (e.g. MDPCZ) by registration /
 * MDPCZ number so a facility admin can attach the existing record instead of
 * creating a duplicate.
 */
export async function lookupRegisteredProvider(
  user: AuthenticatedUser,
  facilityId: string,
  mdpczNumber: string,
) {
  await requireFacilityAdmin(user, facilityId);
  const reg = normalizeRegistrationNumber(mdpczNumber);
  if (!reg) return { found: false as const };

  const result = await query<{
    id: string;
    name: string;
    specialty: string | null;
    registration_number: string | null;
    mdpcz_number: string | null;
    phone: string | null;
    email: string | null;
    is_active: boolean;
    facility_id: string | null;
  }>(
    `SELECT id, name, specialty, registration_number, mdpcz_number, phone, email, is_active, facility_id
     FROM public.providers
     WHERE (UPPER(REPLACE(registration_number, ' ', '')) = $1
            OR UPPER(REPLACE(mdpcz_number, ' ', '')) = $1)
       AND deleted_at IS NULL
     ORDER BY is_active DESC, created_at ASC
     LIMIT 1`,
    [reg],
  );

  const p = result.rows[0];
  if (!p) return { found: false as const };

  const link = await query<{ exists: boolean }>(
    `SELECT EXISTS(
       SELECT 1 FROM public.provider_facility_links WHERE provider_id = $1 AND facility_id = $2
     ) AS exists`,
    [p.id, facilityId],
  );
  const alreadyAtFacility = p.facility_id === facilityId || Boolean(link.rows[0]?.exists);

  return {
    found: true as const,
    provider: {
      id: p.id,
      name: p.name,
      specialty: p.specialty,
      mdpczNumber: p.mdpcz_number ?? p.registration_number,
      phone: p.phone,
      email: p.email,
      isActive: p.is_active,
      alreadyAtFacility,
    },
  };
}

/**
 * Attach an existing registry provider to this facility: assign the facility as
 * its operational home (so it appears in the roster, hours, availability, etc.)
 * and record an `affiliated` registry link. Never creates a duplicate.
 */
export async function attachDoctor(
  user: AuthenticatedUser,
  facilityId: string,
  providerId: string,
) {
  await requireFacilityAdmin(user, facilityId);

  const existing = await query<{ id: string; facility_id: string | null }>(
    `SELECT id, facility_id FROM public.providers WHERE id = $1 AND deleted_at IS NULL`,
    [providerId],
  );
  if (!existing.rows[0]) throw new NotFoundError('Provider', providerId);

  await withTransaction(async (client) => {
    // Keep the provider's existing home facility (don't move them); only fill it
    // in if they have none. The many-to-many link is the source of truth for
    // "works at this facility".
    await client.query(
      `UPDATE public.providers SET
         facility_id = COALESCE(facility_id, $2),
         tenant_id = COALESCE(tenant_id, $2),
         is_active = true,
         updated_at = now()
       WHERE id = $1`,
      [providerId, facilityId],
    );
    await client.query(
      `INSERT INTO public.provider_facility_links (
         provider_id, facility_id, link_type, is_primary, match_confidence,
         is_active, is_accepting_bookings
       ) VALUES ($1, $2, 'affiliated', false, 'HIGH', true, true)
       ON CONFLICT (provider_id, facility_id) DO UPDATE SET is_active = true`,
      [providerId, facilityId],
    );
  });

  return { id: providerId, attached: true };
}

export async function createDoctor(
  user: AuthenticatedUser,
  facilityId: string,
  data: {
    name: string;
    specialty?: string;
    mdpczNumber?: string;
    phone?: string;
    email?: string;
    isAcceptingBookings?: boolean;
  },
) {
  await requireFacilityAdmin(user, facilityId);

  // If the MDPCZ number matches an existing registry record, attach it instead
  // of creating a duplicate provider row.
  if (data.mdpczNumber && data.mdpczNumber.trim()) {
    const reg = normalizeRegistrationNumber(data.mdpczNumber);
    const existing = await query<{ id: string }>(
      `SELECT id FROM public.providers
       WHERE (UPPER(REPLACE(registration_number, ' ', '')) = $1
              OR UPPER(REPLACE(mdpcz_number, ' ', '')) = $1)
         AND deleted_at IS NULL
       LIMIT 1`,
      [reg],
    );
    if (existing.rows[0]) {
      return attachDoctor(user, facilityId, existing.rows[0].id);
    }
  }

  const result = await query(
    `INSERT INTO public.providers (
       facility_id, tenant_id, name, specialty, mdpcz_number, phone, email, is_accepting_bookings
     ) VALUES ($1, $1, $2, $3, $4, $5, $6, $7)
     RETURNING id`,
    [
      facilityId,
      data.name,
      data.specialty ?? null,
      data.mdpczNumber ?? null,
      data.phone ?? null,
      data.email ?? null,
      data.isAcceptingBookings ?? true,
    ],
  );

  return { id: result.rows[0].id, attached: false };
}

export async function updateDoctor(
  user: AuthenticatedUser,
  facilityId: string,
  doctorId: string,
  data: {
    name?: string;
    specialty?: string;
    mdpczNumber?: string;
    phone?: string;
    email?: string;
    isAcceptingBookings?: boolean;
    isActive?: boolean;
  },
) {
  await requireFacilityAdmin(user, facilityId);

  // The provider must belong to this facility's roster (homed here or linked).
  const assoc = await query<{ id: string }>(
    `SELECT p.id
     FROM public.providers p
     LEFT JOIN public.provider_facility_links pfl
       ON pfl.provider_id = p.id AND pfl.facility_id = $1
     WHERE p.id = $2 AND (p.facility_id = $1 OR pfl.facility_id = $1)
       AND p.deleted_at IS NULL
     LIMIT 1`,
    [facilityId, doctorId],
  );
  if (!assoc.rows[0]) throw new NotFoundError('Doctor', doctorId);

  const hasShared =
    data.name !== undefined ||
    data.specialty !== undefined ||
    data.mdpczNumber !== undefined ||
    data.phone !== undefined ||
    data.email !== undefined;
  const hasPerFacility = data.isAcceptingBookings !== undefined || data.isActive !== undefined;

  await withTransaction(async (client) => {
    // Shared attributes live on the provider record (apply to all facilities).
    if (hasShared) {
      await client.query(
        `UPDATE public.providers SET
           name = COALESCE($2, name),
           specialty = COALESCE($3, specialty),
           mdpcz_number = COALESCE($4, mdpcz_number),
           phone = COALESCE($5, phone),
           email = COALESCE($6, email),
           updated_at = now()
         WHERE id = $1`,
        [
          doctorId,
          data.name ?? null,
          data.specialty ?? null,
          data.mdpczNumber ?? null,
          data.phone ?? null,
          data.email ?? null,
        ],
      );
    }

    // Active / accepting-bookings state is per-facility, stored on the link.
    if (hasPerFacility) {
      await client.query(
        `INSERT INTO public.provider_facility_links (
           provider_id, facility_id, link_type, is_primary, match_confidence,
           is_active, is_accepting_bookings
         ) VALUES ($1, $2, 'affiliated', false, 'HIGH', true, true)
         ON CONFLICT (provider_id, facility_id) DO NOTHING`,
        [doctorId, facilityId],
      );
      await client.query(
        `UPDATE public.provider_facility_links SET
           is_active = COALESCE($3, is_active),
           is_accepting_bookings = COALESCE($4, is_accepting_bookings)
         WHERE provider_id = $1 AND facility_id = $2`,
        [doctorId, facilityId, data.isActive ?? null, data.isAcceptingBookings ?? null],
      );
    }
  });

  return { id: doctorId };
}

// --- Operating hours ---

export async function listFacilityHours(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const rows = await query(
    `SELECT id, day_of_week, opens_at, closes_at, is_closed, is_24_hours
     FROM public.facility_operating_hours
     WHERE facility_id = $1
     ORDER BY day_of_week ASC`,
    [facilityId],
  );
  return { hours: rows.rows };
}

export async function upsertFacilityHours(
  user: AuthenticatedUser,
  facilityId: string,
  hours: {
    dayOfWeek: number;
    opensAt?: string | null;
    closesAt?: string | null;
    isClosed?: boolean;
    is24Hours?: boolean;
  }[],
) {
  await requireFacilityAdmin(user, facilityId);

  await withTransaction(async (client) => {
    for (const h of hours) {
      await client.query(
        `INSERT INTO public.facility_operating_hours (
           facility_id, tenant_id, day_of_week, opens_at, closes_at, is_closed, is_24_hours
         ) VALUES ($1, $1, $2, $3, $4, $5, $6)
         ON CONFLICT (facility_id, day_of_week) DO UPDATE SET
           opens_at = EXCLUDED.opens_at,
           closes_at = EXCLUDED.closes_at,
           is_closed = EXCLUDED.is_closed,
           is_24_hours = EXCLUDED.is_24_hours,
           updated_at = now()`,
        [
          facilityId,
          h.dayOfWeek,
          h.opensAt ?? null,
          h.closesAt ?? null,
          h.isClosed ?? false,
          h.is24Hours ?? false,
        ],
      );
    }
  });

  return listFacilityHours(user, facilityId);
}

// --- Provider availability ---

export async function listProviderAvailability(
  user: AuthenticatedUser,
  facilityId: string,
  providerId?: string,
) {
  await assertFacilityAccess(user, facilityId);
  const params: unknown[] = [facilityId];
  let clause =
    `(p.facility_id = $1 OR EXISTS (
        SELECT 1 FROM public.provider_facility_links pfl
        WHERE pfl.provider_id = p.id AND pfl.facility_id = $1
      ))`;
  if (providerId) {
    params.push(providerId);
    clause += ` AND p.id = $${params.length}`;
  }

  const rows = await query(
    `SELECT h.id, h.provider_id, p.name AS provider_name,
            h.day_of_week, h.opens_at, h.closes_at, h.is_closed
     FROM public.provider_working_hours h
     JOIN public.providers p ON p.id = h.provider_id
     WHERE ${clause}
     ORDER BY p.name, h.day_of_week`,
    params,
  );

  return { availability: rows.rows };
}

export async function upsertProviderAvailability(
  user: AuthenticatedUser,
  facilityId: string,
  providerId: string,
  hours: { dayOfWeek: number; opensAt?: string | null; closesAt?: string | null; isClosed?: boolean }[],
) {
  await assertCanManageProvider(user, facilityId, providerId);

  const check = await query(
    `SELECT p.id FROM public.providers p
     WHERE p.id = $1
       AND (p.facility_id = $2 OR EXISTS (
         SELECT 1 FROM public.provider_facility_links pfl
         WHERE pfl.provider_id = p.id AND pfl.facility_id = $2
       ))`,
    [providerId, facilityId],
  );
  if (!check.rows[0]) throw new NotFoundError('Doctor', providerId);

  await withTransaction(async (client) => {
    for (const h of hours) {
      await client.query(
        `INSERT INTO public.provider_working_hours (provider_id, day_of_week, opens_at, closes_at, is_closed)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (provider_id, day_of_week) DO UPDATE SET
           opens_at = EXCLUDED.opens_at,
           closes_at = EXCLUDED.closes_at,
           is_closed = EXCLUDED.is_closed`,
        [providerId, h.dayOfWeek, h.opensAt ?? null, h.closesAt ?? null, h.isClosed ?? false],
      );
    }
  });

  return listProviderAvailability(user, facilityId, providerId);
}

// --- Appointment slots (tenant settings) ---

export async function getSlotSettings(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const row = await query(
    `SELECT value FROM public.app_settings
     WHERE tenant_id = $1 AND scope = 'tenant' AND key = 'appointment_slots'`,
    [facilityId],
  );
  const defaults = { slotDurationMinutes: 30, bufferMinutes: 5, maxAdvanceDays: 30 };
  return { settings: row.rows[0]?.value ?? defaults };
}

export async function updateSlotSettings(
  user: AuthenticatedUser,
  facilityId: string,
  settings: Record<string, unknown>,
) {
  await requireFacilityAdmin(user, facilityId);
  await query(
    `INSERT INTO public.app_settings (tenant_id, scope, key, value, description)
     VALUES ($1, 'tenant', 'appointment_slots', $2::jsonb, 'Appointment slot configuration')
     ON CONFLICT (tenant_id, scope, key) DO UPDATE SET value = EXCLUDED.value, updated_at = now()`,
    [facilityId, JSON.stringify(settings)],
  );
  return getSlotSettings(user, facilityId);
}

// --- Patients ---

export async function listPatients(user: AuthenticatedUser, facilityId: string, opts: AdminListQuery) {
  await assertFacilityAccess(user, facilityId);
  const params: unknown[] = [facilityId];
  let idx = 2;
  const search = buildSearchClause(
    ['pr.first_name', 'pr.last_name', 'pr.phone', 'pr.email'],
    opts.q,
    params,
    idx,
  );
  idx = search.nextIdx;

  const where = `(EXISTS (
    SELECT 1 FROM public.appointments a
    WHERE a.patient_id = pr.id AND a.tenant_id = $1 AND a.deleted_at IS NULL
  ) OR EXISTS (
    SELECT 1 FROM public.walk_in_sessions w
    WHERE w.patient_id = pr.id AND w.tenant_id = $1 AND w.deleted_at IS NULL
  )) AND ${search.clause}`;

  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(DISTINCT pr.id)::text AS count
     FROM public.profiles pr
     WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT DISTINCT pr.id, pr.first_name, pr.last_name, pr.phone, pr.email,
            pr.date_of_birth, pr.created_at,
            (SELECT MAX(a.scheduled_at) FROM public.appointments a
             WHERE a.patient_id = pr.id AND a.tenant_id = $1) AS last_visit
     FROM public.profiles pr
     WHERE ${where}
     ORDER BY last_visit DESC NULLS LAST
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    patients: rows.rows.map((r) => ({
      id: r.id,
      firstName: r.first_name,
      lastName: r.last_name,
      phone: r.phone,
      email: r.email,
      dateOfBirth: r.date_of_birth,
      lastVisit: r.last_visit ? (r.last_visit as Date).toISOString() : null,
      createdAt: (r.created_at as Date).toISOString(),
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

async function createAuthUserWithPhone(phone: string): Promise<string> {
  const response = await fetch(`${env.SUPABASE_URL}/auth/v1/admin/users`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      apikey: env.SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,
    },
    body: JSON.stringify({ phone, phone_confirm: true, user_metadata: { registered_by: 'facility_portal' } }),
  });

  const data = (await response.json()) as { id?: string; msg?: string; message?: string };
  if (!response.ok) {
    throw new AppError(response.status, 'PATIENT_REGISTER_ERROR', data.msg ?? data.message ?? 'Failed to create patient');
  }
  return data.id!;
}

export async function registerPatient(
  user: AuthenticatedUser,
  facilityId: string,
  data: { firstName: string; lastName?: string; phone: string; email?: string; dateOfBirth?: string },
) {
  await assertFacilityAccess(user, facilityId, ['facility_admin', 'receptionist']);
  const phone = normalizeZimbabwePhone(data.phone);

  const existing = await query<{ id: string }>(
    `SELECT id FROM public.profiles WHERE phone = $1`,
    [phone],
  );
  if (existing.rows[0]) {
    return { id: existing.rows[0].id, existing: true };
  }

  const userId = await createAuthUserWithPhone(phone);
  await query(
    `INSERT INTO public.profiles (id, primary_role, first_name, last_name, phone, email, date_of_birth)
     VALUES ($1, 'patient', $2, $3, $4, $5, $6)
     ON CONFLICT (id) DO UPDATE SET
       first_name = EXCLUDED.first_name,
       last_name = EXCLUDED.last_name,
       phone = EXCLUDED.phone,
       email = COALESCE(EXCLUDED.email, profiles.email),
       date_of_birth = COALESCE(EXCLUDED.date_of_birth, profiles.date_of_birth)`,
    [userId, data.firstName, data.lastName ?? null, phone, data.email ?? null, data.dateOfBirth ?? null],
  );

  return { id: userId, existing: false };
}

export async function getPatientHistory(
  user: AuthenticatedUser,
  facilityId: string,
  patientId: string,
  context?: RequestContext,
) {
  await assertFacilityAccess(user, facilityId);

  const profile = await query(
    `SELECT id, first_name, last_name, phone, email, date_of_birth, created_at
     FROM public.profiles WHERE id = $1`,
    [patientId],
  );
  if (!profile.rows[0]) throw new NotFoundError('Patient', patientId);

  const [appointments, walkIns] = await Promise.all([
    query(
      `SELECT a.id, a.reference_number, a.scheduled_at, a.status, a.duration_minutes,
              p.name AS provider_name
       FROM public.appointments a
       JOIN public.providers p ON p.id = a.provider_id
       WHERE a.patient_id = $1 AND a.tenant_id = $2 AND a.deleted_at IS NULL
       ORDER BY a.scheduled_at DESC LIMIT 50`,
      [patientId, facilityId],
    ),
    query(
      `SELECT w.id, w.ticket_number, w.status, w.registered_at, w.chief_complaint,
              p.name AS provider_name
       FROM public.walk_in_sessions w
       LEFT JOIN public.providers p ON p.id = w.provider_id
       WHERE w.patient_id = $1 AND w.tenant_id = $2 AND w.deleted_at IS NULL
       ORDER BY w.registered_at DESC LIMIT 50`,
      [patientId, facilityId],
    ),
  ]);

  await logMedicalAccess({
    actorId: user.id,
    patientId,
    resourceType: 'patient_history',
    resourceId: patientId,
    action: 'read',
    tenantId: facilityId,
    context,
    details: {
      appointmentCount: appointments.rows.length,
      walkInCount: walkIns.rows.length,
    },
  });

  return {
    patient: profile.rows[0],
    appointments: appointments.rows,
    walkIns: walkIns.rows,
  };
}

// --- Appointments ---

function generateReference(): string {
  return `SH-${Date.now().toString(36).toUpperCase()}`;
}

export async function listAppointments(user: AuthenticatedUser, facilityId: string, opts: AdminListQuery) {
  await assertFacilityAccess(user, facilityId);
  const params: unknown[] = [facilityId];
  let idx = 2;
  const conditions = ['a.tenant_id = $1', 'a.deleted_at IS NULL'];

  if (opts.status) {
    conditions.push(`a.status = $${idx++}`);
    params.push(opts.status);
  }

  if (opts.from) {
    conditions.push(`a.scheduled_at >= $${idx++}`);
    params.push(opts.from);
  }

  if (opts.to) {
    conditions.push(`a.scheduled_at <= $${idx++}`);
    params.push(opts.to);
  }

  const search = buildSearchClause(
    ['a.reference_number', 'pr.first_name', 'pr.last_name', 'p.name'],
    opts.q,
    params,
    idx,
  );
  idx = search.nextIdx;
  conditions.push(search.clause);

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);
  const sortDir = opts.sortOrder === 'asc' ? 'ASC' : 'DESC';

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM public.appointments a
     JOIN public.profiles pr ON pr.id = a.patient_id
     JOIN public.providers p ON p.id = a.provider_id
     WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT a.id, a.reference_number, a.scheduled_at, a.duration_minutes, a.status,
            a.cancellation_reason, a.notes,
            pr.first_name || ' ' || COALESCE(pr.last_name, '') AS patient_name,
            p.name AS provider_name
     FROM public.appointments a
     JOIN public.profiles pr ON pr.id = a.patient_id
     JOIN public.providers p ON p.id = a.provider_id
     WHERE ${where}
     ORDER BY a.scheduled_at ${sortDir}
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    appointments: rows.rows,
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function createAppointment(
  user: AuthenticatedUser,
  facilityId: string,
  data: {
    patientId: string;
    providerId: string;
    scheduledAt: string;
    durationMinutes?: number;
    notes?: string;
  },
  context?: RequestContext,
) {
  await assertFacilityAccess(user, facilityId, ['facility_admin', 'receptionist']);

  const ref = generateReference();
  const result = await query(
    `INSERT INTO public.appointments (
       reference_number, facility_id, tenant_id, provider_id, patient_id,
       scheduled_at, duration_minutes, status, notes, booked_by
     ) VALUES ($1, $2, $2, $3, $4, $5, $6, 'confirmed', $7, $8)
     RETURNING id, reference_number`,
    [
      ref,
      facilityId,
      data.providerId,
      data.patientId,
      data.scheduledAt,
      data.durationMinutes ?? 30,
      data.notes ?? null,
      user.id,
    ],
  );

  const row = result.rows[0];
  await logAppointmentAudit(
    user.id,
    'appointment.create',
    row.id as string,
    facilityId,
    context,
    { referenceNumber: row.reference_number, patientId: data.patientId, providerId: data.providerId },
  );

  return row;
}

export async function rescheduleAppointment(
  user: AuthenticatedUser,
  facilityId: string,
  appointmentId: string,
  data: { scheduledAt: string; notes?: string },
  context?: RequestContext,
) {
  await assertFacilityAccess(user, facilityId, ['facility_admin', 'receptionist']);

  const result = await query(
    `UPDATE public.appointments SET
       scheduled_at = $3,
       notes = COALESCE($4, notes),
       status = 'confirmed',
       updated_at = now()
     WHERE id = $2 AND tenant_id = $1 AND deleted_at IS NULL
     RETURNING id`,
    [facilityId, appointmentId, data.scheduledAt, data.notes ?? null],
  );
  if (!result.rows[0]) throw new NotFoundError('Appointment', appointmentId);
  await logAppointmentAudit(
    user.id,
    'appointment.reschedule',
    appointmentId,
    facilityId,
    context,
    { scheduledAt: data.scheduledAt },
  );
  return { id: appointmentId };
}

export async function cancelAppointment(
  user: AuthenticatedUser,
  facilityId: string,
  appointmentId: string,
  reason?: string,
  context?: RequestContext,
) {
  await assertFacilityAccess(user, facilityId, ['facility_admin', 'receptionist']);
  const result = await query(
    `UPDATE public.appointments SET
       status = 'cancelled',
       cancellation_reason = $3,
       updated_at = now()
     WHERE id = $2 AND tenant_id = $1 AND deleted_at IS NULL
     RETURNING id`,
    [facilityId, appointmentId, reason ?? null],
  );
  if (!result.rows[0]) throw new NotFoundError('Appointment', appointmentId);
  await logAppointmentAudit(
    user.id,
    'appointment.cancel',
    appointmentId,
    facilityId,
    context,
    { reason: reason ?? null },
  );
  return { id: appointmentId };
}

async function ensureQueueSession(facilityId: string, providerId?: string) {
  const existing = await query<{ id: string; current_ticket_number: number }>(
    `SELECT id, current_ticket_number FROM public.queue_sessions
     WHERE facility_id = $1 AND session_date = (timezone('utc', now()))::date
       AND is_active = true
       AND ($2::uuid IS NULL OR provider_id = $2)
     ORDER BY created_at DESC LIMIT 1`,
    [facilityId, providerId ?? null],
  );
  if (existing.rows[0]) return existing.rows[0];

  const created = await query<{ id: string; current_ticket_number: number }>(
    `INSERT INTO public.queue_sessions (facility_id, tenant_id, provider_id, session_date, name)
     VALUES ($1, $1, $2, (timezone('utc', now()))::date, 'Walk-in queue')
     RETURNING id, current_ticket_number`,
    [facilityId, providerId ?? null],
  );
  return created.rows[0];
}

export async function listWalkIns(user: AuthenticatedUser, facilityId: string, opts: AdminListQuery) {
  await assertFacilityAccess(user, facilityId);
  const params: unknown[] = [facilityId];
  let idx = 2;
  const conditions = ['w.tenant_id = $1', 'w.deleted_at IS NULL'];

  if (opts.status) {
    conditions.push(`w.queue_status = $${idx++}`);
    params.push(opts.status);
  }

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.walk_in_sessions w WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT w.id, w.ticket_number, w.status, w.queue_status, w.priority,
            w.estimated_wait_minutes, w.registered_at, w.called_at, w.chief_complaint,
            pr.first_name || ' ' || COALESCE(pr.last_name, '') AS patient_name,
            p.name AS provider_name
     FROM public.walk_in_sessions w
     JOIN public.profiles pr ON pr.id = w.patient_id
     LEFT JOIN public.providers p ON p.id = w.provider_id
     WHERE ${where}
     ORDER BY w.priority DESC, w.ticket_number ASC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    queue: rows.rows,
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function registerWalkIn(
  user: AuthenticatedUser,
  facilityId: string,
  data: {
    patientId: string;
    providerId?: string;
    chiefComplaint?: string;
    priority?: number;
  },
) {
  await assertFacilityAccess(user, facilityId, ['facility_admin', 'receptionist']);

  const session = await ensureQueueSession(facilityId, data.providerId);
  const ticketNumber = session.current_ticket_number + 1;

  const waiting = await query<{ count: string; avg: string | null }>(
    `SELECT COUNT(*)::text AS count, AVG(estimated_wait_minutes)::text AS avg
     FROM public.walk_in_sessions
     WHERE queue_session_id = $1 AND queue_status = 'waiting' AND deleted_at IS NULL`,
    [session.id],
  );
  const avgWait = waiting.rows[0]?.avg ? Number(waiting.rows[0].avg) : 15;
  const estimatedWait = Math.round(avgWait * (Number(waiting.rows[0]?.count ?? 0) + 1));

  const result = await withTransaction(async (client) => {
    await client.query(
      `UPDATE public.queue_sessions SET current_ticket_number = $2, updated_at = now() WHERE id = $1`,
      [session.id, ticketNumber],
    );

    const inserted = await client.query(
      `INSERT INTO public.walk_in_sessions (
         facility_id, tenant_id, provider_id, queue_session_id, patient_id,
         ticket_number, chief_complaint, priority, estimated_wait_minutes, registered_by
       ) VALUES ($1, $1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING id, ticket_number, estimated_wait_minutes`,
      [
        facilityId,
        data.providerId ?? null,
        session.id,
        data.patientId,
        ticketNumber,
        data.chiefComplaint ?? null,
        data.priority ?? 0,
        estimatedWait,
        user.id,
      ],
    );
    return inserted.rows[0];
  });

  return result;
}

export async function updateWalkInStatus(
  user: AuthenticatedUser,
  facilityId: string,
  walkInId: string,
  status: 'waiting' | 'called' | 'in_progress' | 'completed' | 'cancelled',
) {
  await assertFacilityAccess(user, facilityId, ['facility_admin', 'receptionist', 'doctor']);

  const timestamps: Record<string, string> = {
    called: ', called_at = now()',
    in_progress: ', started_at = now()',
    completed: ', completed_at = now()',
    cancelled: ', completed_at = now()',
  };

  const result = await query(
    `UPDATE public.walk_in_sessions SET
       queue_status = $3,
       status = CASE
         WHEN $3 = 'completed' THEN 'completed'::public.walk_in_status
         WHEN $3 = 'cancelled' THEN 'cancelled'::public.walk_in_status
         ELSE status
       END
       ${timestamps[status] ?? ''},
       updated_at = now()
     WHERE id = $2 AND tenant_id = $1 AND deleted_at IS NULL
     RETURNING id, ticket_number, queue_status, estimated_wait_minutes`,
    [facilityId, walkInId, status],
  );
  if (!result.rows[0]) throw new NotFoundError('Walk-in', walkInId);
  return result.rows[0];
}

export async function getQueueStats(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const [result, control] = await Promise.all([
    query(
      `SELECT
         COUNT(*) FILTER (WHERE queue_status = 'waiting')::int AS waiting,
         COUNT(*) FILTER (WHERE queue_status = 'in_progress')::int AS in_progress,
         COUNT(*) FILTER (WHERE queue_status = 'completed')::int AS completed_today,
         AVG(estimated_wait_minutes) FILTER (WHERE queue_status = 'waiting') AS avg_wait,
         MAX(ticket_number) AS last_ticket
       FROM public.walk_in_sessions
       WHERE tenant_id = $1 AND deleted_at IS NULL
         AND registered_at >= date_trunc('day', now())`,
      [facilityId],
    ),
    getQueueControl(user, facilityId),
  ]);
  return { stats: result.rows[0], paused: control.paused };
}

export async function getQueueControl(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const row = await query(
    `SELECT value FROM public.app_settings
     WHERE tenant_id = $1 AND scope = 'tenant' AND key = 'queue_control'`,
    [facilityId],
  );
  const value = (row.rows[0]?.value ?? {}) as Record<string, unknown>;
  return { paused: Boolean(value.paused) };
}

export async function setQueuePaused(
  user: AuthenticatedUser,
  facilityId: string,
  paused: boolean,
) {
  await assertFacilityAccess(user, facilityId, ['facility_admin', 'receptionist']);
  await query(
    `INSERT INTO public.app_settings (tenant_id, scope, key, value, description)
     VALUES ($1, 'tenant', 'queue_control', $2::jsonb, 'Queue pause state')
     ON CONFLICT (tenant_id, scope, key) DO UPDATE SET value = EXCLUDED.value, updated_at = now()`,
    [facilityId, JSON.stringify({ paused, updatedAt: new Date().toISOString() })],
  );
  return { paused };
}

export async function delayWalkIn(
  user: AuthenticatedUser,
  facilityId: string,
  walkInId: string,
  additionalMinutes: number,
) {
  await assertFacilityAccess(user, facilityId, ['facility_admin', 'receptionist', 'doctor']);
  const result = await query(
    `UPDATE public.walk_in_sessions SET
       estimated_wait_minutes = COALESCE(estimated_wait_minutes, 0) + $3,
       priority = COALESCE(priority, 0) + 1,
       updated_at = now()
     WHERE id = $2 AND tenant_id = $1 AND deleted_at IS NULL
     RETURNING id, ticket_number, estimated_wait_minutes, queue_status`,
    [facilityId, walkInId, additionalMinutes],
  );
  if (!result.rows[0]) throw new NotFoundError('Walk-in', walkInId);
  return result.rows[0];
}

// --- Emergency availability (tenant settings) ---

export async function getEmergencyAvailability(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const row = await query(
    `SELECT value FROM public.app_settings
     WHERE tenant_id = $1 AND scope = 'tenant' AND key = 'emergency_availability'`,
    [facilityId],
  );
  const defaults = {
    acceptsEmergency: false,
    emergencyPhone: null,
    notes: '',
    afterHoursContact: null,
  };
  return { availability: row.rows[0]?.value ?? defaults };
}

export async function updateEmergencyAvailability(
  user: AuthenticatedUser,
  facilityId: string,
  availability: Record<string, unknown>,
) {
  await requireFacilityAdmin(user, facilityId);
  await query(
    `INSERT INTO public.app_settings (tenant_id, scope, key, value, description)
     VALUES ($1, 'tenant', 'emergency_availability', $2::jsonb, 'Facility emergency availability')
     ON CONFLICT (tenant_id, scope, key) DO UPDATE SET value = EXCLUDED.value, updated_at = now()`,
    [facilityId, JSON.stringify(availability)],
  );
  return getEmergencyAvailability(user, facilityId);
}

// --- Schedule overrides (closures & holidays) ---

export async function getScheduleOverrides(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const row = await query(
    `SELECT value FROM public.app_settings
     WHERE tenant_id = $1 AND scope = 'tenant' AND key = 'schedule_overrides'`,
    [facilityId],
  );
  const defaults = {
    temporarilyClosed: false,
    closureReason: '',
    holidays: [] as { date: string; label: string }[],
  };
  return { overrides: row.rows[0]?.value ?? defaults };
}

export async function updateScheduleOverrides(
  user: AuthenticatedUser,
  facilityId: string,
  overrides: Record<string, unknown>,
) {
  await requireFacilityAdmin(user, facilityId);
  await query(
    `INSERT INTO public.app_settings (tenant_id, scope, key, value, description)
     VALUES ($1, 'tenant', 'schedule_overrides', $2::jsonb, 'Facility closure and holiday overrides')
     ON CONFLICT (tenant_id, scope, key) DO UPDATE SET value = EXCLUDED.value, updated_at = now()`,
    [facilityId, JSON.stringify(overrides)],
  );
  return getScheduleOverrides(user, facilityId);
}

// --- Billing (V1 placeholder — read-only summaries) ---

export async function getBillingDashboard(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);

  const [invoices, payments, claims] = await Promise.all([
    query(
      `SELECT status, COUNT(*)::int AS count, COALESCE(SUM(total_cents), 0)::bigint AS total_cents
       FROM public.invoices WHERE tenant_id = $1 AND deleted_at IS NULL
       GROUP BY status`,
      [facilityId],
    ),
    query(
      `SELECT COUNT(*)::int AS count, COALESCE(SUM(amount_cents), 0)::bigint AS total_cents
       FROM public.payments WHERE tenant_id = $1 AND deleted_at IS NULL AND status = 'completed'`,
      [facilityId],
    ),
    query(
      `SELECT COUNT(*)::int AS pending_claims
       FROM public.invoices
       WHERE tenant_id = $1 AND deleted_at IS NULL
         AND metadata->>'claim_status' = 'pending'`,
      [facilityId],
    ),
  ]);

  return {
    placeholder: true,
    message: 'Advanced accounting is planned for a future phase. Below are summary counts only.',
    invoicesByStatus: invoices.rows,
    paymentsTotal: payments.rows[0],
    pendingMedicalAidClaims: claims.rows[0]?.pending_claims ?? 0,
  };
}

// --- Inventory ---

export async function listProducts(user: AuthenticatedUser, facilityId: string, opts: AdminListQuery) {
  await assertFacilityAccess(user, facilityId);
  const params: unknown[] = [facilityId];
  let idx = 2;
  const conditions = ['p.tenant_id = $1', 'p.deleted_at IS NULL'];

  if (opts.status === 'low_stock') {
    conditions.push('p.current_stock <= p.reorder_level');
  }

  const search = buildSearchClause(['p.name', 'p.sku', 'p.category'], opts.q, params, idx);
  idx = search.nextIdx;
  conditions.push(search.clause);

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.products p WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT p.id, p.sku, p.name, p.category, p.unit_of_measure,
            p.current_stock, p.reorder_level, p.unit_price_cents, p.is_active
     FROM public.products p
     WHERE ${where}
     ORDER BY p.name ASC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    products: rows.rows,
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function createProduct(
  user: AuthenticatedUser,
  facilityId: string,
  data: {
    sku: string;
    name: string;
    category?: string;
    unitOfMeasure?: string;
    reorderLevel?: number;
    currentStock?: number;
    unitPriceCents?: number;
  },
) {
  await assertFacilityAccess(user, facilityId, ['facility_admin', 'receptionist']);

  const result = await query(
    `INSERT INTO public.products (
       facility_id, tenant_id, sku, name, category, unit_of_measure,
       reorder_level, current_stock, unit_price_cents
     ) VALUES ($1, $1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING id`,
    [
      facilityId,
      data.sku,
      data.name,
      data.category ?? null,
      data.unitOfMeasure ?? 'each',
      data.reorderLevel ?? 0,
      data.currentStock ?? 0,
      data.unitPriceCents ?? null,
    ],
  );
  return { id: result.rows[0].id };
}

export async function updateProduct(
  user: AuthenticatedUser,
  facilityId: string,
  productId: string,
  data: Partial<{
    name: string;
    category: string;
    reorderLevel: number;
    unitPriceCents: number;
    isActive: boolean;
  }>,
) {
  await assertFacilityAccess(user, facilityId, ['facility_admin', 'receptionist']);
  const result = await query(
    `UPDATE public.products SET
       name = COALESCE($3, name),
       category = COALESCE($4, category),
       reorder_level = COALESCE($5, reorder_level),
       unit_price_cents = COALESCE($6, unit_price_cents),
       is_active = COALESCE($7, is_active),
       updated_at = now()
     WHERE id = $2 AND tenant_id = $1
     RETURNING id`,
    [
      facilityId,
      productId,
      data.name ?? null,
      data.category ?? null,
      data.reorderLevel ?? null,
      data.unitPriceCents ?? null,
      data.isActive ?? null,
    ],
  );
  if (!result.rows[0]) throw new NotFoundError('Product', productId);
  return { id: productId };
}

export async function adjustStock(
  user: AuthenticatedUser,
  facilityId: string,
  productId: string,
  data: { quantity: number; movementType: string; notes?: string },
) {
  await assertFacilityAccess(user, facilityId, ['facility_admin', 'receptionist']);

  const check = await query(`SELECT id FROM public.products WHERE id = $1 AND tenant_id = $2`, [
    productId,
    facilityId,
  ]);
  if (!check.rows[0]) throw new NotFoundError('Product', productId);

  await query(
    `INSERT INTO public.stock_movements (
       product_id, tenant_id, movement_type, quantity, notes, performed_by
     ) VALUES ($1, $2, $3::public.stock_movement_type, $4, $5, $6)`,
    [productId, facilityId, data.movementType, data.quantity, data.notes ?? null, user.id],
  );

  return { id: productId };
}

export async function getInventoryAlerts(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const rows = await query(
    `SELECT id, sku, name, category, current_stock, reorder_level
     FROM public.products
     WHERE tenant_id = $1 AND deleted_at IS NULL AND is_active = true
       AND current_stock <= reorder_level
     ORDER BY current_stock ASC LIMIT 50`,
    [facilityId],
  );
  return { alerts: rows.rows };
}

// --- Staff ---

function splitFullName(fullName: string): { firstName: string; lastName: string | null } {
  const trimmed = fullName.trim();
  if (!trimmed) throw new ValidationError('Full name is required');
  const parts = trimmed.split(/\s+/);
  return {
    firstName: parts[0]!,
    lastName: parts.length > 1 ? parts.slice(1).join(' ') : null,
  };
}

function authAdminBaseUrl(): string {
  return env.SUPABASE_URL.includes('kong')
    ? 'http://auth:9999'
    : `${env.SUPABASE_URL.replace(/\/$/, '')}/auth/v1`;
}

async function createAuthUserForStaff(email: string, phone: string | null): Promise<string> {
  const body: Record<string, unknown> = {
    email,
    email_confirm: true,
    user_metadata: { registered_by: 'facility_portal_staff' },
  };
  if (phone) {
    body.phone = phone;
    body.phone_confirm = true;
  }

  const response = await fetch(`${authAdminBaseUrl()}/admin/users`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      apikey: env.SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,
    },
    body: JSON.stringify(body),
  });

  const data = (await response.json()) as { id?: string; msg?: string; message?: string };
  if (!response.ok) {
    throw new AppError(
      response.status,
      'STAFF_CREATE_ERROR',
      data.msg ?? data.message ?? 'Failed to create staff account',
    );
  }
  return data.id!;
}

async function resolveStaffUserId(data: {
  firstName: string;
  lastName: string | null;
  email: string;
  phone: string | null;
}): Promise<string> {
  const byEmail = await query<{ id: string }>(
    `SELECT id FROM public.profiles WHERE lower(email) = $1`,
    [data.email],
  );
  const byPhone = data.phone
    ? await query<{ id: string }>(
        `SELECT id FROM public.profiles WHERE phone = $1`,
        [data.phone],
      )
    : { rows: [] as { id: string }[] };

  if (byEmail.rows[0] && byPhone.rows[0] && byEmail.rows[0].id !== byPhone.rows[0].id) {
    throw new ValidationError('Email and phone belong to different accounts');
  }

  if (byEmail.rows[0]) return byEmail.rows[0].id;
  if (byPhone.rows[0]) return byPhone.rows[0].id;

  const userId = await createAuthUserForStaff(data.email, data.phone);
  await query(
    `INSERT INTO public.profiles (id, primary_role, first_name, last_name, email, phone)
     VALUES ($1, 'receptionist', $2, $3, $4, $5)
     ON CONFLICT (id) DO NOTHING`,
    [userId, data.firstName, data.lastName, data.email, data.phone],
  );
  return userId;
}

export async function listStaff(user: AuthenticatedUser, facilityId: string, opts: AdminListQuery) {
  await assertFacilityAccess(user, facilityId);
  const params: unknown[] = [facilityId];
  let idx = 2;
  const search = buildSearchClause(
    ['p.first_name', 'p.last_name', 'p.email', 'p.phone'],
    opts.q,
    params,
    idx,
  );
  idx = search.nextIdx;

  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM public.facility_memberships fm
     JOIN public.profiles p ON p.id = fm.user_id
     WHERE fm.facility_id = $1 AND ${search.clause}`,
    params,
  );

  const rows = await query(
    `SELECT fm.id, fm.role, fm.additional_roles, fm.joined_at, fm.suspended_at,
            p.id AS user_id, p.first_name, p.last_name, p.email, p.phone
     FROM public.facility_memberships fm
     JOIN public.profiles p ON p.id = fm.user_id
     WHERE fm.facility_id = $1 AND ${search.clause}
     ORDER BY fm.joined_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    staff: rows.rows.map((row) => ({
      ...row,
      membership_id: row.id,
      suspended: row.suspended_at !== null,
      additional_roles: row.additional_roles ?? [],
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function updateStaffMember(
  user: AuthenticatedUser,
  facilityId: string,
  membershipId: string,
  data: {
    fullName?: string;
    email?: string;
    phone?: string;
    role?: 'doctor' | 'receptionist' | 'facility_admin';
    additionalRoles?: string[];
  },
  context?: RequestContext,
) {
  await requireFacilityAdmin(user, facilityId);

  const membership = await query<{ user_id: string; role: string }>(
    `SELECT user_id, role::text AS role
     FROM public.facility_memberships
     WHERE id = $1 AND facility_id = $2`,
    [membershipId, facilityId],
  );
  if (!membership.rows[0]) throw new NotFoundError('Staff membership', membershipId);

  const targetUserId = membership.rows[0].user_id;
  const currentRole = membership.rows[0].role;

  let firstName: string | undefined;
  let lastName: string | null | undefined;
  if (data.fullName !== undefined) {
    ({ firstName, lastName } = splitFullName(data.fullName));
  }

  let email: string | undefined;
  if (data.email !== undefined) {
    email = normalizeEmail(data.email);
    const current = await query<{ email: string | null }>(
      `SELECT email FROM public.profiles WHERE id = $1`,
      [targetUserId],
    );
    if ((current.rows[0]?.email ?? '').toLowerCase() !== email) {
      await assertCanAddStaffByEmail(email);
    }
  }

  let phone: string | null | undefined;
  if (data.phone !== undefined) {
    phone = data.phone.trim() ? normalizeZimbabwePhone(data.phone) : null;
  }

  if (data.role && data.role !== currentRole) {
    if (currentRole === 'facility_admin' && data.role !== 'facility_admin') {
      const admins = await query<{ count: string }>(
        `SELECT COUNT(*)::text AS count
         FROM public.facility_memberships
         WHERE facility_id = $1 AND role = 'facility_admin'::public.app_role`,
        [facilityId],
      );
      if (Number(admins.rows[0]?.count ?? 0) <= 1) {
        throw new ConflictError('Cannot change the role of the last facility administrator.');
      }
    }

    await query(
      `UPDATE public.facility_memberships SET role = $2::public.app_role WHERE id = $1`,
      [membershipId, data.role],
    );
  }

  if (data.additionalRoles !== undefined) {
    const validRoles = ['doctor', 'receptionist', 'facility_admin'];
    const filtered = data.additionalRoles.filter((r) => validRoles.includes(r));
    await query(
      `UPDATE public.facility_memberships SET additional_roles = $2 WHERE id = $1`,
      [membershipId, filtered],
    );
  }

  if (
    firstName !== undefined ||
    lastName !== undefined ||
    email !== undefined ||
    phone !== undefined ||
    data.role !== undefined
  ) {
    await query(
      `UPDATE public.profiles SET
         primary_role = COALESCE($2::public.app_role, primary_role),
         first_name = COALESCE($3, first_name),
         last_name = COALESCE($4, last_name),
         email = COALESCE($5, email),
         phone = COALESCE($6, phone)
       WHERE id = $1`,
      [
        targetUserId,
        data.role ?? null,
        firstName ?? null,
        lastName ?? null,
        email ?? null,
        phone ?? null,
      ],
    );

    if (email) {
      await ensureAuthUserEmail(targetUserId, email);
    }
  }

  await logPermissionAudit(
    user.id,
    'permission.update',
    'facility_membership',
    membershipId,
    facilityId,
    context,
    { targetUserId, role: data.role ?? currentRole },
  );

  return { id: membershipId, userId: targetUserId };
}

export async function addStaffMember(
  user: AuthenticatedUser,
  facilityId: string,
  data: {
    fullName: string;
    email: string;
    phone?: string;
    role: 'doctor' | 'receptionist' | 'facility_admin';
  },
  context?: RequestContext,
) {
  await requireFacilityAdmin(user, facilityId);

  const { firstName, lastName } = splitFullName(data.fullName);
  const email = normalizeEmail(data.email);
  const phone = data.phone?.trim() ? normalizeZimbabwePhone(data.phone) : null;

  await assertCanAddStaffByEmail(email);

  const targetUserId = await resolveStaffUserId({ firstName, lastName, email, phone });
  await ensureAuthUserEmail(targetUserId, email);

  const existingMembership = await query<{ id: string }>(
    `SELECT id FROM public.facility_memberships WHERE facility_id = $1 AND user_id = $2`,
    [facilityId, targetUserId],
  );
  if (existingMembership.rows[0]) {
    throw new ConflictError('This person is already on the facility team.');
  }

  const claimedProvider = await query<{ name: string }>(
    `SELECT name FROM public.providers
     WHERE owner_id = $1 AND is_claimed = true AND deleted_at IS NULL
     LIMIT 1`,
    [targetUserId],
  );
  if (claimedProvider.rows[0]) {
    throw new ConflictError(
      `This account is linked to practitioner ${claimedProvider.rows[0].name}. ` +
        'Invite them using their MDPCZ registration number instead of adding staff manually.',
    );
  }

  await query(
    `UPDATE public.profiles SET
       primary_role = $2::public.app_role,
       first_name = $3,
       last_name = $4,
       email = $5,
       phone = COALESCE($6, phone)
     WHERE id = $1`,
    [targetUserId, data.role, firstName, lastName, email, phone],
  );

  const result = await query(
    `INSERT INTO public.facility_memberships (facility_id, user_id, role, invited_by)
     VALUES ($1, $2, $3, $4)
     RETURNING id`,
    [facilityId, targetUserId, data.role, user.id],
  );
  const membershipId = result.rows[0].id as string;

  const facilityRow = await query<{ name: string }>(
    `SELECT name FROM public.facilities WHERE id = $1`,
    [facilityId],
  );
  const facilityName = facilityRow.rows[0]?.name ?? 'your facility';
  const portalUrl =
    process.env.FACILITY_PORTAL_URL ?? 'https://dev.smarthealth.co.zw';
  const loginUrl = `${portalUrl}/login?email=${encodeURIComponent(email)}`;

  const emailResult = await sendEmail(
    email,
    `You've been invited to ${facilityName} on SmartHealth`,
    `<p>Hello ${firstName},</p>
     <p>You have been added as <strong>${data.role.replace('_', ' ')}</strong> at ${facilityName}.</p>
     <p>Sign in at <a href="${loginUrl}">${loginUrl}</a> using this email address and request a staff login code.</p>`,
    'staff_invite',
  );

  await query(
    `INSERT INTO public.notifications (user_id, channel, status, title, body, payload)
     SELECT $1, 'in_app', 'pending', 'Facility staff invitation', $2, $3::jsonb
     WHERE EXISTS (SELECT 1 FROM public.profiles WHERE id = $1)`,
    [
      targetUserId,
      `You have been added to ${facilityName}`,
      JSON.stringify({ facilityId, role: data.role, type: 'staff_invitation' }),
    ],
  );

  await logPermissionAudit(
    user.id,
    'permission.grant',
    'facility_membership',
    membershipId,
    facilityId,
    context,
    { targetUserId, role: data.role },
  );
  return { id: membershipId, userId: targetUserId, emailSent: emailResult.success, emailError: emailResult.error ?? null };
}

export async function removeStaffMember(
  user: AuthenticatedUser,
  facilityId: string,
  membershipId: string,
  context?: RequestContext,
) {
  await requireFacilityAdmin(user, facilityId);

  const target = await query<{ user_id: string; role: string }>(
    `SELECT user_id, role::text AS role
     FROM public.facility_memberships
     WHERE id = $1 AND facility_id = $2`,
    [membershipId, facilityId],
  );
  if (!target.rows[0]) throw new NotFoundError('Staff membership', membershipId);

  if (target.rows[0].user_id === user.id) {
    throw new ConflictError('You cannot remove yourself from the facility team.');
  }

  if (target.rows[0].role === 'facility_admin') {
    const admins = await query<{ count: string }>(
      `SELECT COUNT(*)::text AS count
       FROM public.facility_memberships
       WHERE facility_id = $1 AND role = 'facility_admin'::public.app_role`,
      [facilityId],
    );
    if (Number(admins.rows[0]?.count ?? 0) <= 1) {
      throw new ConflictError('Cannot remove the last facility administrator.');
    }
  }

  const result = await query(
    `DELETE FROM public.facility_memberships WHERE id = $1 AND facility_id = $2 RETURNING id`,
    [membershipId, facilityId],
  );
  if (!result.rows[0]) throw new NotFoundError('Staff membership', membershipId);
  await logPermissionAudit(
    user.id,
    'permission.revoke',
    'facility_membership',
    membershipId,
    facilityId,
    context,
  );
  return { id: membershipId };
}

export async function suspendStaffMember(
  user: AuthenticatedUser,
  facilityId: string,
  membershipId: string,
  context?: RequestContext,
) {
  await requireFacilityAdmin(user, facilityId);

  const target = await query<{ user_id: string }>(
    `SELECT user_id FROM public.facility_memberships WHERE id = $1 AND facility_id = $2`,
    [membershipId, facilityId],
  );
  if (!target.rows[0]) throw new NotFoundError('Staff membership', membershipId);
  if (target.rows[0].user_id === user.id) {
    throw new ConflictError('You cannot suspend yourself.');
  }

  await query(
    `UPDATE public.facility_memberships SET suspended_at = NOW() WHERE id = $1 AND facility_id = $2`,
    [membershipId, facilityId],
  );
  await logPermissionAudit(user.id, 'permission.suspend', 'facility_membership', membershipId, facilityId, context);
  return { id: membershipId, suspended: true };
}

export async function unsuspendStaffMember(
  user: AuthenticatedUser,
  facilityId: string,
  membershipId: string,
  context?: RequestContext,
) {
  await requireFacilityAdmin(user, facilityId);

  const target = await query<{ user_id: string }>(
    `SELECT user_id FROM public.facility_memberships WHERE id = $1 AND facility_id = $2`,
    [membershipId, facilityId],
  );
  if (!target.rows[0]) throw new NotFoundError('Staff membership', membershipId);

  await query(
    `UPDATE public.facility_memberships SET suspended_at = NULL WHERE id = $1 AND facility_id = $2`,
    [membershipId, facilityId],
  );
  await logPermissionAudit(user.id, 'permission.unsuspend', 'facility_membership', membershipId, facilityId, context);
  return { id: membershipId, suspended: false };
}

// --- Reporting ---

export async function getRevenueReport(user: AuthenticatedUser, facilityId: string, opts: AdminListQuery) {
  await assertFacilityAccess(user, facilityId);
  const params: unknown[] = [facilityId];
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.revenue_reports WHERE tenant_id = $1`,
    params,
  );

  const rows = await query(
    `SELECT report_date, period_type, gross_revenue_cents, net_revenue_cents,
            appointment_count, walk_in_count, payment_count
     FROM public.revenue_reports
     WHERE tenant_id = $1
     ORDER BY report_date DESC
     LIMIT $2 OFFSET $3`,
    [facilityId, opts.limit, offset],
  );

  return {
    reports: rows.rows,
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function getDoctorPerformance(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const rows = await query(
    `SELECT p.id, p.name,
            COUNT(a.id)::int AS appointment_count,
            COUNT(a.id) FILTER (WHERE a.status = 'completed')::int AS completed,
            COUNT(a.id) FILTER (WHERE a.status = 'cancelled')::int AS cancelled,
            COALESCE(AVG(r.rating), 0) AS avg_rating
     FROM public.providers p
     LEFT JOIN public.appointments a ON a.provider_id = p.id
       AND a.tenant_id = $1 AND a.deleted_at IS NULL
       AND a.scheduled_at >= now() - interval '30 days'
     LEFT JOIN public.provider_reviews r ON r.provider_id = p.id
     WHERE p.facility_id = $1 AND p.is_active = true
     GROUP BY p.id, p.name
     ORDER BY appointment_count DESC`,
    [facilityId],
  );
  return { doctors: rows.rows };
}

export async function getAppointmentTrends(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const rows = await query(
    `SELECT date_trunc('day', scheduled_at)::date AS day,
            COUNT(*)::int AS total,
            COUNT(*) FILTER (WHERE status = 'completed')::int AS completed,
            COUNT(*) FILTER (WHERE status = 'cancelled')::int AS cancelled
     FROM public.appointments
     WHERE tenant_id = $1 AND deleted_at IS NULL
       AND scheduled_at >= now() - interval '30 days'
     GROUP BY 1
     ORDER BY 1 ASC`,
    [facilityId],
  );
  return { trends: rows.rows };
}

export async function exportReportsCsv(
  user: AuthenticatedUser,
  facilityId: string,
  type: 'revenue' | 'appointments' | 'doctors',
): Promise<string> {
  await assertFacilityAccess(user, facilityId);

  if (type === 'revenue') {
    const rows = await query(
      `SELECT report_date, period_type, net_revenue_cents, appointment_count
       FROM public.revenue_reports WHERE tenant_id = $1 ORDER BY report_date DESC LIMIT 500`,
      [facilityId],
    );
    const header = 'date,period,net_revenue_cents,appointments\n';
    const body = rows.rows
      .map((r) => `${r.report_date},${r.period_type},${r.net_revenue_cents},${r.appointment_count}`)
      .join('\n');
    return header + body;
  }

  if (type === 'appointments') {
    const { trends } = await getAppointmentTrends(user, facilityId);
    const header = 'day,total,completed,cancelled\n';
    const body = trends
      .map((r) => `${r.day},${r.total},${r.completed},${r.cancelled}`)
      .join('\n');
    return header + body;
  }

  const { doctors } = await getDoctorPerformance(user, facilityId);
  const header = 'doctor,appointments,completed,cancelled,avg_rating\n';
  const body = doctors
    .map((r) => `${r.name},${r.appointment_count},${r.completed},${r.cancelled},${r.avg_rating}`)
    .join('\n');
  return header + body;
}

export async function getAnalytics(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);

  const [trends, performance, usage] = await Promise.all([
    getAppointmentTrends(user, facilityId),
    getDoctorPerformance(user, facilityId),
    query(
      `SELECT metric_key, SUM(metric_value)::numeric AS total
       FROM public.usage_metrics
       WHERE tenant_id = $1 AND metric_date >= (now() - interval '30 days')::date
       GROUP BY metric_key`,
      [facilityId],
    ),
  ]);

  return {
    appointmentTrends: trends.trends,
    doctorPerformance: performance.doctors,
    usageMetrics: usage.rows,
  };
}

async function resolveProviderForUser(userId: string, facilityId: string) {
  const row = await query<{
    id: string;
    name: string;
    mdpcz_number: string | null;
  }>(
    `SELECT p.id, p.name, p.mdpcz_number
     FROM public.providers p
     WHERE p.owner_id = $1 AND p.deleted_at IS NULL
       AND (
         p.facility_id = $2
         OR EXISTS (
           SELECT 1 FROM public.provider_facility_links pfl
           WHERE pfl.provider_id = p.id AND pfl.facility_id = $2
         )
       )
     ORDER BY p.is_claimed DESC NULLS LAST, p.updated_at DESC
     LIMIT 1`,
    [userId, facilityId],
  );
  return row.rows[0] ?? null;
}

export async function listMyCredentials(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const provider = await resolveProviderForUser(user.id, facilityId);
  if (!provider) return { credentials: [] as Record<string, unknown>[] };

  const rows = await query(
    `SELECT id, credential_type, title, issued_at, expires_at, storage_path, created_at
     FROM public.practitioner_credentials
     WHERE provider_id = $1
     ORDER BY expires_at ASC NULLS LAST, title ASC`,
    [provider.id],
  );

  const credentials: Record<string, unknown>[] = rows.rows.map((row) => ({
    id: String(row.id),
    credentialType: String(row.credential_type),
    title: String(row.title),
    issuedAt: row.issued_at ? new Date(String(row.issued_at)).toISOString().slice(0, 10) : null,
    expiresAt: row.expires_at ? new Date(String(row.expires_at)).toISOString().slice(0, 10) : null,
    storagePath: row.storage_path ? String(row.storage_path) : null,
  }));

  if (provider.mdpcz_number) {
    credentials.unshift({
      id: `mdpcz-${provider.id}`,
      credentialType: 'registration',
      title: 'MDPCZ Registration',
      issuedAt: null,
      expiresAt: null,
      registrationNumber: provider.mdpcz_number,
    });
  }

  return { credentials };
}

export async function createPractitionerCredential(
  user: AuthenticatedUser,
  facilityId: string,
  body: {
    credentialType: string;
    title: string;
    issuedAt?: string;
    expiresAt?: string;
  },
) {
  await assertFacilityAccess(user, facilityId);
  const provider = await resolveProviderForUser(user.id, facilityId);
  if (!provider) {
    throw new ValidationError('Link a practitioner profile before adding credentials');
  }
  await assertCanManageProvider(user, facilityId, provider.id);

  const row = await query(
    `INSERT INTO public.practitioner_credentials
       (provider_id, credential_type, title, issued_at, expires_at)
     VALUES ($1, $2, $3, $4::date, $5::date)
     RETURNING id, credential_type, title, issued_at, expires_at, storage_path, created_at`,
    [
      provider.id,
      body.credentialType,
      body.title.trim(),
      body.issuedAt ?? null,
      body.expiresAt ?? null,
    ],
  );
  const inserted = row.rows[0];
  if (!inserted) throw new ValidationError('Could not save credential');

  return {
    credential: {
      id: String(inserted.id),
      credentialType: String(inserted.credential_type),
      title: String(inserted.title),
      issuedAt: inserted.issued_at
        ? new Date(String(inserted.issued_at)).toISOString().slice(0, 10)
        : null,
      expiresAt: inserted.expires_at
        ? new Date(String(inserted.expires_at)).toISOString().slice(0, 10)
        : null,
      storagePath: inserted.storage_path ? String(inserted.storage_path) : null,
    },
  };
}

export async function listInternalMessages(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);
  const rows = await query(
    `SELECT m.id, m.sender_id, m.recipient_id, m.body, m.sent_at, m.read_at,
            COALESCE(NULLIF(TRIM(CONCAT(sp.first_name, ' ', sp.last_name)), ''), sp.email) AS sender_name,
            COALESCE(NULLIF(TRIM(CONCAT(rp.first_name, ' ', rp.last_name)), ''), rp.email) AS recipient_name
     FROM public.internal_messages m
     JOIN public.profiles sp ON sp.id = m.sender_id
     JOIN public.profiles rp ON rp.id = m.recipient_id
     WHERE m.facility_id = $1
       AND (m.sender_id = $2 OR m.recipient_id = $2)
     ORDER BY m.sent_at DESC
     LIMIT 200`,
    [facilityId, user.id],
  );

  return {
    messages: rows.rows.map((row) => ({
      id: String(row.id),
      senderId: String(row.sender_id),
      recipientId: String(row.recipient_id),
      senderName: String(row.sender_name ?? 'Staff'),
      recipientName: String(row.recipient_name ?? 'Staff'),
      body: String(row.body),
      sentAt: new Date(String(row.sent_at)).toISOString(),
      read: row.read_at != null,
    })),
  };
}

export async function sendInternalMessage(
  user: AuthenticatedUser,
  facilityId: string,
  data: { recipientId: string; body: string },
) {
  await assertFacilityAccess(user, facilityId);
  const body = data.body.trim();
  if (!body) throw new ValidationError('Message body is required');

  const recipient = await query(
    `SELECT fm.user_id
     FROM public.facility_memberships fm
     WHERE fm.facility_id = $1 AND fm.user_id = $2`,
    [facilityId, data.recipientId],
  );
  if (!recipient.rows[0]) {
    throw new ValidationError('Recipient must be a staff member at this facility');
  }

  const result = await query(
    `INSERT INTO public.internal_messages (
       tenant_id, facility_id, sender_id, recipient_id, body
     ) VALUES ($1, $1, $2, $3, $4)
     RETURNING id, sender_id, recipient_id, body, sent_at, read_at`,
    [facilityId, user.id, data.recipientId, body],
  );
  const row = result.rows[0]!;
  return {
    message: {
      id: String(row.id),
      senderId: String(row.sender_id),
      recipientId: String(row.recipient_id),
      body: String(row.body),
      sentAt: new Date(String(row.sent_at)).toISOString(),
      read: row.read_at != null,
    },
  };
}

export async function markInternalMessageRead(
  user: AuthenticatedUser,
  facilityId: string,
  messageId: string,
) {
  await assertFacilityAccess(user, facilityId);
  await query(
    `UPDATE public.internal_messages
     SET read_at = timezone('utc', now())
     WHERE id = $1 AND facility_id = $2 AND recipient_id = $3 AND read_at IS NULL`,
    [messageId, facilityId, user.id],
  );
  return { id: messageId };
}
