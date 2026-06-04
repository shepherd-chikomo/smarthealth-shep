import { query } from '../lib/db.js';
import { ConflictError, ForbiddenError, NotFoundError } from '../lib/errors.js';
import { requireFacilityAdmin } from '../lib/facility-access.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { logPermissionAudit } from '../lib/audit-log.js';
import type { RequestContext } from '../lib/request-context.js';

export async function invitePractitionerByRegNumber(
  user: AuthenticatedUser,
  facilityId: string,
  registrationNumber: string,
  context?: RequestContext,
) {
  await requireFacilityAdmin(user, facilityId);

  const reg = registrationNumber.trim().toUpperCase();
  const provider = await query<{
    id: string;
    name: string;
    is_verified: boolean;
    is_claimed: boolean;
    profile_id: string | null;
  }>(
    `SELECT id, name, is_verified, is_claimed, profile_id
     FROM public.providers
     WHERE (registration_number = $1 OR mdpcz_number = $1) AND deleted_at IS NULL`,
    [reg],
  );

  if (!provider.rows[0]) throw new NotFoundError('Practitioner', reg);
  if (!provider.rows[0].is_verified || !provider.rows[0].is_claimed) {
    throw new ConflictError('Practitioner must claim and verify their profile before they can be invited');
  }
  if (!provider.rows[0].profile_id) {
    throw new ConflictError('Practitioner must claim their profile before they can be invited');
  }

  const existing = await query(
    `SELECT id FROM public.provider_facility_links WHERE provider_id = $1 AND facility_id = $2`,
    [provider.rows[0].id, facilityId],
  );
  if (existing.rows[0]) throw new ConflictError('Practitioner is already linked to this facility');

  const invite = await query<{ id: string }>(
    `INSERT INTO public.facility_practitioner_invitations (
       facility_id, provider_id, invited_by
     ) VALUES ($1, $2, $3)
     RETURNING id`,
    [facilityId, provider.rows[0].id, user.id],
  );

  await query(
    `INSERT INTO public.notifications (user_id, channel, status, title, body, payload)
     VALUES ($1, 'in_app', 'pending', 'Facility invitation',
             $2, $3::jsonb)`,
    [
      provider.rows[0].profile_id,
      `You have been invited to join a facility on SmartHealth`,
      JSON.stringify({
        invitationId: invite.rows[0].id,
        facilityId,
        type: 'practitioner_invitation',
      }),
    ],
  );

  await logPermissionAudit(
    user.id,
    'invitation.create',
    'facility_practitioner_invitation',
    invite.rows[0].id,
    facilityId,
    context,
    { providerId: provider.rows[0].id },
  );

  return {
    invitationId: invite.rows[0].id,
    providerName: provider.rows[0].name,
  };
}

export async function respondToPractitionerInvitation(
  userId: string,
  invitationId: string,
  action: 'accept' | 'decline',
) {
  const invite = await query<{
    id: string;
    facility_id: string;
    provider_id: string;
    status: string;
  }>(
    `SELECT fpi.id, fpi.facility_id, fpi.provider_id, fpi.status
     FROM public.facility_practitioner_invitations fpi
     JOIN public.providers p ON p.id = fpi.provider_id
     WHERE fpi.id = $1 AND p.profile_id = $2`,
    [invitationId, userId],
  );

  if (!invite.rows[0]) throw new NotFoundError('Invitation', invitationId);
  if (invite.rows[0].status !== 'pending') throw new ConflictError('Invitation is no longer pending');

  const newStatus = action === 'accept' ? 'accepted' : 'declined';
  await query(
    `UPDATE public.facility_practitioner_invitations SET status = $2::public.invitation_status, responded_at = timezone('utc', now())
     WHERE id = $1`,
    [invitationId, newStatus],
  );

  if (action === 'accept') {
    await query(
      `INSERT INTO public.provider_facility_links (
         provider_id, facility_id, link_type, is_primary, is_facility_role_holder, match_confidence
       ) VALUES ($1, $2, 'affiliated', false, false, 'HIGH')
       ON CONFLICT (provider_id, facility_id) DO NOTHING`,
      [invite.rows[0].provider_id, invite.rows[0].facility_id],
    );

    await query(
      `UPDATE public.providers SET
         facility_id = COALESCE(facility_id, $2),
         tenant_id = COALESCE(tenant_id, $2)
       WHERE id = $1`,
      [invite.rows[0].provider_id, invite.rows[0].facility_id],
    );

    await query(
      `INSERT INTO public.facility_memberships (facility_id, user_id, role)
       VALUES ($1, $2, 'doctor')
       ON CONFLICT (facility_id, user_id) DO UPDATE SET role = 'doctor'`,
      [invite.rows[0].facility_id, userId],
    );
  }

  return { status: newStatus };
}

export async function listMyInvitations(userId: string) {
  const rows = await query(
    `SELECT fpi.id, fpi.status, fpi.created_at, f.name AS facility_name, f.city AS facility_city
     FROM public.facility_practitioner_invitations fpi
     JOIN public.providers p ON p.id = fpi.provider_id
     JOIN public.facilities f ON f.id = fpi.facility_id
     WHERE p.profile_id = $1 AND fpi.status = 'pending'
     ORDER BY fpi.created_at DESC`,
    [userId],
  );

  return {
    invitations: rows.rows.map((r) => ({
      id: r.id,
      facilityName: r.facility_name,
      facilityCity: r.facility_city,
      status: r.status,
      createdAt: r.created_at,
    })),
  };
}

