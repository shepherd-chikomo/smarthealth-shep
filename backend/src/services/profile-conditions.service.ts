import { query } from '../lib/db.js';
import { toCatalogSlug } from '../lib/catalog-slug.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { adminOffset, buildSearchClause, type AdminListQuery } from '../lib/admin-query.js';
import { ConflictError, NotFoundError, ValidationError } from '../lib/errors.js';

export type ProfileConditionItem = {
  id: string;
  slug: string;
  label: string;
  isCommon: boolean;
  sortOrder: number;
  isActive: boolean;
};

type ConditionRow = Record<string, unknown>;

function mapConditionRow(row: ConditionRow): ProfileConditionItem {
  return {
    id: String(row.id),
    slug: String(row.slug),
    label: String(row.label),
    isCommon: Boolean(row.is_common),
    sortOrder: Number(row.sort_order ?? 0),
    isActive: Boolean(row.is_active),
  };
}

function mapPublicCondition(row: ConditionRow) {
  return {
    id: String(row.slug),
    label: String(row.label),
  };
}

export async function listProfileConditions() {
  const result = await query(
    `SELECT slug, label, is_common
     FROM public.profile_conditions
     WHERE deleted_at IS NULL AND is_active = true
     ORDER BY is_common DESC, sort_order ASC, label ASC`,
  );

  const common: { id: string; label: string }[] = [];
  const other: { id: string; label: string }[] = [];

  for (const row of result.rows) {
    const item = mapPublicCondition(row);
    if (row.is_common) {
      common.push(item);
    } else {
      other.push(item);
    }
  }

  return { common, other };
}

export async function suggestProfileConditions(q: string, limit = 8) {
  const trimmed = q.trim();
  if (!trimmed) return { suggestions: [] as { id: string; label: string }[] };

  const slug = toCatalogSlug(trimmed);
  const pattern = `%${trimmed}%`;
  const result = await query(
    `SELECT slug, label
     FROM public.profile_conditions
     WHERE deleted_at IS NULL AND is_active = true
       AND (label ILIKE $1 OR slug ILIKE $1 OR slug = $2)
     ORDER BY
       CASE WHEN slug = $2 THEN 0 WHEN label ILIKE $3 THEN 1 ELSE 2 END,
       sort_order ASC,
       label ASC
     LIMIT $4`,
    [pattern, slug, `${trimmed}%`, Math.min(Math.max(limit, 1), 20)],
  );

  return { suggestions: result.rows.map(mapPublicCondition) };
}

export async function createConditionSubmission(
  userId: string,
  data: { label: string; familyMemberId?: string },
) {
  const label = data.label.trim();
  if (!label) throw new ValidationError('Condition label is required');

  const slug = toCatalogSlug(label);
  if (!slug) throw new ValidationError('Condition label is invalid');

  const existing = await query(
    `SELECT id FROM public.profile_conditions
     WHERE slug = $1 AND deleted_at IS NULL AND is_active = true`,
    [slug],
  );
  if (existing.rows[0]) {
    return { submission: null, skipped: true, reason: 'already_in_catalog' as const };
  }

  if (data.familyMemberId) {
    const member = await query(
      `SELECT id FROM public.family_members
       WHERE id = $1 AND account_holder_id = $2`,
      [data.familyMemberId, userId],
    );
    if (!member.rows[0]) throw new NotFoundError('Family member', data.familyMemberId);
  }

  const pending = await query(
    `SELECT id FROM public.condition_submissions
     WHERE user_id = $1 AND proposed_slug = $2 AND status = 'pending'`,
    [userId, slug],
  );
  if (pending.rows[0]) {
    return {
      submission: mapSubmissionRow(pending.rows[0]),
      skipped: true,
      reason: 'already_pending' as const,
    };
  }

  const inserted = await query(
    `INSERT INTO public.condition_submissions (
       user_id, family_member_id, proposed_label, proposed_slug
     ) VALUES ($1, $2, $3, $4)
     RETURNING id, user_id, family_member_id, proposed_label, proposed_slug,
               status, reviewed_by, reviewed_at, resulting_condition_id, created_at`,
    [userId, data.familyMemberId ?? null, label, slug],
  );

  return {
    submission: mapSubmissionRow(inserted.rows[0]),
    skipped: false,
    reason: null,
  };
}

