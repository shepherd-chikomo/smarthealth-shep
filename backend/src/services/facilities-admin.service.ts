import { query, pool } from '../lib/db.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { ForbiddenError, NotFoundError, ValidationError } from '../lib/errors.js';
import { isSuperAdmin } from '../lib/rbac.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { adminOffset, buildSearchClause, type AdminListQuery } from '../lib/admin-query.js';
import { logAdminAudit } from '../lib/audit-log.js';
import type { RequestContext } from '../lib/request-context.js';
import {
  buildFacilityRegistryKey,
  buildFacilityRegistryKeyWithRoleHolder,
  buildFullNameKey,
  buildProviderRegistryKey,
  locationDedupKeyFromRawRows,
  parseHpaRawRow,
} from '../lib/registry-keys.js';
import {
  provinceInsertFallback,
  resolveProvinceFromCity,
} from '../import/province_resolve.js';
import { geocodeFacilityRecord } from '../lib/facility-geocode.js';
import { getGeocodeStatus, isGeocodedUpToDate } from '../lib/geocode-quality.js';
import { upsertImportResolutionRule } from './import-resolution.service.js';

function requireSuperAdmin(user: AuthenticatedUser): void {
  if (!isSuperAdmin(user)) throw new ForbiddenError('Super admin access required');
}

export type FacilityQueueFilter =
  | 'all'
  | 'geocoding'
  | 'ambiguous_facility'
  | 'manual_association'
  | 'unlinked_practitioner'
  | 'no_email_practitioner';

function mapFacility(row: Record<string, unknown>) {
  const latitude = row.latitude != null ? Number(row.latitude) : null;
  const longitude = row.longitude != null ? Number(row.longitude) : null;
  const geocodeQuality =
    row.geocode_quality != null ? String(row.geocode_quality) : null;
  const geocodedAt =
    row.geocoded_at instanceof Date
      ? row.geocoded_at.toISOString()
      : row.geocoded_at
        ? String(row.geocoded_at)
        : null;

  const geoRow = { latitude, longitude, geocode_quality: geocodeQuality };

  return {
    id: row.id,
    name: row.name,
    address: row.address_line1,
    city: row.city,
    province: row.province,
    isVerified: row.is_verified,
    isClaimed: row.is_claimed,
    verificationStatus: row.verification_status,
    importSource: row.import_source,
    primaryRoleHolder: row.primary_role_holder ?? null,
    linkedProviderCount: Number(row.linked_provider_count ?? 0),
    createdAt: row.created_at,
    geocodeQuality,
    geocodedAt,
    isGeocodedUpToDate: isGeocodedUpToDate(geoRow),
    geocodeStatus: getGeocodeStatus(geoRow),
  };
}

