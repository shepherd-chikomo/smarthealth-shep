import { query } from '../lib/db.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { ForbiddenError, NotFoundError } from '../lib/errors.js';
import { isSuperAdmin } from '../lib/rbac.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { adminOffset, buildSearchClause, type AdminListQuery } from '../lib/admin-query.js';
import { logAdminAudit } from '../lib/audit-log.js';
import type { RequestContext } from '../lib/request-context.js';

function requireSuperAdmin(user: AuthenticatedUser): void {
  if (!isSuperAdmin(user)) throw new ForbiddenError('Super admin access required');
}

export async function listImportBatches(user: AuthenticatedUser, opts: AdminListQuery) {
  requireSuperAdmin(user);
  const params: unknown[] = [];
  const search = buildSearchClause(['source_file', 'status::text'], opts.q, params, 1);
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.import_logs WHERE ${search.clause}`,
    params,
  );

  const rows = await query(
    `SELECT id, source_file, source_type, status, dry_run, total_rows, imported_count,
            failed_count, duplicates_merged, facilities_created, providers_created,
            links_created, specialties_unmatched, cities_missing, geocoded_count,
            started_at, completed_at, error_message
     FROM public.import_logs
     WHERE ${search.clause}
     ORDER BY started_at DESC
     LIMIT $${search.nextIdx++} OFFSET $${search.nextIdx}`,
    [...params, opts.limit, offset],
  );

  return {
    batches: rows.rows.map(mapBatch),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function getImportBatch(user: AuthenticatedUser, batchId: string) {
  requireSuperAdmin(user);
  const result = await query(`SELECT * FROM public.import_logs WHERE id = $1`, [batchId]);
  if (!result.rows[0]) throw new NotFoundError('Import batch', batchId);
  return { batch: mapBatchDetail(result.rows[0]) };
}

export async function listFailedImports(
  user: AuthenticatedUser,
  opts: AdminListQuery & { batchId?: string },
) {
  requireSuperAdmin(user);
  const params: unknown[] = [];
  let idx = 1;
  const conditions = ['TRUE'];

  if (opts.batchId) {
    conditions.push(`fi.import_batch_id = $${idx++}`);
    params.push(opts.batchId);
  }
  if (opts.status === 'resolved') conditions.push('fi.is_resolved = true');
  if (opts.status === 'unresolved') conditions.push('fi.is_resolved = false');

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.failed_imports fi WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT fi.*, il.source_file
     FROM public.failed_imports fi
     JOIN public.import_logs il ON il.id = fi.import_batch_id
     WHERE ${where}
     ORDER BY fi.created_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    failures: rows.rows.map(mapFailedImport),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function resolveFailedImport(
  user: AuthenticatedUser,
  failureId: string,
  notes: string | undefined,
  ctx: RequestContext,
) {
  requireSuperAdmin(user);
  const result = await query(
    `UPDATE public.failed_imports SET
       is_resolved = true,
       resolved_at = timezone('utc', now()),
       resolved_by = $2,
       resolution_notes = $3
     WHERE id = $1
     RETURNING id`,
    [failureId, user.id, notes ?? null],
  );
  if (!result.rows[0]) throw new NotFoundError('Failed import', failureId);

  await logAdminAudit(user.id, 'import.failure.resolve', 'failed_import', failureId, ctx);
  return { message: 'Resolved' };
}

export async function listDuplicateReviews(user: AuthenticatedUser, opts: AdminListQuery) {
  requireSuperAdmin(user);
  const status = opts.status ?? 'pending';
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.import_duplicate_reviews WHERE status = $1`,
    [status],
  );

  const rows = await query(
    `SELECT * FROM public.import_duplicate_reviews
     WHERE status = $1
     ORDER BY created_at DESC
     LIMIT $2 OFFSET $3`,
    [status, opts.limit, offset],
  );

  return {
    reviews: rows.rows,
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function reviewDuplicate(
  user: AuthenticatedUser,
  reviewId: string,
  action: 'approve' | 'reject',
  ctx: RequestContext,
) {
  requireSuperAdmin(user);
  const result = await query(
    `UPDATE public.import_duplicate_reviews SET
       status = $2,
       reviewed_by = $3,
       reviewed_at = timezone('utc', now())
     WHERE id = $1 AND status = 'pending'
     RETURNING id`,
    [reviewId, action === 'approve' ? 'approved' : 'rejected', user.id],
  );
  if (!result.rows[0]) throw new NotFoundError('Duplicate review', reviewId);

  await logAdminAudit(user.id, `import.duplicate.${action}`, 'import_duplicate_review', reviewId, ctx);
  return { message: action === 'approve' ? 'Merge approved' : 'Merge rejected' };
}

export async function listUnmatchedSpecialties(user: AuthenticatedUser, opts: AdminListQuery) {
  requireSuperAdmin(user);
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.import_unmatched_specialties WHERE is_resolved = false`,
  );

  const rows = await query(
    `SELECT ius.*, il.source_file
     FROM public.import_unmatched_specialties ius
     JOIN public.import_logs il ON il.id = ius.import_batch_id
     WHERE ius.is_resolved = false
     ORDER BY ius.occurrence_count DESC
     LIMIT $1 OFFSET $2`,
    [opts.limit, offset],
  );

  return {
    specialties: rows.rows,
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function mapUnmatchedSpecialty(
  user: AuthenticatedUser,
  unmatchedId: string,
  specialtyId: string,
  ctx: RequestContext,
) {
  requireSuperAdmin(user);
  const result = await query(
    `UPDATE public.import_unmatched_specialties SET
       mapped_specialty_id = $2,
       is_resolved = true
     WHERE id = $1
     RETURNING raw_specialty`,
    [unmatchedId, specialtyId],
  );
  if (!result.rows[0]) throw new NotFoundError('Unmatched specialty', unmatchedId);

  await logAdminAudit(user.id, 'import.specialty.map', 'import_unmatched_specialty', unmatchedId, ctx, {
    specialtyId,
  });
  return { message: 'Specialty mapped' };
}

export async function verifyImportedProvider(
  user: AuthenticatedUser,
  providerId: string,
  verified: boolean,
  ctx: RequestContext,
) {
  requireSuperAdmin(user);
  const result = await query(
    `UPDATE public.providers SET
       verified_status = $2::public.verified_status,
       is_verified = $3,
       license_verified_at = CASE WHEN $3 THEN timezone('utc', now()) ELSE NULL END,
       verified_at = CASE WHEN $3 THEN timezone('utc', now()) ELSE NULL END,
       verified_by = CASE WHEN $3 THEN $4::uuid ELSE NULL END
     WHERE id = $1
     RETURNING id, name`,
    [providerId, verified ? 'verified' : 'rejected', verified, user.id],
  );
  if (!result.rows[0]) throw new NotFoundError('Provider', providerId);

  await logAdminAudit(
    user.id,
    verified ? 'provider.verify' : 'provider.reject',
    'provider',
    providerId,
    ctx,
  );
  return { provider: result.rows[0] };
}

function mapBatch(row: Record<string, unknown>) {
  return {
    id: row.id,
    sourceFile: row.source_file,
    sourceType: row.source_type,
    status: row.status,
    dryRun: row.dry_run,
    totalRows: row.total_rows,
    importedCount: row.imported_count,
    failedCount: row.failed_count,
    duplicatesMerged: row.duplicates_merged,
    facilitiesCreated: row.facilities_created,
    providersCreated: row.providers_created,
    linksCreated: row.links_created,
    specialtiesUnmatched: row.specialties_unmatched,
    citiesMissing: row.cities_missing,
    geocodedCount: row.geocoded_count,
    startedAt: row.started_at,
    completedAt: row.completed_at,
    errorMessage: row.error_message,
  };
}

function mapBatchDetail(row: Record<string, unknown>) {
  return {
    ...mapBatch(row),
    reportJson: row.report_json,
    reportCsvPath: row.report_csv_path,
    reportJsonPath: row.report_json_path,
    options: row.options,
  };
}

function mapFailedImport(row: Record<string, unknown>) {
  return {
    id: row.id,
    batchId: row.import_batch_id,
    sourceFile: row.source_file,
    rowNumber: row.row_number,
    entityType: row.entity_type,
    rawData: row.raw_data,
    normalizedData: row.normalized_data,
    errorCode: row.error_code,
    errorMessage: row.error_message,
    isResolved: row.is_resolved,
    resolvedAt: row.resolved_at,
    resolutionNotes: row.resolution_notes,
    createdAt: row.created_at,
  };
}
