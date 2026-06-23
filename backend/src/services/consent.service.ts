import { query } from '../lib/db.js';
import { NotFoundError } from '../lib/errors.js';
import { logSecurityEvent } from '../lib/security-events.js';
import type { RequestContext } from '../lib/request-context.js';

export type ConsentType =
  | 'data_processing'
  | 'telehealth'
  | 'marketing'
  | 'research'
  | 'third_party_sharing'
  | 'emergency_contact'
  | 'facility_phi_share'
  | 'encounter_summary_receive'
  | 'facility_ongoing_care';

export interface ConsentRecord {
  id: string;
  consentType: ConsentType;
  version: string;
  grantedAt: string;
  withdrawnAt: string | null;
  metadata: Record<string, unknown>;
}

function mapConsent(row: {
  id: string;
  consent_type: string;
  version: string;
  granted_at: Date;
  withdrawn_at: Date | null;
  metadata: Record<string, unknown>;
}): ConsentRecord {
  return {
    id: row.id,
    consentType: row.consent_type as ConsentType,
    version: row.version,
    grantedAt: row.granted_at.toISOString(),
    withdrawnAt: row.withdrawn_at?.toISOString() ?? null,
    metadata: row.metadata ?? {},
  };
}

export async function listConsents(patientId: string): Promise<ConsentRecord[]> {
  const result = await query<{
    id: string;
    consent_type: string;
    version: string;
    granted_at: Date;
    withdrawn_at: Date | null;
    metadata: Record<string, unknown>;
  }>(
    `SELECT id, consent_type, version, granted_at, withdrawn_at, metadata
     FROM public.patient_consents
     WHERE patient_id = $1
     ORDER BY granted_at DESC`,
    [patientId],
  );
  return result.rows.map(mapConsent);
}

export async function grantConsent(
  patientId: string,
  consentType: ConsentType,
  version: string,
  context?: RequestContext,
  metadata: Record<string, unknown> = {},
): Promise<ConsentRecord> {
  const facilityId = metadata.facilityId as string | undefined;

  await query(
    `UPDATE public.patient_consents
     SET withdrawn_at = timezone('utc', now()), updated_at = timezone('utc', now())
     WHERE patient_id = $1 AND consent_type = $2 AND withdrawn_at IS NULL
       AND (
         ($3::text IS NULL AND metadata->>'facilityId' IS NULL)
         OR metadata->>'facilityId' = $3
       )`,
    [patientId, consentType, facilityId ?? null],
  );

  const result = await query<{
    id: string;
    consent_type: string;
    version: string;
    granted_at: Date;
    withdrawn_at: Date | null;
    metadata: Record<string, unknown>;
  }>(
    `INSERT INTO public.patient_consents (
       patient_id, consent_type, version, ip_address, user_agent, metadata
     ) VALUES ($1, $2, $3, $4::inet, $5, $6::jsonb)
     RETURNING id, consent_type, version, granted_at, withdrawn_at, metadata`,
    [
      patientId,
      consentType,
      version,
      context?.ipAddress ?? null,
      context?.userAgent ?? null,
      JSON.stringify(metadata),
    ],
  );

  await logSecurityEvent({
    userId: patientId,
    eventType: 'consent_change',
    action: 'grant',
    outcome: 'allowed',
    resourceType: 'patient_consent',
    resourceId: result.rows[0].id,
    context,
    details: { consentType, version },
  });

  return mapConsent(result.rows[0]);
}

export async function withdrawConsent(
  patientId: string,
  consentType: ConsentType,
  context?: RequestContext,
  facilityId?: string,
): Promise<ConsentRecord> {
  const result = await query<{
    id: string;
    consent_type: string;
    version: string;
    granted_at: Date;
    withdrawn_at: Date | null;
    metadata: Record<string, unknown>;
  }>(
    `UPDATE public.patient_consents
     SET withdrawn_at = timezone('utc', now()), updated_at = timezone('utc', now())
     WHERE patient_id = $1 AND consent_type = $2 AND withdrawn_at IS NULL
       AND (
         ($3::text IS NULL AND metadata->>'facilityId' IS NULL)
         OR metadata->>'facilityId' = $3
       )
     RETURNING id, consent_type, version, granted_at, withdrawn_at, metadata`,
    [patientId, consentType, facilityId ?? null],
  );

  if (!result.rows[0]) {
    throw new NotFoundError('Active consent', consentType);
  }

  await logSecurityEvent({
    userId: patientId,
    eventType: 'consent_change',
    action: 'withdraw',
    outcome: 'allowed',
    resourceType: 'patient_consent',
    resourceId: result.rows[0].id,
    context,
    details: { consentType },
  });

  return mapConsent(result.rows[0]);
}

export async function hasActiveConsent(
  patientId: string,
  consentType: ConsentType,
  facilityId?: string,
): Promise<boolean> {
  const result = await query<{ exists: boolean }>(
    `SELECT EXISTS (
       SELECT 1 FROM public.patient_consents
       WHERE patient_id = $1 AND consent_type = $2 AND withdrawn_at IS NULL
         AND (
           ($3::text IS NULL AND metadata->>'facilityId' IS NULL)
           OR metadata->>'facilityId' = $3
         )
     ) AS exists`,
    [patientId, consentType, facilityId ?? null],
  );
  return result.rows[0]?.exists ?? false;
}
