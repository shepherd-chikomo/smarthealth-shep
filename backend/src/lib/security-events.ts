import { query } from './db.js';
import type { RequestContext } from './request-context.js';

export type SecurityEventType =
  | 'auth_failure'
  | 'auth_success'
  | 'access_denied'
  | 'token_reuse'
  | 'account_locked'
  | 'account_recovery'
  | 'medical_record_access'
  | 'consent_change'
  | 'logout';

export type SecurityOutcome = 'allowed' | 'denied' | 'error';

export interface SecurityEventInput {
  userId?: string | null;
  eventType: SecurityEventType;
  action?: string;
  outcome?: SecurityOutcome;
  resourceType?: string | null;
  resourceId?: string | null;
  tenantId?: string | null;
  context?: RequestContext;
  details?: Record<string, unknown>;
}

export async function logSecurityEvent(input: SecurityEventInput): Promise<void> {
  try {
    await query(
      `SELECT audit.log_security_event_backend(
         $1, $2, $3, $4, $5, $6, $7, $8::inet, $9::jsonb, $10
       )`,
      [
        input.userId ?? null,
        input.eventType,
        input.action ?? 'access',
        input.outcome ?? 'allowed',
        input.resourceType ?? null,
        input.resourceId ?? null,
        input.tenantId ?? null,
        input.context?.ipAddress ?? null,
        JSON.stringify(input.details ?? {}),
        input.context?.userAgent ?? null,
      ],
    );
  } catch (err) {
    console.error('Failed to log security event', input.eventType, err);
  }
}
