import { query } from '../lib/db.js';
import { env } from '../config.js';
import { AppError, ConflictError, ForbiddenError, NotFoundError, ValidationError } from '../lib/errors.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { isSuperAdmin } from '../lib/rbac.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { adminOffset, buildSearchClause, type AdminListQuery } from '../lib/admin-query.js';
import { logAdminAudit, logPermissionAudit } from '../lib/audit-log.js';
import { normalizeZimbabwePhone } from '../lib/supabase-auth.js';
import type { RequestContext } from '../lib/request-context.js';

function facilityScope(user: AuthenticatedUser, facilityId?: string): {
  clause: string;
  params: unknown[];
} {
  if (isSuperAdmin(user)) {
    if (facilityId) return { clause: 'tenant_id = $1', params: [facilityId] };
    return { clause: 'TRUE', params: [] };
  }
  return {
    clause: `tenant_id IN (
      SELECT facility_id FROM public.facility_memberships
      WHERE user_id = $1 AND role IN ('facility_admin', 'receptionist', 'doctor')
    )`,
    params: [user.id],
  };
}

export async function getAdminProfile(userId: string) {
  const result = await query<{
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
  if (!result.rows[0]) throw new NotFoundError('Admin profile', userId);

  const facilities = await query<{ facility_id: string; name: string; role: string }>(
    `SELECT fm.facility_id, f.name, fm.role::text
     FROM public.facility_memberships fm
     JOIN public.facilities f ON f.id = fm.facility_id
     WHERE fm.user_id = $1`,
    [userId],
  );

  return {
    id: result.rows[0].id,
    role: result.rows[0].primary_role,
    firstName: result.rows[0].first_name,
    lastName: result.rows[0].last_name,
    email: result.rows[0].email,
    phone: result.rows[0].phone,
    facilities: facilities.rows.map((r) => ({
      id: r.facility_id,
      name: r.name,
      role: r.role,
    })),
  };
}

export async function getDashboardStats(user: AuthenticatedUser) {
  const scope = facilityScope(user);
  const p = scope.params;

  const [appointments, walkIns, providers, revenue] = await Promise.all([
    query<{ count: string }>(
      `SELECT COUNT(*)::text AS count FROM public.appointments a
       WHERE a.deleted_at IS NULL AND ${scope.clause.replace(/tenant_id/g, 'a.tenant_id')}`,
      p,
    ),
    query<{ count: string; avg_wait: string | null }>(
      `SELECT COUNT(*)::text AS count,
              AVG(estimated_wait_minutes)::text AS avg_wait
       FROM public.walk_in_sessions w
       WHERE w.deleted_at IS NULL AND w.registered_at >= now() - interval '24 hours'
         AND ${scope.clause.replace(/tenant_id/g, 'w.tenant_id')}`,
      p,
    ),
    query<{ count: string; verified: string }>(
      `SELECT COUNT(*)::text AS count,
              COUNT(*) FILTER (WHERE p.is_verified)::text AS verified
       FROM public.providers p
       JOIN public.facilities f ON f.id = p.facility_id
       WHERE p.is_active = true AND ${scope.clause.replace(/tenant_id/g, 'f.tenant_id')}`,
      p,
    ),
    query<{ total: string }>(
      `SELECT COALESCE(SUM(net_revenue_cents), 0)::text AS total
       FROM public.revenue_reports r
       WHERE r.report_date >= date_trunc('month', now())::date
         AND ${scope.clause.replace(/tenant_id/g, 'r.tenant_id')}`,
      p,
    ),
  ]);

  return {
    appointmentsToday: Number(appointments.rows[0]?.count ?? 0),
    walkIns24h: Number(walkIns.rows[0]?.count ?? 0),
    avgWaitMinutes: walkIns.rows[0]?.avg_wait
      ? Math.round(Number(walkIns.rows[0].avg_wait))
      : null,
    providersTotal: Number(providers.rows[0]?.count ?? 0),
    providersVerified: Number(providers.rows[0]?.verified ?? 0),
    revenueMonthCents: Number(revenue.rows[0]?.total ?? 0),
    updatedAt: new Date().toISOString(),
  };
}

export async function listFacilityAdmins(user: AuthenticatedUser, opts: AdminListQuery) {
  const params: unknown[] = [];
  let idx = 1;
  const conditions = ["fm.role = 'facility_admin'"];

  if (!isSuperAdmin(user)) {
    conditions.push(`fm.facility_id IN (
      SELECT facility_id FROM public.facility_memberships WHERE user_id = $${idx++}
    )`);
    params.push(user.id);
  } else if (opts.facilityId) {
    conditions.push(`fm.facility_id = $${idx++}`);
    params.push(opts.facilityId);
  }

  const search = buildSearchClause(
    ['p.first_name', 'p.last_name', 'p.email', 'f.name'],
    opts.q,
    params,
    idx,
  );
  idx = search.nextIdx;
  conditions.push(search.clause);

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM public.facility_memberships fm
     JOIN public.profiles p ON p.id = fm.user_id
     JOIN public.facilities f ON f.id = fm.facility_id
     WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT fm.id, fm.facility_id, f.name AS facility_name,
            p.id AS user_id, p.first_name, p.last_name, p.email, p.phone,
            fm.joined_at
     FROM public.facility_memberships fm
     JOIN public.profiles p ON p.id = fm.user_id
     JOIN public.facilities f ON f.id = fm.facility_id
     WHERE ${where}
     ORDER BY fm.joined_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    admins: rows.rows.map((r) => ({
      id: r.id,
      facilityId: r.facility_id,
      facilityName: r.facility_name,
      userId: r.user_id,
      firstName: r.first_name,
      lastName: r.last_name,
      email: r.email,
      phone: r.phone,
      joinedAt: (r.joined_at as Date).toISOString(),
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function createFacilityAdmin(
  user: AuthenticatedUser,
  data: { userId: string; facilityId: string },
  context?: RequestContext,
) {
  if (!isSuperAdmin(user)) throw new ForbiddenError('Super admin access required');

  await query(
    `UPDATE public.profiles SET primary_role = 'facility_admin' WHERE id = $1`,
    [data.userId],
  );

  const result = await query(
    `INSERT INTO public.facility_memberships (facility_id, user_id, role)
     VALUES ($1, $2, 'facility_admin')
     ON CONFLICT (facility_id, user_id) DO UPDATE SET role = 'facility_admin'
     RETURNING id`,
    [data.facilityId, data.userId],
  );

  const membershipId = result.rows[0].id as string;
  await logPermissionAudit(
    user.id,
    'permission.grant',
    'facility_admin',
    membershipId,
    data.facilityId,
    context,
    { targetUserId: data.userId },
  );
  await logAdminAudit(
    user.id,
    'admin.facility_admin.create',
    'facility_membership',
    membershipId,
    context,
    { targetUserId: data.userId, facilityId: data.facilityId },
    data.facilityId,
  );

  return { id: membershipId };
}

export async function removeFacilityAdmin(
  user: AuthenticatedUser,
  membershipId: string,
  context?: RequestContext,
) {
  if (!isSuperAdmin(user)) throw new ForbiddenError('Super admin access required');
  await query('DELETE FROM public.facility_memberships WHERE id = $1', [membershipId]);
  await logPermissionAudit(
    user.id,
    'permission.revoke',
    'facility_admin',
    membershipId,
    null,
    context,
  );
  await logAdminAudit(user.id, 'admin.facility_admin.remove', 'facility_membership', membershipId, context);
}

export async function listPlatformAdmins(user: AuthenticatedUser, opts: AdminListQuery) {
  if (!isSuperAdmin(user)) throw new ForbiddenError('Super admin access required');

  const params: unknown[] = [];
  let idx = 1;
  const conditions = ["p.primary_role = 'super_admin'"];

  const search = buildSearchClause(
    ['p.first_name', 'p.last_name', 'p.email', 'p.phone'],
    opts.q,
    params,
    idx,
  );
  idx = search.nextIdx;
  conditions.push(search.clause);

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.profiles p WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT p.id, p.first_name, p.last_name, p.email, p.phone, p.is_active,
            p.created_at, p.updated_at
     FROM public.profiles p
     WHERE ${where}
     ORDER BY p.updated_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    admins: rows.rows.map((r) => ({
      id: r.id,
      firstName: r.first_name,
      lastName: r.last_name,
      email: r.email,
      phone: r.phone,
      isActive: r.is_active,
      createdAt: (r.created_at as Date).toISOString(),
      updatedAt: (r.updated_at as Date).toISOString(),
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
    body: JSON.stringify({
      phone,
      phone_confirm: true,
      user_metadata: { registered_by: 'admin_portal' },
    }),
  });

  const data = (await response.json()) as { id?: string; msg?: string; message?: string };
  if (!response.ok) {
    throw new AppError(
      response.status,
      'ADMIN_USER_CREATE_ERROR',
      data.msg ?? data.message ?? 'Failed to create user account',
    );
  }
  return data.id!;
}

async function resolvePlatformAdminTarget(data: {
  userId?: string;
  phone?: string;
  email?: string;
  firstName?: string;
  lastName?: string;
}): Promise<string> {
  if (data.userId) {
    const existing = await query<{ id: string }>(
      `SELECT id FROM public.profiles WHERE id = $1`,
      [data.userId],
    );
    if (!existing.rows[0]) throw new NotFoundError('User', data.userId);
    return data.userId;
  }

  const normalizedPhone = data.phone ? normalizeZimbabwePhone(data.phone) : null;
  const email = data.email?.trim().toLowerCase() ?? null;

  if (!normalizedPhone && !email) {
    throw new ValidationError('Provide a user ID, phone number, or email address');
  }

  if (normalizedPhone) {
    const byPhone = await query<{ id: string }>(
      `SELECT id FROM public.profiles WHERE phone = $1`,
      [normalizedPhone],
    );
    if (byPhone.rows[0]) return byPhone.rows[0].id;

    const userId = await createAuthUserWithPhone(normalizedPhone);
    await query(
      `INSERT INTO public.profiles (id, primary_role, first_name, last_name, phone, email)
       VALUES ($1, 'patient', $2, $3, $4, $5)
       ON CONFLICT (id) DO UPDATE SET
         phone = COALESCE(EXCLUDED.phone, profiles.phone),
         email = COALESCE(EXCLUDED.email, profiles.email),
         first_name = COALESCE(EXCLUDED.first_name, profiles.first_name),
         last_name = COALESCE(EXCLUDED.last_name, profiles.last_name)`,
      [userId, data.firstName ?? null, data.lastName ?? null, normalizedPhone, email],
    );
    return userId;
  }

  const byEmail = await query<{ id: string }>(
    `SELECT id FROM public.profiles WHERE lower(email) = $1`,
    [email],
  );
  if (!byEmail.rows[0]) {
    throw new NotFoundError('User with email', email ?? undefined);
  }
  return byEmail.rows[0].id;
}

export async function promotePlatformAdmin(
  user: AuthenticatedUser,
  data: {
    userId?: string;
    phone?: string;
    email?: string;
    firstName?: string;
    lastName?: string;
  },
  context?: RequestContext,
) {
  if (!isSuperAdmin(user)) throw new ForbiddenError('Super admin access required');

  const targetUserId = await resolvePlatformAdminTarget(data);

  const existing = await query<{ primary_role: string }>(
    `SELECT primary_role FROM public.profiles WHERE id = $1`,
    [targetUserId],
  );
  if (!existing.rows[0]) throw new NotFoundError('User', targetUserId);
  if (existing.rows[0].primary_role === 'super_admin') {
    throw new ConflictError('User is already a platform administrator');
  }

  await query(
    `UPDATE public.profiles
     SET primary_role = 'super_admin',
         first_name = COALESCE($2, first_name),
         last_name = COALESCE($3, last_name),
         email = COALESCE($4, email),
         is_active = true,
         updated_at = timezone('utc', now())
     WHERE id = $1`,
    [targetUserId, data.firstName ?? null, data.lastName ?? null, data.email?.trim().toLowerCase() ?? null],
  );

  await logPermissionAudit(
    user.id,
    'permission.grant',
    'super_admin',
    targetUserId,
    null,
    context,
    { targetUserId },
  );
  await logAdminAudit(
    user.id,
    'admin.platform_admin.promote',
    'profile',
    targetUserId,
    context,
    { targetUserId },
  );

  return { id: targetUserId };
}

export async function revokePlatformAdmin(
  user: AuthenticatedUser,
  targetUserId: string,
  context?: RequestContext,
) {
  if (!isSuperAdmin(user)) throw new ForbiddenError('Super admin access required');

  if (targetUserId === user.id) {
    throw new ValidationError('You cannot revoke your own platform administrator access');
  }

  const target = await query<{ primary_role: string }>(
    `SELECT primary_role FROM public.profiles WHERE id = $1`,
    [targetUserId],
  );
  if (!target.rows[0]) throw new NotFoundError('User', targetUserId);
  if (target.rows[0].primary_role !== 'super_admin') {
    throw new NotFoundError('Platform administrator', targetUserId);
  }

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.profiles WHERE primary_role = 'super_admin'`,
  );
  if (Number(count.rows[0]?.count ?? 0) <= 1) {
    throw new ValidationError('Cannot revoke the last platform administrator');
  }

  await query(
    `UPDATE public.profiles
     SET primary_role = 'patient',
         updated_at = timezone('utc', now())
     WHERE id = $1`,
    [targetUserId],
  );

  await logPermissionAudit(
    user.id,
    'permission.revoke',
    'super_admin',
    targetUserId,
    null,
    context,
    { targetUserId },
  );
  await logAdminAudit(
    user.id,
    'admin.platform_admin.revoke',
    'profile',
    targetUserId,
    context,
    { targetUserId },
  );
}

export async function listLiveQueues(user: AuthenticatedUser, opts: AdminListQuery) {
  const scope = facilityScope(user, opts.facilityId);
  const params = [...scope.params];
  let idx = params.length + 1;
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.walk_in_sessions w
     WHERE w.deleted_at IS NULL AND w.status NOT IN ('completed', 'cancelled')
       AND ${scope.clause.replace(/tenant_id/g, 'w.tenant_id')}`,
    params,
  );

  const rows = await query(
    `SELECT w.id, w.ticket_number, w.status, w.queue_status, w.priority,
            w.estimated_wait_minutes, w.registered_at, w.chief_complaint,
            w.facility_id, f.name AS facility_name,
            p.name AS provider_name,
            pr.first_name || ' ' || COALESCE(pr.last_name, '') AS patient_name
     FROM public.walk_in_sessions w
     JOIN public.facilities f ON f.id = w.facility_id
     LEFT JOIN public.providers p ON p.id = w.provider_id
     JOIN public.profiles pr ON pr.id = w.patient_id
     WHERE w.deleted_at IS NULL AND w.status NOT IN ('completed', 'cancelled')
       AND ${scope.clause.replace(/tenant_id/g, 'w.tenant_id')}
     ORDER BY w.priority DESC, w.ticket_number ASC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    queue: rows.rows.map(mapWalkIn),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function getQueueStats(user: AuthenticatedUser, facilityId?: string) {
  const scope = facilityScope(user, facilityId);
  const result = await query(
    `SELECT
       COUNT(*) FILTER (WHERE queue_status = 'waiting')::int AS waiting,
       COUNT(*) FILTER (WHERE queue_status = 'in_progress')::int AS in_progress,
       COUNT(*) FILTER (WHERE queue_status = 'completed')::int AS completed_today,
       AVG(estimated_wait_minutes) FILTER (WHERE queue_status = 'waiting') AS avg_wait,
       MAX(priority) AS max_priority
     FROM public.walk_in_sessions w
     WHERE w.deleted_at IS NULL
       AND w.registered_at >= date_trunc('day', now())
       AND ${scope.clause.replace(/tenant_id/g, 'w.tenant_id')}`,
    scope.params,
  );
  return result.rows[0];
}

export async function moderateQueueEntry(
  user: AuthenticatedUser,
  id: string,
  action: 'cancel' | 'flag' | 'priority',
  data?: { priority?: number; reason?: string },
  context?: RequestContext,
) {
  if (action === 'cancel') {
    await query(
      `UPDATE public.walk_in_sessions
       SET status = 'cancelled', queue_status = 'cancelled',
           notes = COALESCE(notes, '') || $2, updated_at = now()
       WHERE id = $1`,
      [id, data?.reason ? `\n[Moderated] ${data.reason}` : ''],
    );
  } else if (action === 'flag') {
    await query(
      `UPDATE public.walk_in_sessions
       SET metadata = metadata || $2::jsonb, updated_at = now()
       WHERE id = $1`,
      [id, JSON.stringify({ flagged: true, flaggedBy: user.id, reason: data?.reason })],
    );
  } else if (action === 'priority') {
    await query(
      `UPDATE public.walk_in_sessions SET priority = $2, updated_at = now() WHERE id = $1`,
      [id, data?.priority ?? 0],
    );
  }

  await logAdminAudit(
    user.id,
    `admin.queue.${action}`,
    'walk_in_session',
    id,
    context,
    { reason: data?.reason, priority: data?.priority },
  );
}

export async function listProvidersAdmin(user: AuthenticatedUser, opts: AdminListQuery) {
  const params: unknown[] = [];
  let idx = 1;
  const conditions = ['p.is_active = true', 'p.deleted_at IS NULL'];

  if (!isSuperAdmin(user)) {
    conditions.push(`EXISTS (
      SELECT 1 FROM public.provider_facility_links pfl
      JOIN public.facility_memberships fm ON fm.facility_id = pfl.facility_id
      WHERE pfl.provider_id = p.id AND fm.user_id = $${idx++}
    )`);
    params.push(user.id);
  } else if (opts.facilityId) {
    conditions.push(`EXISTS (
      SELECT 1 FROM public.provider_facility_links pfl
      WHERE pfl.provider_id = p.id AND pfl.facility_id = $${idx++}
    )`);
    params.push(opts.facilityId);
  }

  if (opts.status === 'verified') conditions.push('p.is_verified = true');
  if (opts.status === 'unverified') conditions.push('p.is_verified = false');
  if (opts.status === 'suspended') conditions.push("p.metadata->>'suspended' = 'true'");

  const search = buildSearchClause(
    [
      'p.name',
      'p.first_name',
      'p.last_name',
      'p.specialty',
      'p.mdpcz_number',
      'p.registration_number',
      'p.email',
    ],
    opts.q,
    params,
    idx,
  );
  idx = search.nextIdx;
  conditions.push(search.clause);

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.providers p WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT p.id, p.name, p.title, p.first_name, p.last_name, p.specialty, p.gender::text AS gender,
            p.qualification, p.email, p.phone, p.registration_number, p.mdpcz_number,
            p.is_verified, p.is_accepting_bookings, p.verified_status, p.import_source,
            hpaf.facility_id AS hpa_facility_id, hpaf.facility_name AS hpa_facility_name,
            COALESCE(pr.avg_rating, 0) AS avg_rating,
            COALESCE(pr.review_count, 0)::int AS review_count,
            p.metadata, p.updated_at
     FROM public.providers p
     LEFT JOIN LATERAL (
       SELECT f.id AS facility_id, f.name AS facility_name
       FROM public.provider_facility_links pfl
       JOIN public.facilities f ON f.id = pfl.facility_id
         AND f.deleted_at IS NULL AND f.import_source = 'HPA'
       WHERE pfl.provider_id = p.id
       ORDER BY pfl.is_primary DESC, pfl.is_facility_role_holder DESC, pfl.created_at ASC
       LIMIT 1
     ) hpaf ON true
     LEFT JOIN (
       SELECT provider_id, AVG(rating)::numeric(3,2) AS avg_rating, COUNT(*) AS review_count
       FROM public.provider_reviews WHERE deleted_at IS NULL GROUP BY provider_id
     ) pr ON pr.provider_id = p.id
     WHERE ${where}
     ORDER BY p.name ASC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    providers: rows.rows.map((r) => ({
      id: r.id,
      name: r.name,
      title: r.title,
      firstName: r.first_name,
      lastName: r.last_name,
      specialty: r.specialty,
      gender: r.gender,
      qualification: r.qualification,
      email: r.email,
      phone: r.phone,
      registrationNumber: r.registration_number ?? r.mdpcz_number,
      mdpczNumber: r.mdpcz_number,
      isVerified: r.is_verified,
      verifiedStatus: r.verified_status,
      importSource: r.import_source,
      isAcceptingBookings: r.is_accepting_bookings,
      facilityId: r.hpa_facility_id,
      facilityName: r.hpa_facility_name ?? null,
      averageRating: Number(r.avg_rating),
      reviewCount: r.review_count,
      isSuspended: (r.metadata as Record<string, unknown>)?.suspended === true,
      updatedAt: (r.updated_at as Date).toISOString(),
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function updateProviderAdmin(
  user: AuthenticatedUser,
  id: string,
  data: {
    title?: string | null;
    firstName?: string;
    lastName?: string;
    specialty?: string | null;
    email?: string | null;
    phone?: string | null;
    gender?: 'male' | 'female' | 'other' | null;
    qualification?: string | null;
    registrationNumber?: string | null;
  },
  context?: RequestContext,
) {
  const existing = await query<{ id: string; title: string | null; first_name: string | null; last_name: string | null }>(
    `SELECT id, title, first_name, last_name FROM public.providers WHERE id = $1 AND deleted_at IS NULL`,
    [id],
  );
  if (!existing.rows[0]) throw new NotFoundError('Provider', id);

  const row = existing.rows[0];
  const firstName = data.firstName?.trim() ?? row.first_name;
  const lastName = data.lastName?.trim() ?? row.last_name;
  const title = data.title !== undefined ? data.title : row.title;
  const fullName = [title, firstName, lastName].filter(Boolean).join(' ');

  const sets = ['name = $2', 'updated_at = now()'];
  const values: unknown[] = [id, fullName];
  let idx = 3;

  if (data.title !== undefined) {
    sets.push(`title = $${idx++}`);
    values.push(data.title);
  }
  if (data.firstName !== undefined) {
    sets.push(`first_name = $${idx++}`);
    values.push(data.firstName.trim());
  }
  if (data.lastName !== undefined) {
    sets.push(`last_name = $${idx++}`);
    values.push(data.lastName.trim());
  }
  if (data.specialty !== undefined) {
    sets.push(`specialty = $${idx++}`);
    values.push(data.specialty);
  }
  if (data.email !== undefined) {
    sets.push(`email = $${idx++}`);
    values.push(data.email);
  }
  if (data.phone !== undefined) {
    sets.push(`phone = $${idx++}`);
    values.push(data.phone ? normalizeZimbabwePhone(data.phone) : null);
  }
  if (data.gender !== undefined) {
    sets.push(`gender = $${idx++}::public.gender`);
    values.push(data.gender);
  }
  if (data.qualification !== undefined) {
    sets.push(`qualification = $${idx++}`);
    values.push(data.qualification);
  }
  if (data.registrationNumber !== undefined) {
    const reg = data.registrationNumber.trim().toUpperCase().replace(/\s+/g, '');
    sets.push(`registration_number = $${idx++}`, `mdpcz_number = $${idx++}`);
    values.push(reg, reg);
  }

  await query(`UPDATE public.providers SET ${sets.join(', ')} WHERE id = $1`, values);

  await logAdminAudit(user.id, 'admin.provider.update', 'provider', id, context, data);
  return { message: 'Updated' };
}

export async function verifyProvider(
  user: AuthenticatedUser,
  id: string,
  verified: boolean,
  context?: RequestContext,
) {
  await query(
    `UPDATE public.providers SET is_verified = $2, updated_at = now() WHERE id = $1`,
    [id, verified],
  );
  await logAdminAudit(
    user.id,
    verified ? 'admin.provider.verify' : 'admin.provider.unverify',
    'provider',
    id,
    context,
    { verified },
  );
}

export async function suspendProvider(
  user: AuthenticatedUser,
  id: string,
  suspended: boolean,
  reason?: string,
  context?: RequestContext,
) {
  await query(
    `UPDATE public.providers
     SET is_accepting_bookings = $2,
         metadata = metadata || $3::jsonb,
         updated_at = now()
     WHERE id = $1`,
    [id, !suspended, JSON.stringify({ suspended, suspendedReason: reason, suspendedBy: user.id })],
  );
  await logAdminAudit(
    user.id,
    suspended ? 'admin.provider.suspend' : 'admin.provider.unsuspend',
    'provider',
    id,
    context,
    { reason },
  );
}

export async function listSpecialties(opts: AdminListQuery) {
  const params: unknown[] = [];
  let idx = 1;
  const search = buildSearchClause(['name', 'category', 'description'], opts.q, params, idx);
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.specialties WHERE is_active = true AND ${search.clause}`,
    params,
  );

  const rows = await query(
    `SELECT id, name, slug, category, description, is_active
     FROM public.specialties WHERE is_active = true AND ${search.clause}
     ORDER BY name ASC LIMIT $${search.nextIdx++} OFFSET $${search.nextIdx}`,
    [...params, opts.limit, offset],
  );

  return {
    specialties: rows.rows,
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function listAppointmentsAdmin(user: AuthenticatedUser, opts: AdminListQuery) {
  const scope = facilityScope(user, opts.facilityId);
  const params = [...scope.params];
  let idx = params.length + 1;
  const conditions = ['a.deleted_at IS NULL', scope.clause.replace(/tenant_id/g, 'a.tenant_id')];

  if (opts.status) {
    conditions.push(`a.status = $${idx++}::public.appointment_status`);
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
    ['a.reference_number', 'p.name', 'f.name'],
    opts.q,
    params,
    idx,
  );
  idx = search.nextIdx;
  conditions.push(search.clause);

  const where = conditions.join(' AND ');
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM public.appointments a
     JOIN public.providers p ON p.id = a.provider_id
     JOIN public.facilities f ON f.id = a.facility_id
     WHERE ${where}`,
    params,
  );

  const rows = await query(
    `SELECT a.id, a.reference_number, a.status, a.scheduled_at, a.duration_minutes,
            a.cancellation_reason, a.created_at,
            p.name AS provider_name, f.name AS facility_name
     FROM public.appointments a
     JOIN public.providers p ON p.id = a.provider_id
     JOIN public.facilities f ON f.id = a.facility_id
     WHERE ${where}
     ORDER BY a.scheduled_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    appointments: rows.rows.map((r) => ({
      id: r.id,
      referenceNumber: r.reference_number,
      status: r.status,
      scheduledAt: (r.scheduled_at as Date).toISOString(),
      durationMinutes: r.duration_minutes,
      cancellationReason: r.cancellation_reason,
      providerName: r.provider_name,
      facilityName: r.facility_name,
      createdAt: (r.created_at as Date).toISOString(),
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function getBookingAnalytics(user: AuthenticatedUser, facilityId?: string) {
  const scope = facilityScope(user, facilityId);
  const result = await query(
    `SELECT
       date_trunc('day', scheduled_at)::date AS day,
       COUNT(*)::int AS total,
       COUNT(*) FILTER (WHERE status = 'cancelled')::int AS cancelled,
       COUNT(*) FILTER (WHERE status = 'completed')::int AS completed
     FROM public.appointments a
     WHERE a.deleted_at IS NULL
       AND a.scheduled_at >= now() - interval '30 days'
       AND ${scope.clause.replace(/tenant_id/g, 'a.tenant_id')}
     GROUP BY 1 ORDER BY 1`,
    scope.params,
  );
  return { series: result.rows };
}

export async function listOperatingHours(user: AuthenticatedUser, _opts: AdminListQuery) {
  const params: unknown[] = [];
  let idx = 1;
  const conditions = ['TRUE'];

  if (!isSuperAdmin(user)) {
    conditions.push(`pwh.provider_id IN (
      SELECT pr.id FROM public.providers pr
      WHERE pr.facility_id IN (
        SELECT facility_id FROM public.facility_memberships WHERE user_id = $${idx++}
      )
    )`);
    params.push(user.id);
  }

  const rows = await query(
    `SELECT pwh.id, pwh.provider_id, p.name AS provider_name, pwh.day_of_week,
            pwh.opens_at, pwh.closes_at, pwh.is_closed
     FROM public.provider_working_hours pwh
     JOIN public.providers p ON p.id = pwh.provider_id
     WHERE ${conditions.join(' AND ')}
     ORDER BY p.name, pwh.day_of_week`,
    params,
  );

  return { hours: rows.rows };
}

export async function upsertOperatingHours(data: {
  providerId: string;
  dayOfWeek: number;
  opensAt?: string;
  closesAt?: string;
  isClosed?: boolean;
}) {
  await query(
    `INSERT INTO public.provider_working_hours (provider_id, day_of_week, opens_at, closes_at, is_closed)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (provider_id, day_of_week) DO UPDATE SET
       opens_at = EXCLUDED.opens_at, closes_at = EXCLUDED.closes_at,
       is_closed = EXCLUDED.is_closed`,
    [data.providerId, data.dayOfWeek, data.opensAt ?? null, data.closesAt ?? null, data.isClosed ?? false],
  );
}

export async function listAppSettings(scope: string, tenantId?: string | null) {
  const result = await query(
    `SELECT id, scope, key, value, description, is_public, tenant_id
     FROM public.app_settings
     WHERE scope = $1 AND (tenant_id IS NOT DISTINCT FROM $2)
     ORDER BY key`,
    [scope, tenantId ?? null],
  );
  return result.rows;
}

export async function upsertAppSetting(data: {
  scope: string;
  key: string;
  value: unknown;
  description?: string;
  isPublic?: boolean;
  tenantId?: string | null;
}) {
  await query(
    `INSERT INTO public.app_settings (scope, key, value, description, is_public, tenant_id)
     VALUES ($1, $2, $3::jsonb, $4, $5, $6)
     ON CONFLICT (tenant_id, scope, key) DO UPDATE SET
       value = EXCLUDED.value, description = EXCLUDED.description,
       is_public = EXCLUDED.is_public, updated_at = now()`,
    [
      data.scope,
      data.key,
      JSON.stringify(data.value),
      data.description ?? null,
      data.isPublic ?? false,
      data.tenantId ?? null,
    ],
  );
}

export async function listEmergencyServicesAdmin(opts: AdminListQuery) {
  const params: unknown[] = [];
  const search = buildSearchClause(['name', 'city', 'phone'], opts.q, params, 1);
  const offset = adminOffset(opts.page, opts.limit);

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.emergency_services
     WHERE deleted_at IS NULL AND ${search.clause}`,
    params,
  );

  const rows = await query(
    `SELECT id, name, service_type, phone, alternate_phone, address, city, province,
            latitude, longitude, is_24_hours, is_active
     FROM public.emergency_services
     WHERE deleted_at IS NULL AND ${search.clause}
     ORDER BY name LIMIT $${search.nextIdx++} OFFSET $${search.nextIdx}`,
    [...params, opts.limit, offset],
  );

  return {
    services: rows.rows.map(mapEmergencyServiceRow),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

function mapEmergencyServiceRow(row: Record<string, unknown>) {
  return {
    id: row.id,
    name: row.name,
    serviceType: row.service_type,
    phone: row.phone,
    alternatePhone: row.alternate_phone ?? null,
    address: row.address ?? null,
    city: row.city,
    province: row.province,
    latitude: row.latitude,
    longitude: row.longitude,
    is24Hours: row.is_24_hours,
    isActive: row.is_active,
  };
}

export async function createEmergencyService(data: {
  name: string;
  serviceType: string;
  phone: string;
  alternatePhone?: string | null;
  address?: string | null;
  city: string;
  province: string;
  latitude: number;
  longitude: number;
  is24Hours?: boolean;
  isActive?: boolean;
}) {
  const result = await query(
    `INSERT INTO public.emergency_services (
       name, service_type, phone, alternate_phone, address, city, province,
       latitude, longitude, is_24_hours, is_active
     ) VALUES ($1, $2::public.emergency_service_type, $3, $4, $5, $6, $7::public.zimbabwe_province,
               $8, $9, $10, $11)
     RETURNING id, name, service_type, phone, alternate_phone, address, city, province,
               latitude, longitude, is_24_hours, is_active`,
    [
      data.name.trim(),
      data.serviceType,
      data.phone.trim(),
      data.alternatePhone?.trim() ?? null,
      data.address?.trim() ?? null,
      data.city.trim(),
      data.province,
      data.latitude,
      data.longitude,
      data.is24Hours ?? true,
      data.isActive ?? true,
    ],
  );
  return { service: mapEmergencyServiceRow(result.rows[0]) };
}

export async function updateEmergencyService(
  id: string,
  data: {
    name?: string;
    serviceType?: string;
    phone?: string;
    alternatePhone?: string | null;
    address?: string | null;
    city?: string;
    province?: string;
    latitude?: number;
    longitude?: number;
    is24Hours?: boolean;
    isActive?: boolean;
  },
) {
  const existing = await query(`SELECT id FROM public.emergency_services WHERE id = $1 AND deleted_at IS NULL`, [id]);
  if (!existing.rows[0]) throw new NotFoundError('Emergency service', id);

  const result = await query(
    `UPDATE public.emergency_services SET
       name = COALESCE($2, name),
       service_type = COALESCE($3::public.emergency_service_type, service_type),
       phone = COALESCE($4, phone),
       alternate_phone = $5,
       address = $6,
       city = COALESCE($7, city),
       province = COALESCE($8::public.zimbabwe_province, province),
       latitude = COALESCE($9, latitude),
       longitude = COALESCE($10, longitude),
       is_24_hours = COALESCE($11, is_24_hours),
       is_active = COALESCE($12, is_active),
       updated_at = timezone('utc', now())
     WHERE id = $1
     RETURNING id, name, service_type, phone, alternate_phone, address, city, province,
               latitude, longitude, is_24_hours, is_active`,
    [
      id,
      data.name?.trim(),
      data.serviceType,
      data.phone?.trim(),
      data.alternatePhone?.trim() ?? null,
      data.address?.trim() ?? null,
      data.city?.trim(),
      data.province,
      data.latitude,
      data.longitude,
      data.is24Hours,
      data.isActive,
    ],
  );
  return { service: mapEmergencyServiceRow(result.rows[0]) };
}

export async function deleteEmergencyService(id: string) {
  const result = await query(
    `UPDATE public.emergency_services SET deleted_at = timezone('utc', now())
     WHERE id = $1 AND deleted_at IS NULL RETURNING id`,
    [id],
  );
  if (!result.rows[0]) throw new NotFoundError('Emergency service', id);
  return { id };
}

export async function listRevenueReports(user: AuthenticatedUser, opts: AdminListQuery) {
  const scope = facilityScope(user, opts.facilityId);
  const offset = adminOffset(opts.page, opts.limit);
  const params = [...scope.params];

  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.revenue_reports r WHERE ${scope.clause.replace(/tenant_id/g, 'r.tenant_id')}`,
    params,
  );

  const rows = await query(
    `SELECT r.id, r.report_date, r.period_type, r.net_revenue_cents AS total_cents,
            r.appointment_count, r.currency_code, f.name AS facility_name
     FROM public.revenue_reports r
     JOIN public.facilities f ON f.id = r.tenant_id
     WHERE ${scope.clause.replace(/tenant_id/g, 'r.tenant_id')}
     ORDER BY r.report_date DESC
     LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, opts.limit, offset],
  );

  return {
    reports: rows.rows,
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function exportReportCsv(
  user: AuthenticatedUser,
  type: 'revenue' | 'appointments' | 'usage',
): Promise<string> {
  if (type === 'revenue') {
    const { reports } = await listRevenueReports(user, { page: 1, limit: 1000, sortOrder: 'desc' });
    const header = 'facility,report_date,period_type,total_cents,appointments\n';
    const lines = reports.map(
      (r: Record<string, unknown>) =>
        `${r.facility_name},${r.report_date},${r.period_type},${r.total_cents},${r.appointment_count}`,
    );
    return header + lines.join('\n');
  }

  if (type === 'appointments') {
    const { appointments } = await listAppointmentsAdmin(user, { page: 1, limit: 1000, sortOrder: 'desc' });
    const header = 'reference,status,scheduled_at,provider,facility\n';
    const lines = appointments.map(
      (a) => `${a.referenceNumber},${a.status},${a.scheduledAt},${a.providerName},${a.facilityName}`,
    );
    return header + lines.join('\n');
  }

  const result = await query(
    `SELECT metric_date, metric_key, metric_value FROM public.usage_metrics
     ORDER BY metric_date DESC LIMIT 1000`,
  );
  const header = 'date,key,value\n';
  return header + result.rows.map((r) => `${r.metric_date},${r.metric_key},${r.metric_value}`).join('\n');
}

export async function listAuditLogs(user: AuthenticatedUser, opts: AdminListQuery) {
  const params: unknown[] = [];
  let idx = 1;
  const conditions = ['TRUE'];

  if (!isSuperAdmin(user)) {
    conditions.push(`facility_id IN (
      SELECT facility_id FROM public.facility_memberships WHERE user_id = $${idx++}
    )`);
    params.push(user.id);
  }

  const offset = adminOffset(opts.page, opts.limit);
  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM audit.logs WHERE ${conditions.join(' AND ')}`,
    params,
  );

  const rows = await query(
    `SELECT id, facility_id, actor_id, action, table_name, record_id, created_at
     FROM audit.logs WHERE ${conditions.join(' AND ')}
     ORDER BY created_at DESC LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    logs: rows.rows,
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

export async function listSecurityEvents(user: AuthenticatedUser, opts: AdminListQuery) {
  const params: unknown[] = [];
  let idx = 1;
  const conditions = ['TRUE'];

  if (opts.status === 'suspicious') {
    conditions.push("outcome = 'denied'");
  }

  if (!isSuperAdmin(user)) {
    conditions.push(`tenant_id IN (
      SELECT facility_id FROM public.facility_memberships WHERE user_id = $${idx++}
    )`);
    params.push(user.id);
  }

  const offset = adminOffset(opts.page, opts.limit);
  const countResult = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM audit.security_events WHERE ${conditions.join(' AND ')}`,
    params,
  );
  const total = Number(countResult.rows[0]?.count ?? 0);

  const rows = await query(
    `SELECT id, user_id, event_type, action, outcome, ip_address, created_at, details
     FROM audit.security_events WHERE ${conditions.join(' AND ')}
     ORDER BY created_at DESC LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return { events: rows.rows, pagination: buildPaginationMeta(opts.page, opts.limit, total) };
}

export async function listMedicalAccessLogs(user: AuthenticatedUser, opts: AdminListQuery) {
  const params: unknown[] = [];
  let idx = 1;
  const conditions = ['TRUE'];

  if (!isSuperAdmin(user)) {
    conditions.push(`tenant_id IN (
      SELECT facility_id FROM public.facility_memberships WHERE user_id = $${idx++}
    )`);
    params.push(user.id);
  }

  const offset = adminOffset(opts.page, opts.limit);
  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM audit.medical_access_logs WHERE ${conditions.join(' AND ')}`,
    params,
  );

  const rows = await query(
    `SELECT id, actor_id, patient_id, resource_type, resource_id, action,
            tenant_id, ip_address, created_at
     FROM audit.medical_access_logs WHERE ${conditions.join(' AND ')}
     ORDER BY created_at DESC LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    logs: rows.rows,
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}

function mapWalkIn(r: Record<string, unknown>) {
  return {
    id: r.id,
    ticketNumber: r.ticket_number,
    status: r.status,
    queueStatus: r.queue_status,
    priority: r.priority,
    estimatedWaitMinutes: r.estimated_wait_minutes,
    registeredAt: (r.registered_at as Date).toISOString(),
    chiefComplaint: r.chief_complaint,
    facilityId: r.facility_id,
    facilityName: r.facility_name,
    providerName: r.provider_name,
    patientName: r.patient_name,
  };
}
