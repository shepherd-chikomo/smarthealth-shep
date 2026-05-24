import { randomUUID } from 'node:crypto';
import { query } from '../lib/db.js';
import { ConflictError, NotFoundError, ForbiddenError } from '../lib/errors.js';
import { sendEmailOtp, verifyEmailOtp } from '../lib/supabase-auth.js';

export interface LinkedFacilitySummary {
  id: string;
  name: string;
  city: string | null;
  isClaimed: boolean;
  isVerified: boolean;
  canClaimOwnership: boolean;
  isOwnedByMe?: boolean;
}

export interface ProviderLookupSummary {
  id: string;
  name: string;
  specialty: string | null;
  registrationNumber: string | null;
}

function splitProviderName(fullName: string): { firstName: string; lastName: string } {
  const parts = fullName.trim().split(/\s+/);
  if (parts.length <= 1) return { firstName: parts[0] ?? '', lastName: '' };
  return { firstName: parts[0], lastName: parts.slice(1).join(' ') };
}

async function getLinkedRoleHolderFacilities(
  providerId: string,
  userId?: string,
): Promise<LinkedFacilitySummary[]> {
  if (!userId) {
    const facilities = await query<{
      id: string;
      name: string;
      city: string | null;
      is_claimed: boolean;
      is_verified: boolean;
    }>(
      `SELECT f.id, f.name, f.city, f.is_claimed, f.is_verified
       FROM public.provider_facility_links pfl
       JOIN public.facilities f ON f.id = pfl.facility_id AND f.deleted_at IS NULL
       WHERE pfl.provider_id = $1
         AND pfl.link_type = 'primary'
         AND pfl.is_facility_role_holder = true
       ORDER BY f.name`,
      [providerId],
    );

    return facilities.rows.map((f) => ({
      id: f.id,
      name: f.name,
      city: f.city,
      isClaimed: f.is_claimed,
      isVerified: f.is_verified,
      canClaimOwnership: !f.is_claimed,
      isOwnedByMe: false,
    }));
  }

  const facilities = await query<{
    id: string;
    name: string;
    city: string | null;
    is_claimed: boolean;
    is_verified: boolean;
    is_owned_by_me: boolean;
  }>(
    `SELECT f.id, f.name, f.city, f.is_claimed, f.is_verified,
            EXISTS (
              SELECT 1 FROM public.facility_memberships fm
              WHERE fm.facility_id = f.id
                AND fm.user_id = $2
                AND fm.role = 'facility_admin'::public.app_role
            ) AS is_owned_by_me
     FROM public.provider_facility_links pfl
     JOIN public.facilities f ON f.id = pfl.facility_id AND f.deleted_at IS NULL
     WHERE pfl.provider_id = $1
       AND pfl.link_type = 'primary'
       AND pfl.is_facility_role_holder = true
     ORDER BY f.name`,
    [providerId, userId],
  );

  return facilities.rows.map((f) => ({
    id: f.id,
    name: f.name,
    city: f.city,
    isClaimed: f.is_claimed,
    isVerified: f.is_verified,
    canClaimOwnership: !f.is_claimed,
    isOwnedByMe: f.is_owned_by_me,
  }));
}