export async function inviteFacilityAdminByEmail(
  user: AuthenticatedUser,
  facilityId: string,
  email: string,
  context?: RequestContext,
) {
  await requireFacilityAdmin(user, facilityId);

  const normalizedEmail = email.trim().toLowerCase();
  const invite = await query<{ id: string }>(
    `INSERT INTO public.facility_admin_invitations (facility_id, email, invited_by)
     VALUES ($1, $2, $3)
     RETURNING id`,
    [facilityId, normalizedEmail, user.id],
  );

  const existingProfile = await query<{ id: string }>(
    `SELECT id FROM public.profiles WHERE lower(email) = $1 LIMIT 1`,
    [normalizedEmail],
  );

  if (existingProfile.rows[0]) {
    await query(
      `INSERT INTO public.notifications (user_id, channel, status, title, body, payload)
       VALUES ($1, 'in_app', 'pending', 'Facility admin invitation', $2, $3::jsonb)`,
      [
        existingProfile.rows[0].id,
        'You have been invited as a facility administrator',
        JSON.stringify({ invitationId: invite.rows[0].id, facilityId, type: 'admin_invitation' }),
      ],
    );
  }

  await logPermissionAudit(
    user.id,
    'invitation.create',
    'facility_admin_invitation',
    invite.rows[0].id,
    facilityId,
    context,
    { email: normalizedEmail },
  );

  return { invitationId: invite.rows[0].id };
}

export async function acceptFacilityAdminInvitation(userId: string, invitationId: string) {
  const invite = await query<{ id: string; facility_id: string; email: string; status: string }>(
    `SELECT id, facility_id, email, status FROM public.facility_admin_invitations WHERE id = $1`,
    [invitationId],
  );
  if (!invite.rows[0]) throw new NotFoundError('Invitation', invitationId);
  if (invite.rows[0].status !== 'pending') throw new ConflictError('Invitation is no longer pending');

  const profile = await query<{ email: string | null }>(
    `SELECT email FROM public.profiles WHERE id = $1`,
    [userId],
  );
  if (profile.rows[0]?.email?.toLowerCase() !== invite.rows[0].email.toLowerCase()) {
    throw new ForbiddenError('Invitation email does not match your account');
  }

  await query(
    `INSERT INTO public.facility_memberships (facility_id, user_id, role)
     VALUES ($1, $2, 'facility_admin')
     ON CONFLICT (facility_id, user_id) DO UPDATE SET role = 'facility_admin'`,
    [invite.rows[0].facility_id, userId],
  );

  await query(
    `UPDATE public.profiles SET primary_role = 'facility_admin' WHERE id = $1`,
    [userId],
  );

  await query(
    `UPDATE public.facility_admin_invitations SET status = 'accepted', accepted_user_id = $2, responded_at = timezone('utc', now())
     WHERE id = $1`,
    [invitationId, userId],
  );

  return { facilityId: invite.rows[0].facility_id };
}

export async function removeInvitedPractitioner(
  user: AuthenticatedUser,
  facilityId: string,
  providerId: string,
  context?: RequestContext,
) {
  await requireFacilityAdmin(user, facilityId);

  const isOwner = await query<{ is_owner: boolean }>(
    `SELECT EXISTS (
       SELECT 1 FROM public.facilities f
       JOIN public.providers p ON p.owner_id = f.owner_id
       WHERE f.id = $1 AND p.id = $2
     ) AS is_owner`,
    [facilityId, providerId],
  );
  if (isOwner.rows[0]?.is_owner) {
    throw new ForbiddenError('Cannot remove the facility owner');
  }

  await query(
    `DELETE FROM public.provider_facility_links
     WHERE facility_id = $1 AND provider_id = $2 AND link_type = 'affiliated'`,
    [facilityId, providerId],
  );

  const provider = await query<{ profile_id: string | null }>(
    `SELECT profile_id FROM public.providers WHERE id = $1`,
    [providerId],
  );
  if (provider.rows[0]?.profile_id) {
    await query(
      `DELETE FROM public.facility_memberships WHERE facility_id = $1 AND user_id = $2 AND role = 'doctor'`,
      [facilityId, provider.rows[0].profile_id],
    );
  }

  await logPermissionAudit(
    user.id,
    'permission.revoke',
    'provider_facility_link',
    providerId,
    facilityId,
    context,
  );

  return { removed: true };
}

export async function listPendingAdminInvitations(userId: string) {
  const profile = await query<{ email: string | null }>(
    `SELECT email FROM public.profiles WHERE id = $1`,
    [userId],
  );
  if (!profile.rows[0]?.email) return { invitations: [] };

  const rows = await query(
    `SELECT fai.id, fai.facility_id, f.name AS facility_name, fai.created_at
     FROM public.facility_admin_invitations fai
     JOIN public.facilities f ON f.id = fai.facility_id
     WHERE fai.email = $1 AND fai.status = 'pending'
     ORDER BY fai.created_at DESC`,
    [profile.rows[0].email.toLowerCase()],
  );

  return {
    invitations: rows.rows.map((r) => ({
      id: r.id,
      facilityId: r.facility_id,
      facilityName: r.facility_name,
      createdAt: r.created_at,
    })),
  };
}
