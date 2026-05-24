import { query } from './db.js';
import type { RequestContext } from './request-context.js';

export type AuditCategory =
  | 'login'
  | 'medical_access'
  | 'appointment'
  | 'billing'
  | 'permission'
  | 'admin'
  | 'security'
  | 'data_change';

export type AuditOutcome = 'allowed' | 'denied' | 'error';

export interface AuditActionInput {
  userId?: string | null;
  category: AuditCategory;
  actionType: string;
  entityType?: string | null;
  entityId?: string | null;
  facilityId?: string | null;
  outcome?: AuditOutcome;
  context?: RequestContext;
  details?: Record<string, unknown>;
}

/** Writes an immutable audit record with full compliance fields. */
export async function logAuditAction(input: AuditActionInput): Promise<void> {
  try {
    await query(
      `SELECT audit.log_action_backend(
         $1, $2, $3, $4, $5, $6, $7, $8::inet, $9, $10::jsonb
       )`,
      [
        input.userId ?? null,
        input.category,
        input.actionType,
        input.entityType ?? null,
        input.entityId ?? null,
        input.facilityId ?? null,
        input.outcome ?? 'allowed',
        input.context?.ipAddress ?? null,
        input.context?.userAgent ?? null,
        JSON.stringify(input.details ?? {}),
      ],
    );
  } catch (err) {
    console.error('Failed to log audit action', input.actionType, err);
  }
}

export async function logLoginAudit(
  userId: string | null,
  actionType: string,
  outcome: AuditOutcome,
  context?: RequestContext,
  details?: Record<string, unknown>,
): Promise<void> {
  await logAuditAction({
    userId,
    category: 'login',
    actionType,
    entityType: 'session',
    outcome,
    context,
    details,
  });
}

export async function logAppointmentAudit(
  userId: string,
  actionType: string,
  appointmentId: string,
  facilityId: string,
  context?: RequestContext,
  details?: Record<string, unknown>,
): Promise<void> {
  await logAuditAction({
    userId,
    category: 'appointment',
    actionType,
    entityType: 'appointment',
    entityId: appointmentId,
    facilityId,
    context,
    details,
  });
}

export async function logBillingAudit(
  userId: string,
  actionType: string,
  entityType: string,
  entityId: string,
  facilityId: string,
  context?: RequestContext,
  details?: Record<string, unknown>,
): Promise<void> {
  await logAuditAction({
    userId,
    category: 'billing',
    actionType,
    entityType,
    entityId,
    facilityId,
    context,
    details,
  });
}

export async function logPermissionAudit(
  userId: string,
  actionType: string,
  entityType: string,
  entityId: string,
  facilityId: string | null,
  context?: RequestContext,
  details?: Record<string, unknown>,
): Promise<void> {
  await logAuditAction({
    userId,
    category: 'permission',
    actionType,
    entityType,
    entityId,
    facilityId,
    context,
    details,
  });
}

export async function logAdminAudit(
  userId: string,
  actionType: string,
  entityType: string,
  entityId: string,
  context?: RequestContext,
  details?: Record<string, unknown>,
  facilityId?: string | null,
): Promise<void> {
  await logAuditAction({
    userId,
    category: 'admin',
    actionType,
    entityType,
    entityId,
    facilityId: facilityId ?? null,
    context,
    details,
  });
}
