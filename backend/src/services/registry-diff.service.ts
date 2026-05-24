import { query } from '../lib/db.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { ForbiddenError, NotFoundError } from '../lib/errors.js';
import { isSuperAdmin } from '../lib/rbac.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { adminOffset, type AdminListQuery } from '../lib/admin-query.js';
import { logAdminAudit } from '../lib/audit-log.js';
import type { RequestContext } from '../lib/request-context.js';

function requireSuperAdmin(user: AuthenticatedUser): void {
  if (!isSuperAdmin(user)) throw new ForbiddenError('Super admin access required');
}

export async function listRegistryDiffRuns(user: AuthenticatedUser, opts: AdminListQuery) {
  requireSuperAdmin(user);
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(`SELECT COUNT(*)::text AS count FROM public.registry_diff_runs`);
  const rows = await query(
    `SELECT id, source_type, source_file, status, added_count, updated_count, removed_count,
            started_at, completed_at, notified_at
     FROM public.registry_diff_runs
     ORDER BY started_at DESC
     LIMIT $1 OFFSET $2`,
    [opts.limit, offset],
  );

  return {
    runs: rows.rows.map((r) => ({
      id: r.id,
      sourceType: r.source_type,
      sourceFile: r.source_file,
      status: r.status,
      addedCount: r.added_count,
      updatedCount: r.updated_count,
      removedCount: r.removed_count,
      startedAt: r.started_at,
      completedAt: r.completed_at,
      notifiedAt: r.notified_at,
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function listRegistryDiffItems(
  user: AuthenticatedUser,
  runId: string,
  opts: AdminListQuery & { status?: string },
) {
  requireSuperAdmin(user);
  const params: unknown[] = [runId];
  let idx = 2;
  const conditions = ['rdi.run_id = $1'];

  if (opts.status) {
    conditions.push(`rdi.status = $${idx++}`);
    params.push(opts.status);
  }

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.registry_diff_items rdi WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT rdi.id, rdi.entity_type, rdi.change_type, rdi.entity_id, rdi.stable_key,
            rdi.field_changes, rdi.raw_data, rdi.status, rdi.review_notes, rdi.created_at
     FROM public.registry_diff_items rdi
     WHERE ${where}
     ORDER BY rdi.created_at ASC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    items: rows.rows.map((r) => ({
      id: r.id,
      entityType: r.entity_type,
      changeType: r.change_type,
      entityId: r.entity_id,
      stableKey: r.stable_key,
      fieldChanges: r.field_changes,
      rawData: r.raw_data,
      status: r.status,
      reviewNotes: r.review_notes,
      createdAt: r.created_at,
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function reviewRegistryDiffItem(
  user: AuthenticatedUser,
  itemId: string,
  action: 'approve' | 'ignore',
  reviewNotes: string | undefined,
  ctx: RequestContext,
) {
  requireSuperAdmin(user);

  const item = await query(
    `SELECT * FROM public.registry_diff_items WHERE id = $1`,
    [itemId],
  );
  if (!item.rows[0]) throw new NotFoundError('Diff item', itemId);
  if (item.rows[0].status !== 'pending') {
    return { status: item.rows[0].status };
  }

  const newStatus = action === 'approve' ? 'approved' : 'ignored';

  if (action === 'approve') {
    await applyRegistryDiffItem(item.rows[0]);
  }

  await query(
    `UPDATE public.registry_diff_items SET
       status = $2, reviewed_by = $3, reviewed_at = timezone('utc', now()), review_notes = $4
     WHERE id = $1`,
    [itemId, newStatus, user.id, reviewNotes ?? null],
  );

  await logAdminAudit(user.id, `registry_diff.${action}`, 'registry_diff_item', itemId, ctx);
  return { status: newStatus };
}

async function applyRegistryDiffItem(row: Record<string, unknown>): Promise<void> {
  const changeType = row.change_type as string;
  const entityType = row.entity_type as string;
  const rawData = row.raw_data as Record<string, unknown>;
  const fieldChanges = row.field_changes as Record<string, { old: string; new: string }>;

  if (entityType === 'facility') {
    if (changeType === 'updated' && row.entity_id) {
      const updates: string[] = [];
      const params: unknown[] = [];
      let idx = 1;
      if (fieldChanges.name) {
        updates.push(`name = $${idx++}`);
        params.push(fieldChanges.name.new);
      }
      if (fieldChanges.address) {
        updates.push(`address_line1 = $${idx++}`);
        params.push(fieldChanges.address.new);
      }
      if (fieldChanges.city) {
        updates.push(`city = $${idx++}`);
        params.push(fieldChanges.city.new);
      }
      if (updates.length > 0) {
        params.push(row.entity_id);
        await query(`UPDATE public.facilities SET ${updates.join(', ')} WHERE id = $${idx}`, params);
      }
    }
    // Added/removed: admin applies manually via facilities UI; no auto-delete on removed
  }

  if (entityType === 'provider') {
    if (changeType === 'updated' && row.entity_id) {
      const updates: string[] = [];
      const params: unknown[] = [];
      let idx = 1;
      if (fieldChanges.name) {
        updates.push(`name = $${idx++}`);
        params.push(fieldChanges.name.new);
      }
      if (fieldChanges.specialty) {
        updates.push(`specialty = $${idx++}`);
        params.push(fieldChanges.specialty.new);
      }
      if (fieldChanges.email) {
        updates.push(`email = $${idx++}`);
        params.push(fieldChanges.email.new);
      }
      if (updates.length > 0) {
        params.push(row.entity_id);
        await query(`UPDATE public.providers SET ${updates.join(', ')} WHERE id = $${idx}`, params);
      }
    }
  }

  void rawData;
}