export async function lookupProviderByEmail(email: string) {
  const normalized = email.trim().toLowerCase();
  if (!normalized) return { matched: false as const };

  const providers = await query<{
    id: string;
    name: string;
    specialty: string | null;
    registration_number: string | null;
    is_claimed: boolean;
    owner_id: string | null;
  }>(
    `SELECT id, name, specialty, registration_number, is_claimed, owner_id
     FROM public.providers
     WHERE LOWER(email) = $1
       AND deleted_at IS NULL
       AND is_active = true
       AND import_source = 'MDPCZ'
     ORDER BY name`,
    [normalized],
  );

  if (providers.rows.length === 0) {
    return { matched: false as const };
  }

  if (providers.rows.length > 1) {
    return {
      matched: true as const,
      ambiguous: true as const,
      providers: providers.rows.map((row) => ({
        id: row.id,
        name: row.name,
        specialty: row.specialty,
        registrationNumber: row.registration_number,
        isClaimed: row.is_claimed,
      })),
    };
  }

  const row = providers.rows[0];
  const provider: ProviderLookupSummary = {
    id: row.id,
    name: row.name,
    specialty: row.specialty,
    registrationNumber: row.registration_number,
  };

  if (row.is_claimed) {
    return {
      matched: true as const,
      alreadyClaimed: true as const,
      provider,
    };
  }

  const linkedFacilities = await getLinkedRoleHolderFacilities(row.id);
  return {
    matched: true as const,
    alreadyClaimed: false as const,
    provider,
    linkedFacilities,
  };
}

export async function claimProviderByVerifiedEmail(userId: string, email: string) {
  const normalizedEmail = email.trim().toLowerCase();

  const owned = await query<{ id: string; name: string }>(
    `SELECT id, name FROM public.providers
     WHERE owner_id = $1 AND is_claimed = true AND deleted_at IS NULL
     LIMIT 1`,
    [userId],
  );
  if (owned.rows[0]) {
    const linkedFacilities = await getLinkedRoleHolderFacilities(owned.rows[0].id, userId);
    return {
      providerId: owned.rows[0].id,
      providerName: owned.rows[0].name,
      alreadyClaimed: true,
      linkedFacilities,
    };
  }

  const lookup = await lookupProviderByEmail(normalizedEmail);
  if (!lookup.matched) {
    throw new NotFoundError('Provider', normalizedEmail);
  }
  if ('ambiguous' in lookup && lookup.ambiguous) {
    throw new ConflictError('Multiple practitioner profiles match this email. Contact support.');
  }
  if (lookup.alreadyClaimed) {
    throw new ConflictError('This practitioner profile is already claimed by another account');
  }

  const providerId = lookup.provider!.id;
  const providerName = lookup.provider!.name;

  await query(
    `UPDATE public.providers SET
       profile_id = $2,
       owner_id = $2,
       is_claimed = true,
       is_verified = true,
       verified_status = 'verified',
       verification_status = 'verified',
       verified_at = timezone('utc', now())
     WHERE id = $1`,
    [providerId, userId],
  );

  const { firstName, lastName } = splitProviderName(providerName);
  await query(
    `UPDATE public.profiles SET
       primary_role = CASE
         WHEN primary_role = 'patient'::public.app_role THEN 'doctor'::public.app_role
         ELSE primary_role
       END,
       first_name = COALESCE(NULLIF(TRIM(first_name), ''), $2),
       last_name = COALESCE(NULLIF(TRIM(last_name), ''), $3),
       email = COALESCE(NULLIF(TRIM(email), ''), $4)
     WHERE id = $1`,
    [userId, firstName || null, lastName || null, normalizedEmail],
  );

  const linkedFacilities = await getLinkedRoleHolderFacilities(providerId, userId);
  return {
    providerId,
    providerName,
    alreadyClaimed: false,
    linkedFacilities,
  };
}

export async function getPractitionerOnboardingStatus(userId: string) {
  const provider = await query<{ id: string; name: string; specialty: string | null }>(
    `SELECT id, name, specialty FROM public.providers
     WHERE owner_id = $1 AND is_claimed = true AND deleted_at IS NULL
     LIMIT 1`,
    [userId],
  );

  if (!provider.rows[0]) {
    return { phase: 'unclaimed' as const };
  }

  const linkedFacilities = await getLinkedRoleHolderFacilities(provider.rows[0].id, userId);
  const ownedCount = linkedFacilities.filter((f) => f.isOwnedByMe).length;

  if (ownedCount > 0) {
    return {
      phase: 'has_facilities' as const,
      provider: provider.rows[0],
      linkedFacilities,
    };
  }

  return {
    phase: 'profile_claimed' as const,
    provider: provider.rows[0],
    linkedFacilities,
  };
}

