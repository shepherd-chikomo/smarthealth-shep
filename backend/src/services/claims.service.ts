import { query } from '../lib/db.js';
import { ConflictError, ForbiddenError, NotFoundError } from '../lib/errors.js';
import { buildPaginationMeta, paginationOffset } from '../lib/pagination.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { isAdminRole, isSuperAdmin } from '../lib/rbac.js';
import { adminOffset, type AdminListQuery } from '../lib/admin-query.js';
import type { RequestContext } from '../lib/request-context.js';
import { logAdminAudit } from '../lib/audit-log.js';

type ClaimType = 'facility' | 'provider';

function mapFacilityClaim(row: Record<string, unknown>) {
  return {
    id: row.id,
    type: 'facility' as const,
    facilityId: row.facility_id,
    facilityName: row.facility_name,
    claimantId: row.claimant_id,
    status: row.status,
    businessRegistrationNumber: row.business_registration_number,
    evidence: row.evidence ?? {},
    notes: row.notes,
    reviewedBy: row.reviewed_by,
    reviewedAt: row.reviewed_at,
    reviewNotes: row.review_notes,
    submittedAt: row.submitted_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function mapProviderClaim(row: Record<string, unknown>) {
  return {
    id: row.id,
    type: 'provider' as const,
    providerId: row.provider_id,
    providerName: row.provider_name,
    facilityId: row.tenant_id,
    facilityName: row.facility_name,
    claimantId: row.claimant_id,
    status: row.status,
    mdpczNumber: row.mdpcz_number,
    evidence: row.evidence ?? {},
    notes: row.notes,
    reviewedBy: row.reviewed_by,
    reviewedAt: row.reviewed_at,
    reviewNotes: row.review_notes,
    submittedAt: row.submitted_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export async function searchClaimableFacilities(opts: {
  q?: string;
  page: number;
  limit: number;
}) {
  const params: unknown[] = [];
  let idx = 1;
  const conditions = ['f.is_active = true', 'f.deleted_at IS NULL', 'f.is_claimed = false'];

  if (opts.q?.trim()) {
    conditions.push(`(f.name ILIKE $${idx} OR f.city ILIKE $${idx})`);
    params.push(`%${opts.q.trim()}%`);
    idx++;
  }

  const where = conditions.join(' AND ');
  const offset = paginationOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.facilities f WHERE ${where}`,
    params,
  );

  const result = await query(
    `SELECT f.id, f.name, f.city, f.province, f.is_claimed,
            (SELECT COUNT(*)::int FROM public.facility_claims fc
             WHERE fc.facility_id = f.id AND fc.status IN ('submitted', 'under_review')) AS pending_claims
     FROM public.facilities f
     WHERE ${where}
     ORDER BY f.name ASC
     LIMIT $${idx} OFFSET $${idx + 1}`,
    [...params, opts.limit, offset],
  );

  return {
    facilities: result.rows.map((row) => ({
      id: row.id,
      name: row.name,
      city: row.city,
      province: row.province,
      isClaimed: row.is_claimed,
      pendingClaims: row.pending_claims,
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function searchClaimableProviders(opts: {
  q?: string;
  page: number;
  limit: number;
}) {
  const params: unknown[] = [];
  let idx = 1;
  const conditions = [
    'p.is_active = true',
    'p.deleted_at IS NULL',
    'p.is_claimed = false',
  ];

  if (opts.q?.trim()) {
    conditions.push(`(p.name ILIKE $${idx} OR p.specialty ILIKE $${idx} OR f.name ILIKE $${idx})`);
    params.push(`%${opts.q.trim()}%`);
    idx++;
  }

  const where = conditions.join(' AND ');
  const offset = paginationOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM public.providers p
     JOIN public.facilities f ON f.id = p.facility_id
     WHERE ${where}`,
    params,
  );

  const result = await query(
    `SELECT p.id, p.name, p.specialty, f.id AS facility_id, f.name AS facility_name, p.is_claimed,
            (SELECT COUNT(*)::int FROM public.provider_claims pc
             WHERE pc.provider_id = p.id AND pc.status IN ('submitted', 'under_review')) AS pending_claims
     FROM public.providers p
     JOIN public.facilities f ON f.id = p.facility_id
     WHERE ${where}
     ORDER BY p.name ASC
     LIMIT $${idx} OFFSET $${idx + 1}`,
    [...params, opts.limit, offset],
  );

  return {
    providers: result.rows.map((row) => ({
      id: row.id,
      name: row.name,
      specialty: row.specialty,
      facilityId: row.facility_id,
      facilityName: row.facility_name,
      isClaimed: row.is_claimed,
      pendingClaims: row.pending_claims,
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function createFacilityClaim(
  userId: string,
  data: {
    facilityId: string;
    businessRegistrationNumber?: string;
    notes?: string;
    evidence?: Record<string, unknown>;
  },
) {
  const facility = await query<{ id: string; is_claimed: boolean; name: string }>(
    `SELECT id, is_claimed, name FROM public.facilities
     WHERE id = $1 AND is_active = true AND deleted_at IS NULL`,
    [data.facilityId],
  );
  if (!facility.rows[0]) throw new NotFoundError('Facility', data.facilityId);
  if (facility.rows[0].is_claimed) {
    throw new ConflictError('This facility is already claimed');
  }

  const duplicate = await query(
    `SELECT id FROM public.facility_claims
     WHERE facility_id = $1 AND claimant_id = $2 AND status NOT IN ('rejected', 'withdrawn')`,
    [data.facilityId, userId],
  );
  if (duplicate.rows[0]) {
    throw new ConflictError('You already have an active claim for this facility');
  }

  const result = await query(
    `INSERT INTO public.facility_claims (
       facility_id, tenant_id, claimant_id, status,
       business_registration_number, evidence, notes
     ) VALUES ($1, $1, $2, 'draft', $3, $4::jsonb, $5)
     RETURNING *`,
    [
      data.facilityId,
      userId,
      data.businessRegistrationNumber ?? null,
      JSON.stringify(data.evidence ?? {}),
      data.notes ?? null,
    ],
  );

  const row = result.rows[0];
  return mapFacilityClaim({ ...row, facility_name: facility.rows[0].name });
}

export async function createProviderClaim(
  userId: string,
  data: {
    providerId: string;
    mdpczNumber?: string;
    notes?: string;
    evidence?: Record<string, unknown>;
  },
) {
  const provider = await query<{
    id: string;
    is_claimed: boolean;
    name: string;
    facility_id: string;
    facility_name: string;
  }>(
    `SELECT p.id, p.is_claimed, p.name, p.facility_id, f.name AS facility_name
     FROM public.providers p
     JOIN public.facilities f ON f.id = p.facility_id
     WHERE p.id = $1 AND p.is_active = true AND p.deleted_at IS NULL`,
    [data.providerId],
  );
  if (!provider.rows[0]) throw new NotFoundError('Provider', data.providerId);
  if (provider.rows[0].is_claimed) {
    throw new ConflictError('This provider listing is already claimed');
  }

  const duplicate = await query(
    `SELECT id FROM public.provider_claims
     WHERE provider_id = $1 AND claimant_id = $2 AND status NOT IN ('rejected', 'withdrawn')`,
    [data.providerId, userId],
  );
  if (duplicate.rows[0]) {
    throw new ConflictError('You already have an active claim for this provider');
  }

  const result = await query(
    `INSERT INTO public.provider_claims (
       provider_id, tenant_id, claimant_id, status,
       mdpcz_number, evidence, notes
     ) VALUES ($1, $2, $3, 'draft', $4, $5::jsonb, $6)
     RETURNING *`,
    [
      data.providerId,
      provider.rows[0].facility_id,
      userId,
      data.mdpczNumber ?? null,
      JSON.stringify(data.evidence ?? {}),
      data.notes ?? null,
    ],
  );

  const row = result.rows[0];
  return mapProviderClaim({
    ...row,
    provider_name: provider.rows[0].name,
    facility_name: provider.rows[0].facility_name,
  });
}

export async function updateFacilityClaim(
  userId: string,
  claimId: string,
  data: {
    businessRegistrationNumber?: string;
    notes?: string;
    evidence?: Record<string, unknown>;
  },
) {
  const existing = await query(
    `SELECT * FROM public.facility_claims WHERE id = $1 AND claimant_id = $2`,
    [claimId, userId],
  );
  if (!existing.rows[0]) throw new NotFoundError('Claim', claimId);
  if (existing.rows[0].status !== 'draft') {
    throw new ConflictError('Only draft claims can be edited');
  }

  const result = await query(
    `UPDATE public.facility_claims SET
       business_registration_number = COALESCE($3, business_registration_number),
       notes = COALESCE($4, notes),
       evidence = COALESCE($5::jsonb, evidence),
       updated_at = now()
     WHERE id = $1 AND claimant_id = $2
     RETURNING *`,
    [
      claimId,
      userId,
      data.businessRegistrationNumber ?? null,
      data.notes ?? null,
      data.evidence ? JSON.stringify(data.evidence) : null,
    ],
  );

  const facility = await query(
    `SELECT name FROM public.facilities WHERE id = $1`,
    [result.rows[0].facility_id],
  );
  return mapFacilityClaim({
    ...result.rows[0],
    facility_name: facility.rows[0]?.name,
  });
}

export async function submitFacilityClaim(userId: string, claimId: string) {
  const result = await query(
    `UPDATE public.facility_claims SET
       status = 'submitted',
       submitted_at = now(),
       updated_at = now()
     WHERE id = $1 AND claimant_id = $2 AND status = 'draft'
     RETURNING *`,
    [claimId, userId],
  );
  if (!result.rows[0]) throw new NotFoundError('Draft claim', claimId);

  await query(
    `UPDATE public.facility_claims SET status = 'under_review', updated_at = now()
     WHERE id = $1`,
    [claimId],
  );

  const facility = await query(
    `SELECT name FROM public.facilities WHERE id = $1`,
    [result.rows[0].facility_id],
  );
  return mapFacilityClaim({
    ...result.rows[0],
    status: 'under_review',
    facility_name: facility.rows[0]?.name,
  });
}

export async function submitProviderClaim(userId: string, claimId: string) {
  const result = await query(
    `UPDATE public.provider_claims SET
       status = 'submitted',
       submitted_at = now(),
       updated_at = now()
     WHERE id = $1 AND claimant_id = $2 AND status = 'draft'
     RETURNING *`,
    [claimId, userId],
  );
  if (!result.rows[0]) throw new NotFoundError('Draft claim', claimId);

  await query(
    `UPDATE public.provider_claims SET status = 'under_review', updated_at = now()
     WHERE id = $1`,
    [claimId],
  );

  const provider = await query(
    `SELECT p.name, f.name AS facility_name
     FROM public.providers p
     JOIN public.facilities f ON f.id = p.facility_id
     WHERE p.id = $1`,
    [result.rows[0].provider_id],
  );
  return mapProviderClaim({
    ...result.rows[0],
    status: 'under_review',
    provider_name: provider.rows[0]?.name,
    facility_name: provider.rows[0]?.facility_name,
  });
}

export async function listMyClaims(userId: string) {
  const [facilities, providers] = await Promise.all([
    query(
      `SELECT fc.*, f.name AS facility_name
       FROM public.facility_claims fc
       JOIN public.facilities f ON f.id = fc.facility_id
       WHERE fc.claimant_id = $1
       ORDER BY fc.updated_at DESC`,
      [userId],
    ),
    query(
      `SELECT pc.*, p.name AS provider_name, f.name AS facility_name
       FROM public.provider_claims pc
       JOIN public.providers p ON p.id = pc.provider_id
       JOIN public.facilities f ON f.id = pc.tenant_id
       WHERE pc.claimant_id = $1
       ORDER BY pc.updated_at DESC`,
      [userId],
    ),
  ]);

  return {
    facilityClaims: facilities.rows.map(mapFacilityClaim),
    providerClaims: providers.rows.map(mapProviderClaim),
  };
}

export async function listClaimsForAdmin(user: AuthenticatedUser, opts: AdminListQuery) {
  if (!isSuperAdmin(user) && !isAdminRole(user.role)) {
    throw new ForbiddenError('Admin access required');
  }

  const offset = adminOffset(opts.page, opts.limit);
  const statusFilter = opts.status ?? 'under_review';
  const params: unknown[] = [statusFilter, opts.limit, offset];

  const facilityClaims = await query(
    `SELECT fc.*, f.name AS facility_name,
            pr.first_name || ' ' || COALESCE(pr.last_name, '') AS claimant_name
     FROM public.facility_claims fc
     JOIN public.facilities f ON f.id = fc.facility_id
     JOIN public.profiles pr ON pr.id = fc.claimant_id
     WHERE fc.status = $1
     ORDER BY fc.submitted_at ASC NULLS LAST
     LIMIT $2 OFFSET $3`,
    params,
  );

  const providerClaims = await query(
    `SELECT pc.*, p.name AS provider_name, f.name AS facility_name,
            pr.first_name || ' ' || COALESCE(pr.last_name, '') AS claimant_name
     FROM public.provider_claims pc
     JOIN public.providers p ON p.id = pc.provider_id
     JOIN public.facilities f ON f.id = pc.tenant_id
     JOIN public.profiles pr ON pr.id = pc.claimant_id
     WHERE pc.status = $1
     ORDER BY pc.submitted_at ASC NULLS LAST
     LIMIT $2 OFFSET $3`,
    params,
  );

  const countF = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.facility_claims WHERE status = $1`,
    [statusFilter],
  );
  const countP = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.provider_claims WHERE status = $1`,
    [statusFilter],
  );

  return {
    facilityClaims: facilityClaims.rows.map((row) => ({
      ...mapFacilityClaim(row),
      claimantName: row.claimant_name,
    })),
    providerClaims: providerClaims.rows.map((row) => ({
      ...mapProviderClaim(row),
      claimantName: row.claimant_name,
    })),
    pagination: buildPaginationMeta(
      opts.page,
      opts.limit,
      Number(countF.rows[0]?.count ?? 0) + Number(countP.rows[0]?.count ?? 0),
    ),
  };
}

export async function reviewClaim(
  user: AuthenticatedUser,
  claimId: string,
  type: ClaimType,
  action: 'approve' | 'reject',
  reviewNotes?: string,
  ctx?: RequestContext,
) {
  if (!isSuperAdmin(user) && !isAdminRole(user.role)) {
    throw new ForbiddenError('Admin access required');
  }

  if (type === 'facility') {
    const claim = await query(
      `SELECT * FROM public.facility_claims WHERE id = $1`,
      [claimId],
    );
    if (!claim.rows[0]) throw new NotFoundError('Claim', claimId);
    if (!['submitted', 'under_review'].includes(claim.rows[0].status)) {
      throw new ConflictError('Claim is not pending review');
    }

    const newStatus = action === 'approve' ? 'approved' : 'rejected';
    await query(
      `UPDATE public.facility_claims SET
         status = $2::public.claim_status,
         reviewed_by = $3,
         reviewed_at = now(),
         review_notes = $4,
         updated_at = now()
       WHERE id = $1`,
      [claimId, newStatus, user.id, reviewNotes ?? null],
    );

    if (action === 'approve') {
      const facilityId = claim.rows[0].facility_id;
      const claimantId = claim.rows[0].claimant_id;
      await query(
        `UPDATE public.facilities SET
           owner_id = $2,
           is_claimed = true,
           verification_status = 'verified'::public.verification_status,
           verified_at = now(),
           verified_by = $3
         WHERE id = $1`,
        [facilityId, claimantId, user.id],
      );
      await query(
        `INSERT INTO public.facility_memberships (facility_id, user_id, role)
         VALUES ($1, $2, 'facility_admin'::public.facility_role)
         ON CONFLICT (facility_id, user_id) DO UPDATE SET role = EXCLUDED.role`,
        [facilityId, claimantId],
      );
    }

    await logAdminAudit(
      user.id,
      `claim_${action}`,
      'facility_claim',
      claimId,
      ctx,
      { reviewNotes },
    );

    return { status: newStatus };
  }

  const claim = await query(
    `SELECT * FROM public.provider_claims WHERE id = $1`,
    [claimId],
  );
  if (!claim.rows[0]) throw new NotFoundError('Claim', claimId);
  if (!['submitted', 'under_review'].includes(claim.rows[0].status)) {
    throw new ConflictError('Claim is not pending review');
  }

  const newStatus = action === 'approve' ? 'approved' : 'rejected';
  await query(
    `UPDATE public.provider_claims SET
       status = $2::public.claim_status,
       reviewed_by = $3,
       reviewed_at = now(),
       review_notes = $4,
       updated_at = now()
     WHERE id = $1`,
    [claimId, newStatus, user.id, reviewNotes ?? null],
  );

  if (action === 'approve') {
    const providerId = claim.rows[0].provider_id;
    const claimantId = claim.rows[0].claimant_id;
    const tenantId = claim.rows[0].tenant_id;
    await query(
      `UPDATE public.providers SET
         owner_id = $2,
         is_claimed = true,
         is_verified = true,
         verification_status = 'verified'::public.verification_status,
         verified_at = now(),
         verified_by = $3
       WHERE id = $1`,
      [providerId, claimantId, user.id],
    );
    await query(
      `INSERT INTO public.facility_memberships (facility_id, user_id, role)
       VALUES ($1, $2, 'doctor'::public.facility_role)
       ON CONFLICT (facility_id, user_id) DO NOTHING`,
      [tenantId, claimantId],
    );
  }

  await logAdminAudit(
    user.id,
    `claim_${action}`,
    'provider_claim',
    claimId,
    ctx,
    { reviewNotes },
  );

  return { status: newStatus };
}

export async function getClaimHistory(entityId: string, type: ClaimType) {
  const table = type === 'facility' ? 'facility_claims' : 'provider_claims';
  const col = type === 'facility' ? 'facility_id' : 'provider_id';

  const result = await query(
    `SELECT id, status, claimant_id, submitted_at, reviewed_at, review_notes, created_at
     FROM public.${table}
     WHERE ${col} = $1
     ORDER BY created_at DESC`,
    [entityId],
  );

  return { history: result.rows };
}

export async function detectDuplicateClaims(entityId: string, type: ClaimType) {
  const table = type === 'facility' ? 'facility_claims' : 'provider_claims';
  const col = type === 'facility' ? 'facility_id' : 'provider_id';

  const result = await query<{ count: string; claimants: string[] }>(
    `SELECT COUNT(*)::text AS count,
            array_agg(DISTINCT claimant_id::text) AS claimants
     FROM public.${table}
     WHERE ${col} = $1 AND status IN ('submitted', 'under_review')`,
    [entityId],
  );

  return {
    pendingCount: Number(result.rows[0]?.count ?? 0),
    claimantIds: result.rows[0]?.claimants ?? [],
    isDuplicate: Number(result.rows[0]?.count ?? 0) > 1,
  };
}
