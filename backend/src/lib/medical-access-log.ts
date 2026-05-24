import { query } from './db.js';
import type { RequestContext } from './request-context.js';

export interface MedicalAccessInput {
  actorId: string;
  patientId: string;
  resourceType: string;
  resourceId?: string | null;
  action?: 'read' | 'export' | 'print' | 'share';
  tenantId?: string | null;
  context?: RequestContext;
  details?: Record<string, unknown>;
}

export async function logMedicalAccess(input: MedicalAccessInput): Promise<void> {
  try {
    await query(
      `SELECT audit.log_medical_access_backend(
         $1, $2, $3, $4, $5, $6, $7::inet, $8, $9::jsonb
       )`,
      [
        input.actorId,
        input.patientId,
        input.resourceType,
        input.resourceId ?? null,
        input.action ?? 'read',
        input.tenantId ?? null,
        input.context?.ipAddress ?? null,
        input.context?.userAgent ?? null,
        JSON.stringify(input.details ?? {}),
      ],
    );
  } catch (err) {
    console.error('Failed to log medical access', input.resourceType, err);
  }
}