function normalizeSpecialty(value: string | null | undefined): string {
  return String(value ?? '').trim().toLowerCase().replace(/\s+/g, ' ');
}

async function specialtyMatches(
  providerSpecialty: string | null,
  providerSpecialtyId: string | null,
  submitted: string,
): Promise<boolean> {
  const normalized = normalizeSpecialty(submitted);
  if (!normalized) return false;
  if (normalizeSpecialty(providerSpecialty) === normalized) return true;

  const alias = await query<{ specialty_id: string; name: string }>(
    `SELECT sa.specialty_id, s.name
     FROM public.specialty_aliases sa
     JOIN public.specialties s ON s.id = sa.specialty_id
     WHERE sa.alias_normalized = $1 LIMIT 1`,
    [normalized],
  );
  if (!alias.rows[0]) return false;

  if (providerSpecialtyId && providerSpecialtyId === alias.rows[0].specialty_id) return true;
  return normalizeSpecialty(providerSpecialty) === normalizeSpecialty(alias.rows[0].name);
}

export async function validatePractitionerClaimCredentials(data: {
  registrationNumber: string;
  email: string;
  specialty: string;
}): Promise<{ providerId: string; providerName: string }> {
  const reg = data.registrationNumber.trim().toUpperCase();
  const email = data.email.trim().toLowerCase();

  const result = await query<{
    id: string;
    name: string;
    email: string | null;
    specialty: string | null;
    specialty_id: string | null;
    is_claimed: boolean;
  }>(
    `SELECT id, name, email, specialty, specialty_id, is_claimed
     FROM public.providers
     WHERE (registration_number = $1 OR mdpcz_number = $1)
       AND deleted_at IS NULL AND is_active = true`,
    [reg],
  );

  const provider = result.rows[0];
  if (!provider) throw new NotFoundError('Provider', reg);
  if (provider.is_claimed) throw new ConflictError('This practitioner profile is already claimed');
  if (!provider.email) {
    throw new ConflictError(
      'No email on file. Please contact validation@smarthealth.co.zw for manual verification.',
    );
  }
  if (provider.email.toLowerCase() !== email) {
    throw new ConflictError('Email does not match our records');
  }

  const specOk = await specialtyMatches(provider.specialty, provider.specialty_id, data.specialty);
  if (!specOk) throw new ConflictError('Specialty does not match our records');

  return { providerId: provider.id, providerName: provider.name };
}

export async function initiatePractitionerClaimOtp(data: {
  registrationNumber: string;
  email: string;
  specialty: string;
}): Promise<{ sessionId: string; message: string }> {
  const { providerId } = await validatePractitionerClaimCredentials(data);
  const email = data.email.trim().toLowerCase();

  await sendEmailOtp(email, true);

  const sessionId = randomUUID();
  await query(
    `INSERT INTO public.practitioner_claim_sessions (
       id, provider_id, registration_number, email, specialty_normalized, expires_at
     ) VALUES ($1, $2, $3, $4, $5, timezone('utc', now()) + interval '15 minutes')`,
    [
      sessionId,
      providerId,
      data.registrationNumber.trim().toUpperCase(),
      email,
      normalizeSpecialty(data.specialty),
    ],
  );

  return { sessionId, message: 'OTP sent to registered email address' };
}

