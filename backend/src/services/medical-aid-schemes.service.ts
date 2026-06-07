import { query } from '../lib/db.js';
import { toCatalogSlug } from '../lib/catalog-slug.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { adminOffset, buildSearchClause, type AdminListQuery } from '../lib/admin-query.js';
import { ConflictError, NotFoundError, ValidationError } from '../lib/errors.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { requireFacilityAdmin } from '../lib/facility-access.js';

export type MedicalAidSchemeItem = {
  id: string;
  schemeKey: string;
  name: string;
  logoPath: string | null;
  sortOrder: number;
  isActive: boolean;
};

type Row = Record<string, unknown>;

function mapScheme(row: Row): MedicalAidSchemeItem {
  return {
    id: String(row.id),
    schemeKey: String(row.scheme_key),
    name: String(row.name),
    logoPath: row.logo_path ? String(row.logo_path) : null,
    sortOrder: Number(row.sort_order ?? 0),
    isActive: Boolean(row.is_active),
  };
}

export async function listMedicalAidSchemesCatalog() {
  const result = await query(
    `SELECT scheme_key, name, logo_path
     FROM public.medical_aid_schemes
     WHERE deleted_at IS NULL AND is_active = true
     ORDER BY sort_order ASC, name ASC`,
  );
  return {
    schemes: result.rows.map((row) => ({
      schemeKey: String(row.scheme_key),
      name: String(row.name),
      logoPath: row.logo_path ? String(row.logo_path) : undefined,
    })),
  };
}

export async function suggestMedicalAidSchemes(q: string, limit = 8) {
  const trimmed = q.trim();
  if (!trimmed) return { suggestions: [] as { schemeKey: string; name: string }[] };

  const key = toCatalogSlug(trimmed).replace(/-/g, '_');
  const pattern = `%${trimmed}%`;
  const result = await query(
    `SELECT scheme_key, name
     FROM public.medical_aid_schemes
     WHERE deleted_at IS NULL AND is_active = true
       AND (name ILIKE $1 OR scheme_key ILIKE $1 OR scheme_key = $2)
     ORDER BY sort_order ASC, name ASC
     LIMIT $3`,
    [pattern, key, Math.min(Math.max(limit, 1), 20)],
  );
  return {
    suggestions: result.rows.map((row) => ({
      schemeKey: String(row.scheme_key),
      name: String(row.name),
    })),
  };
}