type SubmissionStatus = 'pending' | 'approved' | 'rejected';

function mapSubmissionRow(row: ConditionRow) {
  return {
    id: String(row.id),
    userId: String(row.user_id),
    familyMemberId: row.family_member_id ? String(row.family_member_id) : null,
    proposedLabel: String(row.proposed_label),
    proposedSlug: String(row.proposed_slug),
    status: String(row.status) as SubmissionStatus,
    reviewedBy: row.reviewed_by ? String(row.reviewed_by) : null,
    reviewedAt: row.reviewed_at ? new Date(String(row.reviewed_at)).toISOString() : null,
    resultingConditionId: row.resulting_condition_id
      ? String(row.resulting_condition_id)
      : null,
    createdAt: new Date(String(row.created_at)).toISOString(),
  };
}

export async function listConditionsAdmin(opts: AdminListQuery) {
  const params: unknown[] = [];
  const search = buildSearchClause(['label', 'slug'], opts.q, params, 1);
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.profile_conditions
     WHERE deleted_at IS NULL AND ${search.clause}`,
    params,
  );

  const rows = await query(
    `SELECT id, slug, label, is_common, sort_order, is_active
     FROM public.profile_conditions
     WHERE deleted_at IS NULL AND ${search.clause}
     ORDER BY is_common DESC, sort_order ASC, label ASC
     LIMIT $${search.nextIdx++} OFFSET $${search.nextIdx}`,
    [...params, opts.limit, offset],
  );

  return {
    conditions: rows.rows.map(mapConditionRow),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function createCondition(data: {
  label: string;
  isCommon?: boolean;
  sortOrder?: number;
  isActive?: boolean;
}) {
  const label = data.label.trim();
  if (!label) throw new ValidationError('Label is required');

  const slug = toCatalogSlug(label);
  if (!slug) throw new ValidationError('Label cannot be converted to a valid slug');

  const dup = await query(
    `SELECT id FROM public.profile_conditions WHERE slug = $1 AND deleted_at IS NULL`,
    [slug],
  );
  if (dup.rows[0]) throw new ConflictError(`Condition '${slug}' already exists`);

  const result = await query(
    `INSERT INTO public.profile_conditions (slug, label, is_common, sort_order, is_active)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, slug, label, is_common, sort_order, is_active`,
    [
      slug,
      label,
      data.isCommon ?? true,
      data.sortOrder ?? 0,
      data.isActive ?? true,
    ],
  );

  return { condition: mapConditionRow(result.rows[0]) };
}

export async function updateCondition(
  id: string,
  data: {
    label?: string;
    isCommon?: boolean;
    sortOrder?: number;
    isActive?: boolean;
  },
) {
  const existing = await query(
    `SELECT id, slug FROM public.profile_conditions WHERE id = $1 AND deleted_at IS NULL`,
    [id],
  );
  if (!existing.rows[0]) throw new NotFoundError('Profile condition', id);

  let slug: string | undefined;
  if (data.label !== undefined) {
    const label = data.label.trim();
    if (!label) throw new ValidationError('Label is required');
    slug = toCatalogSlug(label);
    if (!slug) throw new ValidationError('Label cannot be converted to a valid slug');

    const dup = await query(
      `SELECT id FROM public.profile_conditions
       WHERE slug = $1 AND deleted_at IS NULL AND id <> $2`,
      [slug, id],
    );
    if (dup.rows[0]) throw new ConflictError(`Condition '${slug}' already exists`);
  }

  const result = await query(
    `UPDATE public.profile_conditions SET
       slug = COALESCE($2, slug),
       label = COALESCE($3, label),
       is_common = COALESCE($4, is_common),
       sort_order = COALESCE($5, sort_order),
       is_active = COALESCE($6, is_active),
       updated_at = timezone('utc', now())
     WHERE id = $1
     RETURNING id, slug, label, is_common, sort_order, is_active`,
    [
      id,
      slug,
      data.label?.trim(),
      data.isCommon,
      data.sortOrder,
      data.isActive,
    ],
  );

  return { condition: mapConditionRow(result.rows[0]) };
}

export async function deleteCondition(id: string) {
  const result = await query(
    `UPDATE public.profile_conditions SET deleted_at = timezone('utc', now())
     WHERE id = $1 AND deleted_at IS NULL RETURNING id`,
    [id],
  );
  if (!result.rows[0]) throw new NotFoundError('Profile condition', id);
  return { id };
}

export async function listSubmissionsAdmin(opts: AdminListQuery) {
  const params: unknown[] = [];
  let idx = 1;
  let where = 'TRUE';

  if (opts.status) {
    where += ` AND cs.status = $${idx++}::public.condition_submission_status`;
    params.push(opts.status);
  }

  const search = buildSearchClause(
    ['cs.proposed_label', 'cs.proposed_slug', 'p.email'],
    opts.q,
    params,
    idx,
  );
  where += ` AND ${search.clause}`;
  idx = search.nextIdx;

  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM public.condition_submissions cs
     LEFT JOIN public.profiles p ON p.id = cs.user_id
     WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT cs.id, cs.user_id, cs.family_member_id, cs.proposed_label, cs.proposed_slug,
            cs.status, cs.reviewed_by, cs.reviewed_at, cs.resulting_condition_id, cs.created_at,
            p.email AS user_email
     FROM public.condition_submissions cs
     LEFT JOIN public.profiles p ON p.id = cs.user_id
     WHERE ${where}
     ORDER BY cs.created_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    submissions: rows.rows.map((row) => ({
      ...mapSubmissionRow(row),
      userEmail: row.user_email ? String(row.user_email) : null,
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function approveSubmission(
  id: string,
  reviewerId: string,
  data: { isCommon?: boolean },
) {
  const submission = await query(
    `SELECT id, proposed_label, proposed_slug, status
     FROM public.condition_submissions WHERE id = $1`,
    [id],
  );
  const row = submission.rows[0];
  if (!row) throw new NotFoundError('Condition submission', id);
  if (row.status !== 'pending') {
    throw new ConflictError('Submission has already been reviewed');
  }

  const label = String(row.proposed_label);
  const slug = String(row.proposed_slug);
  const isCommon = data.isCommon ?? false;

  let conditionId: string;
  const existing = await query(
    `SELECT id FROM public.profile_conditions WHERE slug = $1 AND deleted_at IS NULL`,
    [slug],
  );

  if (existing.rows[0]) {
    conditionId = String(existing.rows[0].id);
    await query(
      `UPDATE public.profile_conditions SET
         label = $2,
         is_active = true,
         updated_at = timezone('utc', now())
       WHERE id = $1`,
      [conditionId, label],
    );
  } else {
    const created = await query(
      `INSERT INTO public.profile_conditions (slug, label, is_common, sort_order, is_active)
       VALUES ($1, $2, $3, 0, true)
       RETURNING id`,
      [slug, label, isCommon],
    );
    conditionId = String(created.rows[0].id);
  }

  const updated = await query(
    `UPDATE public.condition_submissions SET
       status = 'approved',
       reviewed_by = $2,
       reviewed_at = timezone('utc', now()),
       resulting_condition_id = $3,
       updated_at = timezone('utc', now())
     WHERE id = $1
     RETURNING id, user_id, family_member_id, proposed_label, proposed_slug,
               status, reviewed_by, reviewed_at, resulting_condition_id, created_at`,
    [id, reviewerId, conditionId],
  );

  const condition = await query(
    `SELECT id, slug, label, is_common, sort_order, is_active
     FROM public.profile_conditions WHERE id = $1`,
    [conditionId],
  );

  return {
    submission: mapSubmissionRow(updated.rows[0]),
    condition: mapConditionRow(condition.rows[0]),
  };
}

export async function rejectSubmission(id: string, reviewerId: string) {
  const result = await query(
    `UPDATE public.condition_submissions SET
       status = 'rejected',
       reviewed_by = $2,
       reviewed_at = timezone('utc', now()),
       updated_at = timezone('utc', now())
     WHERE id = $1 AND status = 'pending'
     RETURNING id, user_id, family_member_id, proposed_label, proposed_slug,
               status, reviewed_by, reviewed_at, resulting_condition_id, created_at`,
    [id, reviewerId],
  );
  if (!result.rows[0]) {
    const exists = await query(`SELECT status FROM public.condition_submissions WHERE id = $1`, [id]);
    if (!exists.rows[0]) throw new NotFoundError('Condition submission', id);
    throw new ConflictError('Submission has already been reviewed');
  }
  return { submission: mapSubmissionRow(result.rows[0]) };
}