export async function listFacilities(
  user: AuthenticatedUser,
  opts: AdminListQuery & { queue?: FacilityQueueFilter },
) {
  requireSuperAdmin(user);
  const params: unknown[] = [];
  let idx = 1;
  const conditions = ['f.deleted_at IS NULL'];

  const search = buildSearchClause(['f.name', 'f.city', 'f.address_line1'], opts.q, params, idx);
  idx = search.nextIdx;
  if (opts.q?.trim()) {
    const pattern = `%${opts.q.trim()}%`;
    conditions.push(`(
      ${search.clause}
      OR EXISTS (
        SELECT 1 FROM public.facility_role_holder_intents frih
        WHERE frih.facility_id = f.id
          AND (frih.practitioner_first_name || ' ' || COALESCE(frih.practitioner_last_name, '')) ILIKE $${idx}
      )
    )`);
    params.push(pattern);
    idx++;
  } else {
    conditions.push(search.clause);
  }

  if (opts.queue === 'geocoding') {
    conditions.push(`(f.address_line1 IS NOT NULL OR f.city IS NOT NULL)`);
    conditions.push(`(
      f.latitude IS NULL OR f.longitude IS NULL
      OR f.geocode_quality IN ('city_only', 'city_centre')
    )`);
  } else if (opts.queue && opts.queue !== 'all') {
    conditions.push(`EXISTS (
      SELECT 1 FROM public.import_review_queue irq
      WHERE irq.status = 'pending' AND irq.queue_type = $${idx}::public.import_queue_type
        AND (irq.facility_id = f.id OR irq.provider_id IN (
          SELECT pfl.provider_id FROM public.provider_facility_links pfl WHERE pfl.facility_id = f.id
        ))
    )`);
    params.push(opts.queue);
    idx++;
  }

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.facilities f WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT f.id, f.name, f.address_line1, f.city, f.province::text AS province,
            f.is_verified, f.is_claimed, f.verification_status, f.import_source, f.created_at,
            f.latitude, f.longitude, f.geocode_quality, f.geocoded_at,
            (SELECT COUNT(*)::int FROM public.provider_facility_links pfl WHERE pfl.facility_id = f.id) AS linked_provider_count,
            (SELECT frih.practitioner_first_name || ' ' || COALESCE(frih.practitioner_last_name, '')
             FROM public.facility_role_holder_intents frih WHERE frih.facility_id = f.id LIMIT 1) AS primary_role_holder
     FROM public.facilities f
     WHERE ${where}
     ORDER BY f.name ASC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    facilities: rows.rows.map(mapFacility),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

const FACILITY_ADMIN_SELECT = `
  f.id, f.name, f.address_line1, f.city, f.province::text AS province,
  f.is_verified, f.is_claimed, f.verification_status, f.import_source, f.created_at,
  f.latitude, f.longitude, f.geocode_quality, f.geocoded_at,
  (SELECT COUNT(*)::int FROM public.provider_facility_links pfl WHERE pfl.facility_id = f.id) AS linked_provider_count,
  (SELECT frih.practitioner_first_name || ' ' || COALESCE(frih.practitioner_last_name, '')
   FROM public.facility_role_holder_intents frih WHERE frih.facility_id = f.id LIMIT 1) AS primary_role_holder
`;

export async function geocodeFacility(
  user: AuthenticatedUser,
  facilityId: string,
  ctx: RequestContext,
) {
  requireSuperAdmin(user);

  const existing = await query<{
    id: string;
    name: string;
    address_line1: string | null;
    city: string | null;
    province: string | null;
  }>(
    `SELECT id, name, address_line1, city, province::text AS province
     FROM public.facilities
     WHERE id = $1 AND deleted_at IS NULL`,
    [facilityId],
  );
  if (!existing.rows[0]) throw new NotFoundError('Facility', facilityId);

  const row = existing.rows[0];
  const geocodeResult = await geocodeFacilityRecord({
    facilityId,
    name: row.name,
    addressLine1: row.address_line1,
    city: row.city,
    province: row.province,
    clearOnFailure: false,
  });

  const updated = await query(
    `SELECT ${FACILITY_ADMIN_SELECT}
     FROM public.facilities f
     WHERE f.id = $1`,
    [facilityId],
  );

  await logAdminAudit(user.id, 'admin.facility.geocode', 'facility', facilityId, ctx, {
    geocoded: geocodeResult.geocoded,
    quality: geocodeResult.quality ?? null,
  });

  return {
    geocoded: geocodeResult.geocoded,
    facility: mapFacility(updated.rows[0]),
  };
}

export async function updateFacilityAddress(
  user: AuthenticatedUser,
  facilityId: string,
  data: { name?: string; address?: string; city?: string },
  ctx: RequestContext,
) {
  requireSuperAdmin(user);

  const hasName = data.name !== undefined && data.name.trim().length > 0;
  const hasAddress = data.address !== undefined;
  const hasCity = data.city !== undefined;
  if (!hasName && !hasAddress && !hasCity) {
    throw new ValidationError('At least one of name, address, or city is required');
  }

  const existing = await query<{
    name: string;
    address_line1: string | null;
    city: string | null;
    province: string | null;
  }>(
    `SELECT name, address_line1, city, province::text AS province
     FROM public.facilities
     WHERE id = $1 AND deleted_at IS NULL`,
    [facilityId],
  );
  if (!existing.rows[0]) throw new NotFoundError('Facility', facilityId);

  const prior = existing.rows[0];
  const nextName = hasName ? data.name!.trim() : prior.name;
  const nextAddress = hasAddress ? (data.address!.trim() || null) : prior.address_line1;
  const nextCity = hasCity ? (data.city!.trim() || null) : prior.city;
  const addressChanged =
    nextAddress !== prior.address_line1 || nextCity !== prior.city;
  const resolved = await resolveProvinceFromCity(pool, nextCity);
  const province = resolved ?? prior.province ?? provinceInsertFallback(nextCity);

  await query(
    `UPDATE public.facilities SET
       name = $2,
       address_line1 = $3,
       city = $4,
       province = $5::public.zimbabwe_province,
       updated_at = timezone('utc', now())
     WHERE id = $1`,
    [facilityId, nextName, nextAddress, nextCity, province],
  );

  if (addressChanged) {
    await geocodeFacilityRecord({
      facilityId,
      name: nextName,
      addressLine1: nextAddress,
      city: nextCity,
      province,
      clearOnFailure: true,
    });
  }

  const updated = await query(
    `SELECT ${FACILITY_ADMIN_SELECT}
     FROM public.facilities f
     WHERE f.id = $1`,
    [facilityId],
  );

  await logAdminAudit(user.id, 'admin.facility.update_address', 'facility', facilityId, ctx, {
    addressChanged,
  });

  return { facility: mapFacility(updated.rows[0]) };
}

export async function listImportReviewQueue(
  user: AuthenticatedUser,
  opts: AdminListQuery & { queueType?: FacilityQueueFilter },
) {
  requireSuperAdmin(user);
  const params: unknown[] = [];
  let idx = 1;
  const conditions = ["irq.status = 'pending'"];

  if (opts.queueType && opts.queueType !== 'all') {
    conditions.push(`irq.queue_type = $${idx++}::public.import_queue_type`);
    params.push(opts.queueType);
  }

  const search = buildSearchClause(
    ['f.name', 'f.city', 'p.name', 'p.registration_number', 'irq.notes'],
    opts.q,
    params,
    idx,
  );
  idx = search.nextIdx;
  conditions.push(search.clause);

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);
  const fromClause = `
     FROM public.import_review_queue irq
     LEFT JOIN public.facilities f ON f.id = irq.facility_id
     LEFT JOIN public.providers p ON p.id = irq.provider_id`;

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count${fromClause} WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT irq.id, irq.queue_type, irq.facility_id, irq.provider_id, irq.row_number,
            irq.raw_data, irq.notes, irq.created_at,
            f.name AS facility_name, f.city AS facility_city,
            p.name AS provider_name, p.registration_number
     ${fromClause}
     WHERE ${where}
     ORDER BY irq.created_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    items: rows.rows.map((r) => ({
      id: r.id,
      queueType: r.queue_type,
      facilityId: r.facility_id,
      facilityName: r.facility_name,
      facilityCity: r.facility_city,
      providerId: r.provider_id,
      providerName: r.provider_name,
      registrationNumber: r.registration_number,
      rowNumber: r.row_number,
      rawData: r.raw_data,
      notes: r.notes,
      createdAt: (r.created_at as Date).toISOString(),
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

function mapQueueItem(row: Record<string, unknown>) {
  return {
    id: row.id,
    queueType: row.queue_type,
    facilityId: row.facility_id,
    facilityName: row.facility_name,
    facilityCity: row.facility_city,
    providerId: row.provider_id,
    providerName: row.provider_name,
    registrationNumber: row.registration_number,
    rowNumber: row.row_number,
    rawData: row.raw_data,
    notes: row.notes,
    createdAt: row.created_at ? (row.created_at as Date).toISOString() : null,
  };
}

export async function getImportReviewQueueItem(user: AuthenticatedUser, id: string) {
  requireSuperAdmin(user);
  const rows = await query(
    `SELECT irq.id, irq.queue_type, irq.facility_id, irq.provider_id, irq.row_number,
            irq.raw_data, irq.notes, irq.created_at, irq.status,
            f.name AS facility_name, f.city AS facility_city,
            p.name AS provider_name, p.registration_number, p.email AS provider_email
     FROM public.import_review_queue irq
     LEFT JOIN public.facilities f ON f.id = irq.facility_id
     LEFT JOIN public.providers p ON p.id = irq.provider_id
     WHERE irq.id = $1`,
    [id],
  );
  if (!rows.rows[0]) throw new NotFoundError('Queue item', id);
  return { item: mapQueueItem(rows.rows[0]) };
}

async function resolveQueueItem(queueItemId: string, userId: string, notes: string, facilityId?: string) {
  await query(
    `UPDATE public.import_review_queue SET
       status = 'resolved',
       resolved_at = timezone('utc', now()),
       resolved_by = $2,
       resolution_notes = $3,
       facility_id = COALESCE($4, facility_id)
     WHERE id = $1`,
    [queueItemId, userId, notes, facilityId ?? null],
  );
}

async function upsertFacilityFromFields(opts: {
  facilityName: string;
  address: string;
  city: string | null;
  registryKey: string;
  practitionerFirstName?: string | null;
  practitionerLastName?: string | null;
  normalizedNameKey?: string;
}): Promise<string> {
  const slug = opts.facilityName.toLowerCase().replace(/[^a-z0-9]+/g, '-').slice(0, 80);
  const province =
    (await resolveProvinceFromCity(pool, opts.city)) ?? provinceInsertFallback(opts.city);
  const insert = await query<{ id: string }>(
    `INSERT INTO public.facilities (
       name, slug, facility_type, address_line1, city, province,
       is_verified, is_claimed, verification_status, import_source, registry_key
     ) VALUES (
       $1, $2, 'clinic', $3, $4, $5::public.zimbabwe_province,
       false, false, 'draft', 'HPA', $6
     )
     ON CONFLICT (registry_key) WHERE registry_key IS NOT NULL AND deleted_at IS NULL
     DO UPDATE SET
       name = EXCLUDED.name,
       address_line1 = EXCLUDED.address_line1,
       city = EXCLUDED.city,
       province = EXCLUDED.province
     RETURNING id`,
    [opts.facilityName, slug, opts.address, opts.city, province, opts.registryKey],
  );
  const facilityId = insert.rows[0].id;

  await geocodeFacilityRecord({
    facilityId,
    name: opts.facilityName,
    addressLine1: opts.address,
    city: opts.city,
    province,
  });
  const nameKey = opts.normalizedNameKey ?? buildFullNameKey(
    opts.practitionerFirstName ?? null,
    opts.practitionerLastName ?? null,
  );
  if (nameKey) {
    await query(
      `INSERT INTO public.facility_role_holder_intents (
         facility_id, practitioner_first_name, practitioner_last_name, normalized_full_name
       ) VALUES ($1, $2, $3, $4)
       ON CONFLICT (facility_id) DO UPDATE SET
         practitioner_first_name = EXCLUDED.practitioner_first_name,
         practitioner_last_name = EXCLUDED.practitioner_last_name,
         normalized_full_name = EXCLUDED.normalized_full_name`,
      [facilityId, opts.practitionerFirstName ?? null, opts.practitionerLastName ?? null, nameKey],
    );
  }
  return facilityId;
}

export async function associatePractitionerWithFacility(
  user: AuthenticatedUser,
  data: { facilityId: string; providerId: string; queueItemId?: string },
  ctx: RequestContext,
) {
  requireSuperAdmin(user);

  const facility = await query(`SELECT id FROM public.facilities WHERE id = $1 AND deleted_at IS NULL`, [
    data.facilityId,
  ]);
  if (!facility.rows[0]) throw new NotFoundError('Facility', data.facilityId);

  const provider = await query(`SELECT id FROM public.providers WHERE id = $1 AND deleted_at IS NULL`, [
    data.providerId,
  ]);
  if (!provider.rows[0]) throw new NotFoundError('Provider', data.providerId);

  await query(
    `INSERT INTO public.provider_facility_links (
       provider_id, facility_id, link_type, is_primary, is_facility_role_holder, match_confidence
     ) VALUES ($1, $2, 'primary', true, true, 'HIGH')
     ON CONFLICT (provider_id, facility_id) DO UPDATE SET
       link_type = 'primary', is_facility_role_holder = true, is_primary = true`,
    [data.providerId, data.facilityId],
  );

  await query(
    `UPDATE public.providers SET
       facility_id = COALESCE(facility_id, $2),
       tenant_id = COALESCE(tenant_id, $2)
     WHERE id = $1`,
    [data.providerId, data.facilityId],
  );

  if (data.queueItemId) {
    await resolveQueueItem(data.queueItemId, user.id, 'Manual association by admin', data.facilityId);
  }

  const intent = await query<{ normalized_full_name: string | null }>(
    `SELECT normalized_full_name FROM public.facility_role_holder_intents WHERE facility_id = $1 LIMIT 1`,
    [data.facilityId],
  );
  if (intent.rows[0]?.normalized_full_name) {
    await upsertImportResolutionRule({
      resolutionType: 'practitioner_facility_link',
      stableKey: intent.rows[0].normalized_full_name,
      facilityId: data.facilityId,
      providerId: data.providerId,
      payload: { providerId: data.providerId, facilityId: data.facilityId },
      sourceQueueId: data.queueItemId ?? null,
      createdBy: user.id,
    });
  }

  const providerReg = await query<{ registration_number: string | null; registry_key: string | null }>(
    `SELECT registration_number, registry_key FROM public.providers WHERE id = $1`,
    [data.providerId],
  );
  const regKey = providerReg.rows[0]?.registry_key
    ?? (providerReg.rows[0]?.registration_number
      ? buildProviderRegistryKey(providerReg.rows[0].registration_number)
      : null);
  if (regKey) {
    await upsertImportResolutionRule({
      resolutionType: 'practitioner_facility_link',
      stableKey: regKey,
      facilityId: data.facilityId,
      providerId: data.providerId,
      payload: { providerId: data.providerId, facilityId: data.facilityId },
      sourceQueueId: data.queueItemId ?? null,
      createdBy: user.id,
    });
  }

  await logAdminAudit(user.id, 'admin.facility.associate_practitioner', 'facility', data.facilityId, ctx, {
    providerId: data.providerId,
  });

  return { facilityId: data.facilityId, providerId: data.providerId };
}

export async function resolveAmbiguousFacility(
  user: AuthenticatedUser,
  queueItemId: string,
  data: {
    mode: 'merged' | 'distinct';
    facilityName?: string;
    address?: string;
    city?: string;
    practitionerFirstName?: string;
    practitionerLastName?: string;
  },
  ctx: RequestContext,
) {
  requireSuperAdmin(user);

  const item = await query<{ raw_data: unknown }>(
    `SELECT raw_data FROM public.import_review_queue
     WHERE id = $1 AND queue_type = 'ambiguous_facility' AND status = 'pending'`,
    [queueItemId],
  );
  if (!item.rows[0]) throw new NotFoundError('Queue item', queueItemId);

  const rawRows = Array.isArray(item.rows[0].raw_data)
    ? (item.rows[0].raw_data as Record<string, unknown>[])
    : [];
  const locationKey = locationDedupKeyFromRawRows(rawRows);
  if (!locationKey) throw new ValidationError('Queue item has no valid raw facility rows');

  if (data.mode === 'merged') {
    if (!data.facilityName?.trim() || !data.address?.trim()) {
      throw new ValidationError('facilityName and address are required for merged resolution');
    }
    const registryKey = buildFacilityRegistryKey(data.facilityName, data.address, data.city ?? null);
    const facilityId = await upsertFacilityFromFields({
      facilityName: data.facilityName.trim(),
      address: data.address.trim(),
      city: data.city?.trim() ?? null,
      registryKey,
      practitionerFirstName: data.practitionerFirstName ?? null,
      practitionerLastName: data.practitionerLastName ?? null,
    });

    await upsertImportResolutionRule({
      resolutionType: 'ambiguous_merged',
      stableKey: locationKey,
      facilityId,
      payload: {
        facilityName: data.facilityName,
        address: data.address,
        city: data.city ?? null,
        practitionerFirstName: data.practitionerFirstName ?? null,
        practitionerLastName: data.practitionerLastName ?? null,
        registryKey,
      },
      sourceQueueId: queueItemId,
      createdBy: user.id,
    });

    await resolveQueueItem(queueItemId, user.id, 'Ambiguous facility merged by admin', facilityId);
    await logAdminAudit(user.id, 'admin.facility.resolve_ambiguous', 'facility', facilityId, ctx, { mode: 'merged' });
    return { mode: 'merged' as const, facilityId, facilityIds: [facilityId] };
  }

  const facilityIds: string[] = [];
  for (const raw of rawRows) {
    const parsed = parseHpaRawRow(raw);
    if (!parsed.facilityName || !parsed.address) continue;
    const registryKey = buildFacilityRegistryKeyWithRoleHolder(
      parsed.facilityName,
      parsed.address,
      parsed.city,
      parsed.normalizedNameKey || 'unknown',
    );
    const facilityId = await upsertFacilityFromFields({
      facilityName: parsed.facilityName,
      address: parsed.address,
      city: parsed.city,
      registryKey,
      practitionerFirstName: parsed.practitionerFirstName,
      practitionerLastName: parsed.practitionerLastName,
      normalizedNameKey: parsed.normalizedNameKey,
    });
    facilityIds.push(facilityId);
  }

  await upsertImportResolutionRule({
    resolutionType: 'ambiguous_distinct',
    stableKey: locationKey,
    payload: { distinct: true, facilityIds },
    sourceQueueId: queueItemId,
    createdBy: user.id,
  });

  await resolveQueueItem(
    queueItemId,
    user.id,
    `Ambiguous facility accepted as ${facilityIds.length} distinct site(s)`,
    facilityIds[0],
  );
  await logAdminAudit(user.id, 'admin.facility.resolve_ambiguous', 'facility', facilityIds[0], ctx, {
    mode: 'distinct',
    count: facilityIds.length,
  });
  return { mode: 'distinct' as const, facilityIds };
}

export async function resolveUnlinkedPractitioner(
  user: AuthenticatedUser,
  queueItemId: string,
  data: { action: 'associate' | 'no_link'; facilityId?: string; reason?: string },
  ctx: RequestContext,
) {
  requireSuperAdmin(user);
  const item = await query<{ provider_id: string; registration_number: string | null; registry_key: string | null }>(
    `SELECT irq.provider_id, p.registration_number, p.registry_key
     FROM public.import_review_queue irq
     JOIN public.providers p ON p.id = irq.provider_id
     WHERE irq.id = $1 AND irq.queue_type = 'unlinked_practitioner' AND irq.status = 'pending'`,
    [queueItemId],
  );
  if (!item.rows[0]?.provider_id) throw new NotFoundError('Queue item', queueItemId);

  const providerId = item.rows[0].provider_id;
  const stableKey = item.rows[0].registry_key
    ?? (item.rows[0].registration_number
      ? buildProviderRegistryKey(item.rows[0].registration_number)
      : providerId);

  if (data.action === 'associate') {
    if (!data.facilityId) throw new ValidationError('facilityId is required');
    await associatePractitionerWithFacility(
      user,
      { facilityId: data.facilityId, providerId, queueItemId },
      ctx,
    );
    return { action: 'associate' as const, facilityId: data.facilityId, providerId };
  }

  await upsertImportResolutionRule({
    resolutionType: 'practitioner_no_link',
    stableKey,
    providerId,
    payload: { reason: data.reason ?? null },
    sourceQueueId: queueItemId,
    createdBy: user.id,
  });
  await resolveQueueItem(queueItemId, user.id, data.reason ?? 'No facility link expected');
  await logAdminAudit(user.id, 'admin.import.resolve_unlinked', 'provider', providerId, ctx);
  return { action: 'no_link' as const, providerId };
}

export async function resolveNoEmailPractitioner(
  user: AuthenticatedUser,
  queueItemId: string,
  data: { action: 'set_email' | 'manual_claim_only'; email?: string; notes?: string },
  ctx: RequestContext,
) {
  requireSuperAdmin(user);
  const item = await query<{ provider_id: string; registration_number: string | null; registry_key: string | null }>(
    `SELECT irq.provider_id, p.registration_number, p.registry_key
     FROM public.import_review_queue irq
     JOIN public.providers p ON p.id = irq.provider_id
     WHERE irq.id = $1 AND irq.queue_type = 'no_email_practitioner' AND irq.status = 'pending'`,
    [queueItemId],
  );
  if (!item.rows[0]?.provider_id) throw new NotFoundError('Queue item', queueItemId);

  const providerId = item.rows[0].provider_id;
  const stableKey = item.rows[0].registry_key
    ?? (item.rows[0].registration_number
      ? buildProviderRegistryKey(item.rows[0].registration_number)
      : providerId);

  if (data.action === 'set_email') {
    if (!data.email?.trim()) throw new ValidationError('email is required');
    const email = data.email.trim().toLowerCase();
    await query(`UPDATE public.providers SET email = $2 WHERE id = $1`, [providerId, email]);
    await upsertImportResolutionRule({
      resolutionType: 'provider_email_override',
      stableKey,
      providerId,
      payload: { email },
      sourceQueueId: queueItemId,
      createdBy: user.id,
    });
    await resolveQueueItem(queueItemId, user.id, `Email set to ${email}`);
  } else {
    await upsertImportResolutionRule({
      resolutionType: 'provider_manual_claim_allowed',
      stableKey,
      providerId,
      payload: { notes: data.notes ?? null },
      sourceQueueId: queueItemId,
      createdBy: user.id,
    });
    await resolveQueueItem(queueItemId, user.id, data.notes ?? 'Manual claim allowed without email');
  }

  await logAdminAudit(user.id, 'admin.import.resolve_no_email', 'provider', providerId, ctx, data);
  return { providerId, action: data.action };
}

export async function searchFacilitiesForAssociation(
  user: AuthenticatedUser,
  opts: AdminListQuery,
) {
  requireSuperAdmin(user);
  const params: unknown[] = [];
  const search = buildSearchClause(['f.name', 'f.city', 'f.address_line1'], opts.q, params, 1);
  const offset = adminOffset(opts.page, opts.limit);

  const rows = await query(
    `SELECT f.id, f.name, f.city, f.address_line1
     FROM public.facilities f
     WHERE f.deleted_at IS NULL AND ${search.clause}
     ORDER BY f.name ASC
     LIMIT $${search.nextIdx++} OFFSET $${search.nextIdx}`,
    [...params, opts.limit, offset],
  );

  return {
    facilities: rows.rows.map((r) => ({
      id: r.id,
      name: r.name,
      city: r.city,
      address: r.address_line1,
    })),
  };
}

export async function searchProvidersForAssociation(
  user: AuthenticatedUser,
  opts: AdminListQuery,
) {
  requireSuperAdmin(user);
  const params: unknown[] = [];
  const search = buildSearchClause(
    ['p.name', 'p.registration_number', 'p.first_name', 'p.last_name'],
    opts.q,
    params,
    1,
  );
  const offset = adminOffset(opts.page, opts.limit);

  const rows = await query(
    `SELECT p.id, p.name, p.registration_number, p.specialty, p.email, p.is_verified
     FROM public.providers p
     WHERE p.deleted_at IS NULL AND ${search.clause}
     ORDER BY p.name ASC
     LIMIT $${search.nextIdx++} OFFSET $${search.nextIdx}`,
    [...params, opts.limit, offset],
  );

  return {
    providers: rows.rows.map((r) => ({
      id: r.id,
      name: r.name,
      registrationNumber: r.registration_number,
      specialty: r.specialty,
      email: r.email,
      isVerified: r.is_verified,
    })),
  };
}
