import { query } from './db.js';
import { ConflictError, ForbiddenError, ValidationError } from './errors.js';
import { normalizeEmail, normalizeZimbabwePhone } from './supabase-auth.js';

export type OtpContext = 'staff' | 'mobile' | 'recovery' | 'practitioner';
export type OtpChannel = 'email' | 'phone';
export type OtpDeliveryChannel = 'email' | 'sms';

const STAFF_ROLES = new Set(['super_admin', 'facility_admin', 'doctor', 'receptionist']);

export interface OtpSendInput {
  context: OtpContext;
  email?: string;
  phone?: string;
  channel?: OtpChannel;
}

export interface ResolvedOtpSend {
  channel: OtpDeliveryChannel;
  identifier: string;
  maskedDestination: string;
  createUser: boolean;
  authUserId?: string;
}

interface ProfileRow {
  id: string;
  email: string | null;
  phone: string | null;
  primary_role: string;
}

export function maskEmail(email: string): string {
  const [local, domain] = email.split('@');
  if (!domain || !local) return '***';
  return `${local.charAt(0)}***@${domain}`;
}

export function maskPhone(phone: string): string {
  if (phone.length <= 7) return '***';
  return `${phone.slice(0, 4)}***${phone.slice(-3)}`;
}

async function findProfileByEmail(email: string): Promise<ProfileRow | null> {
  const result = await query<ProfileRow>(
    `SELECT id, email, phone, primary_role::text AS primary_role
     FROM public.profiles
     WHERE lower(email) = $1 AND is_active = true
     LIMIT 1`,
    [email],
  );
  return result.rows[0] ?? null;
}

async function findProfileByPhone(phone: string): Promise<ProfileRow | null> {
  const result = await query<ProfileRow>(
    `SELECT id, email, phone, primary_role::text AS primary_role
     FROM public.profiles
     WHERE phone = $1 AND is_active = true
     LIMIT 1`,
    [phone],
  );
  return result.rows[0] ?? null;
}

function assertStaffProfile(profile: ProfileRow | null): ProfileRow {
  if (!profile || !STAFF_ROLES.has(profile.primary_role)) {
    throw new ForbiddenError('Unable to send verification code');
  }
  return profile;
}

interface StaffLoginResolution {
  profile: ProfileRow;
  otpEmail: string;
}

/** Staff login by work email, including MDPCZ registry email on an already-claimed provider. */
async function resolveStaffLoginByEmail(email: string): Promise<StaffLoginResolution | null> {
  const normalized = normalizeEmail(email);

  const direct = await findProfileByEmail(normalized);
  if (direct && STAFF_ROLES.has(direct.primary_role)) {
    return { profile: direct, otpEmail: direct.email ?? normalized };
  }

  const provider = await query<{
    owner_id: string | null;
    profile_id: string | null;
    is_claimed: boolean;
  }>(
    `SELECT owner_id, profile_id, is_claimed
     FROM public.providers
     WHERE LOWER(email) = $1
       AND deleted_at IS NULL
       AND is_active = true
       AND import_source = 'MDPCZ'
     ORDER BY name
     LIMIT 1`,
    [normalized],
  );
  const row = provider.rows[0];
  if (!row?.is_claimed) return null;

  const userId = row.profile_id ?? row.owner_id;
  if (!userId) return null;

  const ownerResult = await query<ProfileRow>(
    `SELECT id, email, phone, primary_role::text AS primary_role
     FROM public.profiles
     WHERE id = $1 AND is_active = true`,
    [userId],
  );
  const owner = ownerResult.rows[0];
  if (!owner) return null;

  return { profile: owner, otpEmail: normalized };
}

function assertExistingProfile(profile: ProfileRow | null): ProfileRow {
  if (!profile) {
    throw new ForbiddenError('Unable to send verification code');
  }
  return profile;
}

async function assertPractitionerRegistryEmail(email: string): Promise<void> {
  const result = await query<{ is_claimed: boolean }>(
    `SELECT is_claimed FROM public.providers
     WHERE LOWER(email) = $1
       AND deleted_at IS NULL
       AND is_active = true
       AND import_source = 'MDPCZ'
     ORDER BY name
     LIMIT 1`,
    [email],
  );
  if (!result.rows[0]) {
    throw new ForbiddenError('No practitioner profile found for this email address');
  }
  if (result.rows[0].is_claimed) {
    throw new ConflictError(
      'This practitioner profile is already claimed. Use facility portal login instead.',
    );
  }
}

