import { query } from '../lib/db.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { ConflictError, ForbiddenError, NotFoundError } from '../lib/errors.js';
import { isSuperAdmin } from '../lib/rbac.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { adminOffset, buildSearchClause, type AdminListQuery } from '../lib/admin-query.js';
import { logAdminAudit } from '../lib/audit-log.js';
import type { RequestContext } from '../lib/request-context.js';

function requireSuperAdmin(user: AuthenticatedUser): void {
  if (!isSuperAdmin(user)) throw new ForbiddenError('Super admin access required');
}

export type FacilityQueueFilter =
  | 'all'
  | 'ambiguous_facility'
  | 'manual_association'
  | 'unlinked_practitioner'
  | 'no_email_practitioner';

function mapFacility(row: Record<string, unknown>) {
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
  conditions.push(search.clause);

  if (opts.queue && opts.queue !== 'all') {
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

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.import_review_queue irq WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT irq.id, irq.queue_type, irq.facility_id, irq.provider_id, irq.row_number,
            irq.raw_data, irq.notes, irq.created_at,
            f.name AS facility_name, f.city AS facility_city,
            p.name AS provider_name, p.registration_number
     FROM public.import_review_queue irq
     LEFT JOIN public.facilities f ON f.id = irq.facility_id
     LEFT JOIN public.providers p ON p.id = irq.provider_id
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
      createdAt: r.created_at,
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
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
    await query(
      `UPDATE public.import_review_queue SET
         status = 'resolved', resolved_at = timezone('utc', now()), resolved_by = $2,
         resolution_notes = 'Manual association by admin'
       WHERE id = $1`,
      [data.queueItemId, user.id],
    );
  }

  await logAdminAudit(user.id, 'admin.facility.associate_practitioner', 'facility', data.facilityId, ctx, {
    providerId: data.providerId,
  });

  return { facilityId: data.facilityId, providerId: data.providerId };
}

export async function resolveAmbiguousFacility(
  user: AuthenticatedUser,
  queueItemId: string,
  data: { facilityName: string; address: string; city?: string; practitionerFirstName?: string; practitionerLastName?: string },
  ctx: RequestContext,
) {
  requireSuperAdmin(user);

  const item = await query(
    `SELECT * FROM public.import_review_queue WHERE id = $1 AND queue_type = 'ambiguous_facility'`,
    [queueItemId],
  );
  if (!item.rows[0]) throw new NotFoundError('Queue item', queueItemId);

  const insert = await query<{ id: string }>(
    `INSERT INTO public.facilities (
       name, slug, facility_type, address_line1, city, verification_status, import_source
     ) VALUES ($1, $2, 'clinic', $3, $4, 'draft', 'HPA')
     RETURNING id`,
    [
      data.facilityName,
      data.facilityName.toLowerCase().replace(/\s+/g, '-').slice(0, 80),
      data.address,
      data.city ?? null,
    ],
  );

  const facilityId = insert.rows[0].id;

  if (data.practitionerFirstName) {
    const fullName = [data.practitionerFirstName, data.practitionerLastName].filter(Boolean).join(' ').toLowerCase();
    await query(
      `INSERT INTO public.facility_role_holder_intents (
         facility_id, practitioner_first_name, practitioner_last_name, normalized_full_name
       ) VALUES ($1, $2, $3, $4)`,
      [facilityId, data.practitionerFirstName, data.practitionerLastName ?? null, fullName],
    );
  }

  await query(
    `UPDATE public.import_review_queue SET status = 'resolved', resolved_at = timezone('utc', now()),
       resolved_by = $2, resolution_notes = $3, facility_id = $4
     WHERE id = $1`,
    [queueItemId, user.id, 'Resolved ambiguous facility manually', facilityId],
  );

  await logAdminAudit(user.id, 'admin.facility.resolve_ambiguous', 'facility', facilityId, ctx);
  return { facilityId };
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
