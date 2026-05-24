import { query } from './db.js';
import { ForbiddenError, ValidationError } from './errors.js';
import { normalizeEmail, normalizeZimbabwePhone } from './supabase-auth.js';

export type OtpContext = 'staff' | 'mobile' | 'recovery';
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

function assertExistingProfile(profile: ProfileRow | null): ProfileRow {
  if (!profile) {
    throw new ForbiddenError('Unable to send verification code');
  }
  return profile;
}

export async function resolveOtpSend(input: OtpSendInput): Promise<ResolvedOtpSend> {
  const requestedChannel = input.channel ?? (input.context === 'mobile' ? undefined : 'email');

  if (input.context === 'staff') {
    if (requestedChannel === 'phone') {
      const email = input.email ? normalizeEmail(input.email) : null;
      let profile: ProfileRow | null = null;

      if (email) {
        profile = assertStaffProfile(await findProfileByEmail(email));
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
    const profile = assertStaffProfile(await findProfileByEmail(email));
    return {
      channel: 'email',
      identifier: email,
      maskedDestination: maskEmail(email),
      createUser: false,
      authUserId: profile.id,
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
    return { channel: 'email', identifier: normalizeEmail(input.email) };
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