export async function resolveOtpSend(input: OtpSendInput): Promise<ResolvedOtpSend> {
  const requestedChannel = input.channel ?? (input.context === 'mobile' ? undefined : 'email');

  if (input.context === 'practitioner') {
    if (!input.email) {
      throw new ValidationError('Email is required');
    }
    const email = normalizeEmail(input.email);
    await assertPractitionerRegistryEmail(email);
    return {
      channel: 'email',
      identifier: email,
      maskedDestination: maskEmail(email),
      createUser: true,
    };
  }

  if (input.context === 'staff') {
    if (requestedChannel === 'phone') {
      const email = input.email ? normalizeEmail(input.email) : null;
      let profile: ProfileRow | null = null;

      if (email) {
        const resolved = await resolveStaffLoginByEmail(email);
        const profile = resolved?.profile ?? assertStaffProfile(await findProfileByEmail(email));
        if (!profile.phone) {
          throw new ValidationError('No registered phone number is linked to this account');
        }
        return {
          channel: 'sms',
          identifier: profile.phone,
          maskedDestination: maskPhone(profile.phone),
          createUser: false,
        };
      }

      if (!input.phone) {
        throw new ValidationError('Email or phone is required');
      }
      const phone = normalizeZimbabwePhone(input.phone);
      profile = assertStaffProfile(await findProfileByPhone(phone));
      return {
        channel: 'sms',
        identifier: phone,
        maskedDestination: maskPhone(phone),
        createUser: false,
      };
    }

    if (!input.email) {
      throw new ValidationError('Email is required');
    }
    const email = normalizeEmail(input.email);
    const resolved = await resolveStaffLoginByEmail(email);
    if (!resolved) {
      throw new ForbiddenError('Unable to send verification code');
    }
    return {
      channel: 'email',
      identifier: resolved.otpEmail,
      maskedDestination: maskEmail(resolved.otpEmail),
      createUser: false,
      authUserId: resolved.profile.id,
    };
  }

  if (input.context === 'recovery') {
    if (requestedChannel === 'phone') {
      const email = input.email ? normalizeEmail(input.email) : null;
      if (email) {
        const profile = assertExistingProfile(await findProfileByEmail(email));
        if (!profile.phone) {
          throw new ValidationError('No registered phone number is linked to this account');
        }
        return {
          channel: 'sms',
          identifier: profile.phone,
          maskedDestination: maskPhone(profile.phone),
          createUser: false,
        };
      }
      if (!input.phone) {
        throw new ValidationError('Email or phone is required');
      }
      const phone = normalizeZimbabwePhone(input.phone);
      assertExistingProfile(await findProfileByPhone(phone));
      return {
        channel: 'sms',
        identifier: phone,
        maskedDestination: maskPhone(phone),
        createUser: false,
      };
    }

    if (!input.email) {
      throw new ValidationError('Email is required');
    }
    const email = normalizeEmail(input.email);
    const profile = assertExistingProfile(await findProfileByEmail(email));
    return {
      channel: 'email',
      identifier: email,
      maskedDestination: maskEmail(email),
      createUser: false,
      authUserId: profile.id,
    };
  }

  const channel = requestedChannel ?? 'phone';

  if (channel === 'email') {
    if (!input.email) {
      throw new ValidationError('Email is required');
    }
    const email = normalizeEmail(input.email);
    return {
      channel: 'email',
      identifier: email,
      maskedDestination: maskEmail(email),
      createUser: true,
    };
  }

  if (!input.phone) {
    throw new ValidationError('Phone is required');
  }
  const phone = normalizeZimbabwePhone(input.phone);
  return {
    channel: 'sms',
    identifier: phone,
    maskedDestination: maskPhone(phone),
    createUser: true,
  };
}

export interface OtpVerifyInput {
  context: OtpContext;
  email?: string;
  phone?: string;
  channel: OtpChannel;
}

export async function resolveOtpVerify(input: OtpVerifyInput): Promise<{
  channel: OtpDeliveryChannel;
  identifier: string;
}> {
  if (input.channel === 'email') {
    if (!input.email) {
      throw new ValidationError('Email is required');
    }
    const email = normalizeEmail(input.email);
    if (input.context === 'staff') {
      const resolved = await resolveStaffLoginByEmail(email);
      if (resolved) {
        return { channel: 'email', identifier: resolved.otpEmail };
      }
    }
    return { channel: 'email', identifier: email };
  }

  if (input.context === 'staff' || input.context === 'recovery') {
    const email = input.email ? normalizeEmail(input.email) : null;
    if (email) {
      const profile =
        input.context === 'staff'
          ? assertStaffProfile(await findProfileByEmail(email))
          : assertExistingProfile(await findProfileByEmail(email));
      if (!profile.phone) {
        throw new ValidationError('No registered phone number is linked to this account');
      }
      return { channel: 'sms', identifier: profile.phone };
    }
  }

  if (!input.phone) {
    throw new ValidationError('Phone is required');
  }
  return { channel: 'sms', identifier: normalizeZimbabwePhone(input.phone) };
}

export function lockoutIdentifier(
  channel: OtpDeliveryChannel,
  identifier: string,
): string {
  return `${channel}:${identifier}`;
}