export async function completePractitionerClaimOtp(data: {
  sessionId: string;
  otp: string;
  userId: string;
}): Promise<{ providerId: string; primaryFacilities: unknown[] }> {
  const session = await query<{
    id: string;
    provider_id: string;
    email: string;
    expires_at: Date;
    otp_verified: boolean;
  }>(
    `SELECT id, provider_id, email, expires_at, otp_verified
     FROM public.practitioner_claim_sessions WHERE id = $1`,
    [data.sessionId],
  );

  if (!session.rows[0]) throw new NotFoundError('Claim session', data.sessionId);
  if (new Date(session.rows[0].expires_at) < new Date()) {
    throw new ConflictError('Claim session expired');
  }

  await verifyEmailOtp(session.rows[0].email, data.otp);

  await query(
    `UPDATE public.providers SET
       profile_id = $2,
       owner_id = $2,
       is_claimed = true,
       is_verified = true,
       verified_status = 'verified',
       verification_status = 'verified',
       verified_at = timezone('utc', now())
     WHERE id = $1`,
    [session.rows[0].provider_id, data.userId],
  );

  await query(
    `UPDATE public.practitioner_claim_sessions SET otp_verified = true, claimed_by = $2 WHERE id = $1`,
    [data.sessionId, data.userId],
  );

  const facilities = await query(
    `SELECT f.id, f.name, f.city, f.is_claimed, f.is_verified, pfl.is_facility_role_holder
     FROM public.provider_facility_links pfl
     JOIN public.facilities f ON f.id = pfl.facility_id
     WHERE pfl.provider_id = $1 AND pfl.link_type = 'primary' AND pfl.is_facility_role_holder = true
     ORDER BY f.name`,
    [session.rows[0].provider_id],
  );

  return {
    providerId: session.rows[0].provider_id,
    primaryFacilities: facilities.rows.map((f) => ({
      id: f.id,
      name: f.name,
      city: f.city,
      isClaimed: f.is_claimed,
      isVerified: f.is_verified,
      canClaimOwnership: true,
    })),
  };
}

export async function checkRegistryEmailMatch(userId: string, userEmail?: string | null) {
  let email = userEmail?.trim().toLowerCase() ?? null;
  if (!email) {
    const profile = await query<{ email: string | null }>(
      `SELECT email FROM public.profiles WHERE id = $1`,
      [userId],
    );
    email = profile.rows[0]?.email?.trim().toLowerCase() ?? null;
  }
  if (!email) return { matched: false as const, skipDocuments: false as const };

  const lookup = await lookupProviderByEmail(email);
  if (!lookup.matched || ('ambiguous' in lookup && lookup.ambiguous) || lookup.alreadyClaimed) {
    return { matched: false as const, skipDocuments: false as const };
  }

  return {
    matched: true as const,
    skipDocuments: true as const,
    provider: {
      id: lookup.provider!.id,
      name: lookup.provider!.name,
      specialty: lookup.provider!.specialty,
      registrationNumber: lookup.provider!.registrationNumber,
    },
    linkedFacilities: lookup.linkedFacilities ?? [],
  };
}

export async function submitManualValidationTicket(data: {
  registrationNumber: string;
  specialty: string;
  submitterName?: string;
  submitterEmail?: string;
  submitterPhone?: string;
  evidence?: Record<string, unknown>;
}): Promise<{ ticketId: string }> {
  const reg = data.registrationNumber.trim().toUpperCase();

  const provider = await query<{ id: string; email: string | null }>(
    `SELECT id, email FROM public.providers
     WHERE (registration_number = $1 OR mdpcz_number = $1) AND deleted_at IS NULL`,
    [reg],
  );

  const result = await query<{ id: string }>(
    `INSERT INTO public.manual_validation_tickets (
       provider_id, registration_number, specialty,
       submitter_name, submitter_email, submitter_phone, evidence
     ) VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb)
     RETURNING id`,
    [
      provider.rows[0]?.id ?? null,
      reg,
      data.specialty,
      data.submitterName ?? null,
      data.submitterEmail ?? null,
      data.submitterPhone ?? null,
      JSON.stringify(data.evidence ?? {}),
    ],
  );

  return { ticketId: result.rows[0].id };
}

