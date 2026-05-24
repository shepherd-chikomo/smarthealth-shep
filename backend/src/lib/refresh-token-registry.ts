import { createHash } from 'node:crypto';
import { query } from './db.js';
import { AppError } from './errors.js';
import { logSecurityEvent } from './security-events.js';
import type { RequestContext } from './request-context.js';

export function hashRefreshToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

export async function registerRefreshToken(
  userId: string,
  refreshToken: string,
  context?: RequestContext,
  expiresInSeconds = 604_800,
): Promise<void> {
  const tokenHash = hashRefreshToken(refreshToken);
  const expiresAt = new Date(Date.now() + expiresInSeconds * 1000);

  await query(
    `SELECT private.register_refresh_token($1, $2, null, $3, $4::inet, $5)`,
    [
      userId,
      tokenHash,
      context?.userAgent ?? null,
      context?.ipAddress ?? null,
      expiresAt.toISOString(),
    ],
  );
}

export async function revokeRefreshToken(refreshToken: string): Promise<void> {
  const tokenHash = hashRefreshToken(refreshToken);
  await query(`SELECT private.revoke_refresh_token($1)`, [tokenHash]);
}

export async function revokeAllUserTokens(userId: string): Promise<void> {
  await query(`SELECT private.revoke_all_user_tokens($1)`, [userId]);
}

export interface RefreshValidation {
  userId: string | null;
  isValid: boolean;
  isReuse: boolean;
}

export async function validateRefreshToken(refreshToken: string): Promise<RefreshValidation> {
  const tokenHash = hashRefreshToken(refreshToken);
  const result = await query<{ user_id: string | null; is_valid: boolean; is_reuse: boolean }>(
    `SELECT user_id, is_valid, is_reuse FROM private.validate_refresh_token($1)`,
    [tokenHash],
  );

  const row = result.rows[0];
  return {
    userId: row?.user_id ?? null,
    isValid: row?.is_valid ?? false,
    isReuse: row?.is_reuse ?? false,
  };
}

export async function rotateRefreshToken(
  oldRefreshToken: string,
  newRefreshToken: string,
  userId: string,
  context?: RequestContext,
  expiresInSeconds = 604_800,
): Promise<void> {
  const validation = await validateRefreshToken(oldRefreshToken);

  if (validation.isReuse) {
    await logSecurityEvent({
      userId: validation.userId,
      eventType: 'token_reuse',
      outcome: 'denied',
      action: 'refresh',
      context,
      details: { message: 'Refresh token reuse detected — all sessions revoked' },
    });
    throw new AppError(401, 'TOKEN_REUSE_DETECTED', 'Session invalidated due to token reuse');
  }

  if (!validation.isValid) {
    throw new AppError(401, 'INVALID_REFRESH_TOKEN', 'Refresh token is invalid or expired');
  }

  await revokeRefreshToken(oldRefreshToken);
  await registerRefreshToken(userId, newRefreshToken, context, expiresInSeconds);
}
