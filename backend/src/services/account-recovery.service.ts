import { query } from '../lib/db.js';
import { assertNotLocked, recordLoginAttempt } from '../lib/login-attempts.js';
import { logSecurityEvent } from '../lib/security-events.js';
import { revokeAllUserTokens } from '../lib/refresh-token-registry.js';
import type { RequestContext } from '../lib/request-context.js';
import {
  lockoutIdentifier,
  resolveOtpSend,
  resolveOtpVerify,
  type OtpSendInput,
} from '../lib/otp-policy.js';
import type { OtpVerifyBody } from '../schemas/common.js';
import {
  sendEmailOtp,
  sendPhoneOtp,
  verifyEmailOtp,
  verifyPhoneOtp,
} from '../lib/supabase-auth.js';

export async function initiateAccountRecovery(
  input: OtpSendInput,
  context?: RequestContext,
): Promise<{ message: string; channel: 'email' | 'sms'; destination: string }> {
  const resolved = await resolveOtpSend({ ...input, context: 'recovery' });
  const attemptKey = lockoutIdentifier(resolved.channel, resolved.identifier);
  await assertNotLocked(attemptKey, 'recovery', context);

  const profile = await query<{ id: string }>(
    resolved.channel === 'email'
      ? `SELECT id FROM public.profiles WHERE lower(email) = $1 AND is_active = true`
      : `SELECT id FROM public.profiles WHERE phone = $1 AND is_active = true`,
    [resolved.identifier],
  );

  if (profile.rows[0]) {
    if (resolved.channel === 'email') {
      await sendEmailOtp(resolved.identifier, false);
    } else {
      await sendPhoneOtp(resolved.identifier, false);
    }
    await logSecurityEvent({
      userId: profile.rows[0].id,
      eventType: 'account_recovery',
      action: 'initiate',
      outcome: 'allowed',
      context,
      details: { channel: resolved.channel },
    });
  }

  await recordLoginAttempt(attemptKey, 'recovery', true, context);
  return {
    message: 'If an account exists, a recovery code has been sent',
    channel: resolved.channel,
    destination: resolved.maskedDestination,
  };
}

export async function verifyAccountRecovery(
  input: OtpVerifyBody,
  context?: RequestContext,
): Promise<{
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  user: { id: string; phone?: string; email?: string };
}> {
  const resolved = await resolveOtpVerify({
    context: 'recovery',
    email: input.email,
    phone: input.phone,
    channel: input.channel,
  });
  const attemptKey = lockoutIdentifier(resolved.channel, resolved.identifier);
  await assertNotLocked(attemptKey, 'recovery', context);

  try {
    const result =
      resolved.channel === 'email'
        ? await verifyEmailOtp(resolved.identifier, input.otp)
        : await verifyPhoneOtp(resolved.identifier, input.otp);

    await revokeAllUserTokens(result.user.id);

    await recordLoginAttempt(attemptKey, 'recovery', true, context);
    await logSecurityEvent({
      userId: result.user.id,
      eventType: 'account_recovery',
      action: 'complete',
      outcome: 'allowed',
      context,
      details: { sessionsRevoked: true, channel: resolved.channel },
    });

    return {
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      expiresIn: result.expiresIn,
      user: result.user,
    };
  } catch (error) {
    await recordLoginAttempt(attemptKey, 'recovery', false, context);
    throw error;
  }
}
