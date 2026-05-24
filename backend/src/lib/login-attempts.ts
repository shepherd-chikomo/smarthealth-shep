import { query } from './db.js';
import { AppError } from './errors.js';
import type { RequestContext } from './request-context.js';
import { logLoginAudit } from './audit-log.js';
import { logSecurityEvent } from './security-events.js';

export type AttemptType = 'otp_send' | 'otp_verify' | 'refresh' | 'recovery';

const DEFAULT_MAX_FAILURES = 5;
const DEFAULT_WINDOW_MINUTES = 15;

export async function recordLoginAttempt(
  identifier: string,
  attemptType: AttemptType,
  success: boolean,
  context?: RequestContext,
): Promise<void> {
  try {
    await query(
      `SELECT private.record_login_attempt($1, $2, $3, $4::inet, $5)`,
      [
        identifier,
        attemptType,
        success,
        context?.ipAddress ?? null,
        context?.userAgent ?? null,
      ],
    );
  } catch (err) {
    console.error('Failed to record login attempt', err);
  }
}

export async function isIdentifierLocked(
  identifier: string,
  attemptType: AttemptType = 'otp_verify',
  maxFailures = DEFAULT_MAX_FAILURES,
  windowMinutes = DEFAULT_WINDOW_MINUTES,
): Promise<boolean> {
  const result = await query<{ locked: boolean }>(
    `SELECT private.is_identifier_locked($1, $2, $3, $4) AS locked`,
    [identifier, attemptType, maxFailures, windowMinutes],
  );
  return result.rows[0]?.locked ?? false;
}

export async function assertNotLocked(
  identifier: string,
  attemptType: AttemptType = 'otp_verify',
  context?: RequestContext,
): Promise<void> {
  const locked = await isIdentifierLocked(identifier, attemptType);
  if (locked) {
    await recordLoginAttempt(identifier, attemptType, false, context);
    await logSecurityEvent({
      eventType: 'account_locked',
      action: attemptType,
      outcome: 'denied',
      context,
      details: { identifier },
    });
    await logLoginAudit(null, `login.${attemptType}.locked`, 'denied', context, { identifier });
    throw new AppError(
      429,
      'ACCOUNT_LOCKED',
      'Too many failed attempts. Please try again later.',
    );
  }
}
