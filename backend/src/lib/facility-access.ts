import { query } from './db.js';
import { ForbiddenError, NotFoundError } from './errors.js';
import type { AuthenticatedUser } from './auth.js';
import { isSuperAdmin } from './rbac.js';
import { logSecurityEvent } from './security-events.js';

export type FacilityRole = 'facility_admin' | 'doctor' | 'receptionist';

const FACILITY_STAFF_ROLES: FacilityRole[] = ['facility_admin', 'doctor', 'receptionist'];

export async function getUserFacilityMemberships(userId: string) {
  const result = await query<{
    facility_id: string;
    name: string;
    role: string;
    membership_id: string;
  }>(
    `SELECT fm.id AS membership_id, fm.facility_id, f.name, fm.role::text
     FROM public.facility_memberships fm
     JOIN public.facilities f ON f.id = fm.facility_id
     WHERE fm.user_id = $1 AND f.deleted_at IS NULL AND f.is_active = true
     ORDER BY fm.is_primary DESC, f.name ASC`,
    [userId],
  );
  return result.rows;
}

export async function assertFacilityAccess(
  user: AuthenticatedUser,
  facilityId: string,
  allowedRoles: FacilityRole[] = FACILITY_STAFF_ROLES,
  request?: { ip?: string | null; userAgent?: string | null; url?: string },
): Promise<{ role: FacilityRole }> {
  if (isSuperAdmin(user)) {
    return { role: 'facility_admin' };
  }

  const result = await query<{ role: string }>(
    `SELECT fm.role::text AS role
     FROM public.facility_memberships fm
     JOIN public.facilities f ON f.id = fm.facility_id
     WHERE fm.user_id = $1 AND fm.facility_id = $2
       AND f.deleted_at IS NULL AND f.is_active = true`,
    [user.id, facilityId],
  );

  const role = result.rows[0]?.role as FacilityRole | undefined;
  if (!role || !allowedRoles.includes(role)) {
    await logSecurityEvent({
      userId: user.id,
      eventType: 'access_denied',
      action: 'facility_access',
      outcome: 'denied',
      resourceType: 'facility',
      resourceId: facilityId,
      tenantId: facilityId,
      context: request
        ? { ipAddress: request.ip ?? null, userAgent: request.userAgent ?? null }
        : undefined,
      details: { route: request?.url, allowedRoles },
    });
    throw new ForbiddenError('You do not have access to this facility');
  }

  return { role };
}

export async function requireFacilityAdmin(
  user: AuthenticatedUser,
  facilityId: string,
): Promise<void> {
  await assertFacilityAccess(user, facilityId, ['facility_admin']);
}

export async function getFacilityOrThrow(facilityId: string) {
  const result = await query(
    `SELECT id, name, slug, facility_type, description, address_line1, address_line2,
            city, province, postal_code, phone, email, website, is_verified, is_active,
            settings, created_at, updated_at
     FROM public.facilities
     WHERE id = $1 AND deleted_at IS NULL`,
    [facilityId],
  );
  if (!result.rows[0]) throw new NotFoundError('Facility', facilityId);
  return result.rows[0];
}
