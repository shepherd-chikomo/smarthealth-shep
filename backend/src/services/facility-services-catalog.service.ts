import { query } from '../lib/db.js';
import { toCatalogSlug } from '../lib/catalog-slug.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { adminOffset, buildSearchClause, type AdminListQuery } from '../lib/admin-query.js';
import { ConflictError, NotFoundError, ValidationError } from '../lib/errors.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { requireFacilityAdmin } from '../lib/facility-access.js';

export type FacilityServiceItem = {
  id: string;
  slug: string;
  label: string;
  iconKey: string;
  isPreset: boolean;
  sortOrder: number;
  isActive: boolean;
};

type Row = Record<string, unknown>;

function mapService(row: Row): FacilityServiceItem {
  return {
    id: String(row.id),
    slug: String(row.slug),
    label: String(row.label),
    iconKey: String(row.icon_key ?? 'custom'),
    isPreset: Boolean(row.is_preset),
    sortOrder: Number(row.sort_order ?? 0),
    isActive: Boolean(row.is_active),
  };
}

function mapPublic(row: Row) {
  return {
    id: String(row.slug),
    label: String(row.label),
    iconKey: String(row.icon_key ?? 'custom'),
  };
}

export async function listFacilityServicesCatalog() {
  const result = await query(
    `SELECT slug, label, icon_key, is_preset
     FROM public.facility_services
     WHERE deleted_at IS NULL AND is_active = true
     ORDER BY is_preset DESC, sort_order ASC, label ASC`,
  );

  const preset: ReturnType<typeof mapPublic>[] = [];
  const other: ReturnType<typeof mapPublic>[] = [];
  for (const row of result.rows) {
    const item = mapPublic(row);
    if (row.is_preset) preset.push(item);
    else other.push(item);
  }
  return { preset, other };
}

export async function suggestFacilityServices(q: string, limit = 8) {
  const trimmed = q.trim();
  if (!trimmed) return { suggestions: [] as ReturnType<typeof mapPublic>[] };

  const slug = toCatalogSlug(trimmed);
  const pattern = `%${trimmed}%`;
  const result = await query(
    `SELECT slug, label, icon_key
     FROM public.facility_services
     WHERE deleted_at IS NULL AND is_active = true
       AND (label ILIKE $1 OR slug ILIKE $1 OR slug = $2)
     ORDER BY
       CASE WHEN slug = $2 THEN 0 WHEN label ILIKE $3 THEN 1 ELSE 2 END,
       sort_order ASC, label ASC
     LIMIT $4`,
    [pattern, slug, `${trimmed}%`, Math.min(Math.max(limit, 1), 20)],
  );
  return { suggestions: result.rows.map(mapPublic) };
}