export async function listSchemesAdmin(opts: AdminListQuery) {
  const params: unknown[] = [];
  const search = buildSearchClause(['name', 'scheme_key'], opts.q, params, 1);
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.medical_aid_schemes
     WHERE deleted_at IS NULL AND ${search.clause}`,
    params,
  );

  const rows = await query(
    `SELECT id, scheme_key, name, logo_path, sort_order, is_active
     FROM public.medical_aid_schemes
     WHERE deleted_at IS NULL AND ${search.clause}
     ORDER BY sort_order ASC, name ASC
     LIMIT $${search.nextIdx++} OFFSET $${search.nextIdx}`,
    [...params, opts.limit, offset],
  );

  return {
    schemes: rows.rows.map(mapScheme),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function createScheme(data: {
  name: string;
  schemeKey?: string;
  logoPath?: string;
  sortOrder?: number;
  isActive?: boolean;
}) {
  const name = data.name.trim();
  if (!name) throw new ValidationError('Name is required');
  const schemeKey = (data.schemeKey ?? toCatalogSlug(name).replace(/-/g, '_')).trim();
  if (!schemeKey) throw new ValidationError('Scheme key is invalid');

  const dup = await query(
    `SELECT id FROM public.medical_aid_schemes WHERE scheme_key = $1 AND deleted_at IS NULL`,
    [schemeKey],
  );
  if (dup.rows[0]) throw new ConflictError(`Medical aid '${schemeKey}' already exists`);

  const result = await query(
    `INSERT INTO public.medical_aid_schemes (scheme_key, name, logo_path, sort_order, is_active)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, scheme_key, name, logo_path, sort_order, is_active`,
    [schemeKey, name, data.logoPath ?? null, data.sortOrder ?? 0, data.isActive ?? true],
  );
  return { scheme: mapScheme(result.rows[0]) };
}

export async function updateScheme(
  id: string,
  data: { name?: string; schemeKey?: string; logoPath?: string | null; sortOrder?: number; isActive?: boolean },
) {
  const existing = await query(`SELECT id FROM public.medical_aid_schemes WHERE id = $1 AND deleted_at IS NULL`, [id]);
  if (!existing.rows[0]) throw new NotFoundError('Medical aid scheme', id);

  if (data.schemeKey) {
    const dup = await query(
      `SELECT id FROM public.medical_aid_schemes WHERE scheme_key = $1 AND deleted_at IS NULL AND id <> $2`,
      [data.schemeKey, id],
    );
    if (dup.rows[0]) throw new ConflictError(`Medical aid '${data.schemeKey}' already exists`);
  }

  const result = await query(
    `UPDATE public.medical_aid_schemes SET
       scheme_key = COALESCE($2, scheme_key),
       name = COALESCE($3, name),
       logo_path = COALESCE($4, logo_path),
       sort_order = COALESCE($5, sort_order),
       is_active = COALESCE($6, is_active),
       updated_at = timezone('utc', now())
     WHERE id = $1
     RETURNING id, scheme_key, name, logo_path, sort_order, is_active`,
    [id, data.schemeKey, data.name?.trim(), data.logoPath, data.sortOrder, data.isActive],
  );
  return { scheme: mapScheme(result.rows[0]) };
}

export async function deleteScheme(id: string) {
  const result = await query(
    `UPDATE public.medical_aid_schemes SET deleted_at = timezone('utc', now())
     WHERE id = $1 AND deleted_at IS NULL RETURNING id`,
    [id],
  );
  if (!result.rows[0]) throw new NotFoundError('Medical aid scheme', id);
  return { id };
}

function mapSubmission(row: Row) {
  return {
    id: String(row.id),
    facilityId: String(row.facility_id),
    submittedBy: String(row.submitted_by),
    proposedName: String(row.proposed_name),
    proposedSchemeKey: String(row.proposed_scheme_key),
    status: String(row.status),
    reviewedBy: row.reviewed_by ? String(row.reviewed_by) : null,
    reviewedAt: row.reviewed_at ? new Date(String(row.reviewed_at)).toISOString() : null,
    resultingSchemeId: row.resulting_scheme_id ? String(row.resulting_scheme_id) : null,
    createdAt: new Date(String(row.created_at)).toISOString(),
    facilityName: row.facility_name ? String(row.facility_name) : null,
  };
}

export async function createMedicalAidSubmission(
  user: AuthenticatedUser,
  facilityId: string,
  data: { name: string },
) {
  await requireFacilityAdmin(user, facilityId);
  const name = data.name.trim();
  if (!name) throw new ValidationError('Medical aid name is required');
  const schemeKey = toCatalogSlug(name).replace(/-/g, '_');
  if (!schemeKey) throw new ValidationError('Medical aid name is invalid');

  const existing = await query(
    `SELECT id FROM public.medical_aid_schemes WHERE scheme_key = $1 AND deleted_at IS NULL AND is_active = true`,
    [schemeKey],
  );
  if (existing.rows[0]) {
    return { submission: null, skipped: true, reason: 'already_in_catalog' as const };
  }

  const pending = await query(
    `SELECT id FROM public.medical_aid_submissions
     WHERE facility_id = $1 AND proposed_scheme_key = $2 AND status = 'pending'`,
    [facilityId, schemeKey],
  );
  if (pending.rows[0]) {
    return { submission: mapSubmission(pending.rows[0]), skipped: true, reason: 'already_pending' as const };
  }

  const inserted = await query(
    `INSERT INTO public.medical_aid_submissions (facility_id, submitted_by, proposed_name, proposed_scheme_key)
     VALUES ($1, $2, $3, $4)
     RETURNING id, facility_id, submitted_by, proposed_name, proposed_scheme_key,
               status, reviewed_by, reviewed_at, resulting_scheme_id, created_at`,
    [facilityId, user.id, name, schemeKey],
  );
  return { submission: mapSubmission(inserted.rows[0]), skipped: false, reason: null };
}

export async function listMedicalAidSubmissionsAdmin(opts: AdminListQuery) {
  const params: unknown[] = [];
  let idx = 1;
  let where = 'TRUE';
  if (opts.status) {
    where += ` AND ms.status = $${idx++}::public.condition_submission_status`;
    params.push(opts.status);
  }
  const search = buildSearchClause(['ms.proposed_name', 'ms.proposed_scheme_key', 'f.name'], opts.q, params, idx);
  where += ` AND ${search.clause}`;
  idx = search.nextIdx;
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.medical_aid_submissions ms
     JOIN public.facilities f ON f.id = ms.facility_id WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT ms.id, ms.facility_id, ms.submitted_by, ms.proposed_name, ms.proposed_scheme_key,
            ms.status, ms.reviewed_by, ms.reviewed_at, ms.resulting_scheme_id, ms.created_at,
            f.name AS facility_name
     FROM public.medical_aid_submissions ms
     JOIN public.facilities f ON f.id = ms.facility_id
     WHERE ${where}
     ORDER BY ms.created_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    submissions: rows.rows.map(mapSubmission),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function approveMedicalAidSubmission(id: string, reviewerId: string) {
  const submission = await query(
    `SELECT id, proposed_name, proposed_scheme_key, status FROM public.medical_aid_submissions WHERE id = $1`,
    [id],
  );
  const row = submission.rows[0];
  if (!row) throw new NotFoundError('Medical aid submission', id);
  if (row.status !== 'pending') throw new ConflictError('Submission has already been reviewed');

  const name = String(row.proposed_name);
  const schemeKey = String(row.proposed_scheme_key);

  let schemeId: string;
  const existing = await query(
    `SELECT id FROM public.medical_aid_schemes WHERE scheme_key = $1 AND deleted_at IS NULL`,
    [schemeKey],
  );
  if (existing.rows[0]) {
    schemeId = String(existing.rows[0].id);
    await query(
      `UPDATE public.medical_aid_schemes SET name = $2, is_active = true, updated_at = timezone('utc', now()) WHERE id = $1`,
      [schemeId, name],
    );
  } else {
    const created = await query(
      `INSERT INTO public.medical_aid_schemes (scheme_key, name, sort_order, is_active)
       VALUES ($1, $2, 0, true) RETURNING id`,
      [schemeKey, name],
    );
    schemeId = String(created.rows[0].id);
  }

  const updated = await query(
    `UPDATE public.medical_aid_submissions SET status = 'approved', reviewed_by = $2, reviewed_at = timezone('utc', now()),
       resulting_scheme_id = $3, updated_at = timezone('utc', now())
     WHERE id = $1
     RETURNING id, facility_id, submitted_by, proposed_name, proposed_scheme_key,
               status, reviewed_by, reviewed_at, resulting_scheme_id, created_at`,
    [id, reviewerId, schemeId],
  );

  const scheme = await query(
    `SELECT id, scheme_key, name, logo_path, sort_order, is_active FROM public.medical_aid_schemes WHERE id = $1`,
    [schemeId],
  );

  return { submission: mapSubmission(updated.rows[0]), scheme: mapScheme(scheme.rows[0]) };
}

export async function rejectMedicalAidSubmission(id: string, reviewerId: string) {
  const result = await query(
    `UPDATE public.medical_aid_submissions SET status = 'rejected', reviewed_by = $2, reviewed_at = timezone('utc', now()),
       updated_at = timezone('utc', now())
     WHERE id = $1 AND status = 'pending'
     RETURNING id, facility_id, submitted_by, proposed_name, proposed_scheme_key,
               status, reviewed_by, reviewed_at, resulting_scheme_id, created_at`,
    [id, reviewerId],
  );
  if (!result.rows[0]) {
    const exists = await query(`SELECT status FROM public.medical_aid_submissions WHERE id = $1`, [id]);
    if (!exists.rows[0]) throw new NotFoundError('Medical aid submission', id);
    throw new ConflictError('Submission has already been reviewed');
  }
  return { submission: mapSubmission(result.rows[0]) };
}