export async function listManualValidationTickets(
  opts: { page: number; limit: number; status?: string },
) {
  const offset = (opts.page - 1) * opts.limit;
  const params: unknown[] = [];
  let idx = 1;
  const conditions = ['TRUE'];
  if (opts.status) {
    conditions.push(`mvt.status = $${idx++}`);
    params.push(opts.status);
  }

  const rows = await query(
    `SELECT mvt.*, p.name AS provider_name
     FROM public.manual_validation_tickets mvt
     LEFT JOIN public.providers p ON p.id = mvt.provider_id
     WHERE ${conditions.join(' AND ')}
     ORDER BY mvt.created_at DESC
     LIMIT $${idx++} OFFSET $${idx}`,
    [...params, opts.limit, offset],
  );

  return {
    tickets: rows.rows.map((r) => ({
      id: r.id,
      providerId: r.provider_id,
      providerName: r.provider_name,
      registrationNumber: r.registration_number,
      specialty: r.specialty,
      submitterName: r.submitter_name,
      submitterEmail: r.submitter_email,
      status: r.status,
      mdpczNotes: r.mdpcz_notes,
      createdAt: r.created_at,
    })),
  };
}

export async function approveManualValidationTicket(
  adminUserId: string,
  ticketId: string,
  data: { mdpczNotes?: string; claimantId: string },
): Promise<{ providerId: string }> {
  const ticket = await query<{ provider_id: string | null; registration_number: string }>(
    `SELECT provider_id, registration_number FROM public.manual_validation_tickets WHERE id = $1`,
    [ticketId],
  );
  if (!ticket.rows[0]) throw new NotFoundError('Ticket', ticketId);

  let providerId = ticket.rows[0].provider_id;
  if (!providerId) {
    const p = await query<{ id: string }>(
      `SELECT id FROM public.providers WHERE registration_number = $1 OR mdpcz_number = $1 LIMIT 1`,
      [ticket.rows[0].registration_number],
    );
    providerId = p.rows[0]?.id ?? null;
  }
  if (!providerId) throw new NotFoundError('Provider', ticket.rows[0].registration_number);

  await query(
    `UPDATE public.providers SET
       profile_id = $2, owner_id = $2, is_claimed = true, is_verified = true,
       verified_status = 'verified', verification_status = 'verified', verified_at = timezone('utc', now())
     WHERE id = $1`,
    [providerId, data.claimantId],
  );

  await query(
    `UPDATE public.manual_validation_tickets SET
       status = 'approved', mdpcz_notes = $2, reviewed_by = $3, reviewed_at = timezone('utc', now()),
       claimant_id = $4
     WHERE id = $1`,
    [ticketId, data.mdpczNotes ?? null, adminUserId, data.claimantId],
  );

  return { providerId };
}

export async function getMyPrimaryFacilities(userId: string) {
  const provider = await query<{ id: string }>(
    `SELECT id FROM public.providers WHERE owner_id = $1 AND is_claimed = true LIMIT 1`,
    [userId],
  );
  if (!provider.rows[0]) return { facilities: [] };

  const linkedFacilities = await getLinkedRoleHolderFacilities(provider.rows[0].id, userId);
  return {
    facilities: linkedFacilities.map((f) => ({
      id: f.id,
      name: f.name,
      city: f.city,
      isClaimed: f.isClaimed,
      isVerified: f.isVerified,
      canClaimOwnership: f.canClaimOwnership,
      isOwnedByMe: f.isOwnedByMe ?? false,
    })),
  };
}

export async function assertPrimaryRoleHolder(userId: string, facilityId: string): Promise<void> {
  const check = await query<{ ok: boolean }>(
    `SELECT EXISTS (
       SELECT 1 FROM public.providers p
       JOIN public.provider_facility_links pfl ON pfl.provider_id = p.id
       WHERE p.owner_id = $1 AND pfl.facility_id = $2
         AND pfl.link_type = 'primary' AND pfl.is_facility_role_holder = true
     ) AS ok`,
    [userId, facilityId],
  );
  if (!check.rows[0]?.ok) {
    throw new ForbiddenError('Only the HPA primary role-holder may claim this facility');
  }
}