export async function listServicesAdmin(opts: AdminListQuery) {
  const params: unknown[] = [];
  const search = buildSearchClause(['label', 'slug'], opts.q, params, 1);
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.facility_services
     WHERE deleted_at IS NULL AND ${search.clause}`,
    params,
  );

  const rows = await query(
    `SELECT id, slug, label, icon_key, is_preset, sort_order, is_active
     FROM public.facility_services
     WHERE deleted_at IS NULL AND ${search.clause}
     ORDER BY is_preset DESC, sort_order ASC, label ASC
     LIMIT $${search.nextIdx++} OFFSET $${search.nextIdx}`,
    [...params, opts.limit, offset],
  );

  return {
    services: rows.rows.map(mapService),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function createService(data: {
  label: string;
  iconKey?: string;
  isPreset?: boolean;
  sortOrder?: number;
  isActive?: boolean;
}) {
  const label = data.label.trim();
  if (!label) throw new ValidationError('Label is required');
  const slug = toCatalogSlug(label);
  if (!slug) throw new ValidationError('Label cannot be converted to a valid slug');

  const dup = await query(
    `SELECT id FROM public.facility_services WHERE slug = $1 AND deleted_at IS NULL`,
    [slug],
  );
  if (dup.rows[0]) throw new ConflictError(`Service '${slug}' already exists`);

  const result = await query(
    `INSERT INTO public.facility_services (slug, label, icon_key, is_preset, sort_order, is_active)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id, slug, label, icon_key, is_preset, sort_order, is_active`,
    [slug, label, data.iconKey ?? 'custom', data.isPreset ?? true, data.sortOrder ?? 0, data.isActive ?? true],
  );
  return { service: mapService(result.rows[0]) };
}

export async function updateService(
  id: string,
  data: { label?: string; iconKey?: string; isPreset?: boolean; sortOrder?: number; isActive?: boolean },
) {
  const existing = await query(`SELECT id FROM public.facility_services WHERE id = $1 AND deleted_at IS NULL`, [id]);
  if (!existing.rows[0]) throw new NotFoundError('Facility service', id);

  let slug: string | undefined;
  if (data.label !== undefined) {
    const label = data.label.trim();
    if (!label) throw new ValidationError('Label is required');
    slug = toCatalogSlug(label);
    if (!slug) throw new ValidationError('Label cannot be converted to a valid slug');
    const dup = await query(
      `SELECT id FROM public.facility_services WHERE slug = $1 AND deleted_at IS NULL AND id <> $2`,
      [slug, id],
    );
    if (dup.rows[0]) throw new ConflictError(`Service '${slug}' already exists`);
  }

  const result = await query(
    `UPDATE public.facility_services SET
       slug = COALESCE($2, slug),
       label = COALESCE($3, label),
       icon_key = COALESCE($4, icon_key),
       is_preset = COALESCE($5, is_preset),
       sort_order = COALESCE($6, sort_order),
       is_active = COALESCE($7, is_active),
       updated_at = timezone('utc', now())
     WHERE id = $1
     RETURNING id, slug, label, icon_key, is_preset, sort_order, is_active`,
    [id, slug, data.label?.trim(), data.iconKey, data.isPreset, data.sortOrder, data.isActive],
  );
  return { service: mapService(result.rows[0]) };
}

export async function deleteService(id: string) {
  const result = await query(
    `UPDATE public.facility_services SET deleted_at = timezone('utc', now())
     WHERE id = $1 AND deleted_at IS NULL RETURNING id`,
    [id],
  );
  if (!result.rows[0]) throw new NotFoundError('Facility service', id);
  return { id };
}

function mapSubmission(row: Row) {
  return {
    id: String(row.id),
    facilityId: String(row.facility_id),
    submittedBy: String(row.submitted_by),
    proposedLabel: String(row.proposed_label),
    proposedSlug: String(row.proposed_slug),
    proposedIconKey: String(row.proposed_icon_key ?? 'custom'),
    status: String(row.status),
    reviewedBy: row.reviewed_by ? String(row.reviewed_by) : null,
    reviewedAt: row.reviewed_at ? new Date(String(row.reviewed_at)).toISOString() : null,
    resultingServiceId: row.resulting_service_id ? String(row.resulting_service_id) : null,
    createdAt: new Date(String(row.created_at)).toISOString(),
    facilityName: row.facility_name ? String(row.facility_name) : null,
  };
}

export async function createServiceSubmission(
  user: AuthenticatedUser,
  facilityId: string,
  data: { label: string; iconKey?: string },
) {
  await requireFacilityAdmin(user, facilityId);
  const label = data.label.trim();
  if (!label) throw new ValidationError('Service label is required');
  const slug = toCatalogSlug(label);
  if (!slug) throw new ValidationError('Service label is invalid');

  const existing = await query(
    `SELECT id FROM public.facility_services WHERE slug = $1 AND deleted_at IS NULL AND is_active = true`,
    [slug],
  );
  if (existing.rows[0]) {
    return { submission: null, skipped: true, reason: 'already_in_catalog' as const };
  }

  const pending = await query(
    `SELECT id FROM public.service_submissions
     WHERE facility_id = $1 AND proposed_slug = $2 AND status = 'pending'`,
    [facilityId, slug],
  );
  if (pending.rows[0]) {
    return { submission: mapSubmission(pending.rows[0]), skipped: true, reason: 'already_pending' as const };
  }

  const inserted = await query(
    `INSERT INTO public.service_submissions (
       facility_id, submitted_by, proposed_label, proposed_slug, proposed_icon_key
     ) VALUES ($1, $2, $3, $4, $5)
     RETURNING id, facility_id, submitted_by, proposed_label, proposed_slug, proposed_icon_key,
               status, reviewed_by, reviewed_at, resulting_service_id, created_at`,
    [facilityId, user.id, label, slug, data.iconKey ?? 'custom'],
  );
  return { submission: mapSubmission(inserted.rows[0]), skipped: false, reason: null };
}

export async function listServiceSubmissionsAdmin(opts: AdminListQuery) {
  const params: unknown[] = [];
  let idx = 1;
  let where = 'TRUE';
  if (opts.status) {
    where += ` AND ss.status = $${idx++}::public.condition_submission_status`;
    params.push(opts.status);
  }
  const search = buildSearchClause(
    ['ss.proposed_label', 'ss.proposed_slug', 'f.name'],
    opts.q,
    params,
    idx,
  );
  where += ` AND ${search.clause}`;
  idx = search.nextIdx;
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM public.service_submissions ss
     JOIN public.facilities f ON f.id = ss.facility_id
     WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT ss.id, ss.facility_id, ss.submitted_by, ss.proposed_label, ss.proposed_slug,
            ss.proposed_icon_key, ss.status, ss.reviewed_by, ss.reviewed_at, ss.resulting_service_id,
            ss.created_at, f.name AS facility_name
     FROM public.service_submissions ss
     JOIN public.facilities f ON f.id = ss.facility_id
     WHERE ${where}
     ORDER BY ss.created_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    submissions: rows.rows.map(mapSubmission),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function approveServiceSubmission(id: string, reviewerId: string, data: { isPreset?: boolean }) {
  const submission = await query(
    `SELECT id, proposed_label, proposed_slug, proposed_icon_key, status
     FROM public.service_submissions WHERE id = $1`,
    [id],
  );
  const row = submission.rows[0];
  if (!row) throw new NotFoundError('Service submission', id);
  if (row.status !== 'pending') throw new ConflictError('Submission has already been reviewed');

  const label = String(row.proposed_label);
  const slug = String(row.proposed_slug);
  const iconKey = String(row.proposed_icon_key ?? 'custom');
  const isPreset = data.isPreset ?? false;

  let serviceId: string;
  const existing = await query(
    `SELECT id FROM public.facility_services WHERE slug = $1 AND deleted_at IS NULL`,
    [slug],
  );
  if (existing.rows[0]) {
    serviceId = String(existing.rows[0].id);
    await query(
      `UPDATE public.facility_services SET label = $2, icon_key = $3, is_active = true, updated_at = timezone('utc', now())
       WHERE id = $1`,
      [serviceId, label, iconKey],
    );
  } else {
    const created = await query(
      `INSERT INTO public.facility_services (slug, label, icon_key, is_preset, sort_order, is_active)
       VALUES ($1, $2, $3, $4, 0, true) RETURNING id`,
      [slug, label, iconKey, isPreset],
    );
    serviceId = String(created.rows[0].id);
  }

  const updated = await query(
    `UPDATE public.service_submissions SET status = 'approved', reviewed_by = $2, reviewed_at = timezone('utc', now()),
       resulting_service_id = $3, updated_at = timezone('utc', now())
     WHERE id = $1
     RETURNING id, facility_id, submitted_by, proposed_label, proposed_slug, proposed_icon_key,
               status, reviewed_by, reviewed_at, resulting_service_id, created_at`,
    [id, reviewerId, serviceId],
  );

  const service = await query(
    `SELECT id, slug, label, icon_key, is_preset, sort_order, is_active FROM public.facility_services WHERE id = $1`,
    [serviceId],
  );

  return { submission: mapSubmission(updated.rows[0]), service: mapService(service.rows[0]) };
}

export async function rejectServiceSubmission(id: string, reviewerId: string) {
  const result = await query(
    `UPDATE public.service_submissions SET status = 'rejected', reviewed_by = $2, reviewed_at = timezone('utc', now()),
       updated_at = timezone('utc', now())
     WHERE id = $1 AND status = 'pending'
     RETURNING id, facility_id, submitted_by, proposed_label, proposed_slug, proposed_icon_key,
               status, reviewed_by, reviewed_at, resulting_service_id, created_at`,
    [id, reviewerId],
  );
  if (!result.rows[0]) {
    const exists = await query(`SELECT status FROM public.service_submissions WHERE id = $1`, [id]);
    if (!exists.rows[0]) throw new NotFoundError('Service submission', id);
    throw new ConflictError('Submission has already been reviewed');
  }
  return { submission: mapSubmission(result.rows[0]) };
}
