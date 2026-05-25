import { query } from '../lib/db.js';

export type ImportResolutionType =
  | 'ambiguous_merged'
  | 'ambiguous_distinct'
  | 'practitioner_facility_link'
  | 'practitioner_no_link'
  | 'provider_email_override'
  | 'provider_manual_claim_allowed'
  | 'manual_validation_approved'
  | 'manual_validation_rejected';

export interface ImportResolutionRule {
  id: string;
  resolutionType: ImportResolutionType;
  stableKey: string;
  facilityId: string | null;
  providerId: string | null;
  payload: Record<string, unknown>;
}

export async function upsertImportResolutionRule(opts: {
  resolutionType: ImportResolutionType;
  stableKey: string;
  facilityId?: string | null;
  providerId?: string | null;
  payload?: Record<string, unknown>;
  sourceQueueId?: string | null;
  createdBy: string;
}): Promise<void> {
  await query(
    `INSERT INTO public.import_resolution_rules (
       resolution_type, stable_key, facility_id, provider_id, payload, source_queue_id, created_by
     ) VALUES ($1::public.import_resolution_type, $2, $3, $4, $5::jsonb, $6, $7)
     ON CONFLICT (resolution_type, stable_key) DO UPDATE SET
       facility_id = EXCLUDED.facility_id,
       provider_id = EXCLUDED.provider_id,
       payload = EXCLUDED.payload,
       source_queue_id = EXCLUDED.source_queue_id,
       created_by = EXCLUDED.created_by`,
    [
      opts.resolutionType,
      opts.stableKey,
      opts.facilityId ?? null,
      opts.providerId ?? null,
      JSON.stringify(opts.payload ?? {}),
      opts.sourceQueueId ?? null,
      opts.createdBy,
    ],
  );
}

export async function getImportResolutionRule(
  resolutionType: ImportResolutionType,
  stableKey: string,
): Promise<ImportResolutionRule | null> {
  const result = await query<{
    id: string;
    resolution_type: ImportResolutionType;
    stable_key: string;
    facility_id: string | null;
    provider_id: string | null;
    payload: Record<string, unknown>;
  }>(
    `SELECT id, resolution_type, stable_key, facility_id, provider_id, payload
     FROM public.import_resolution_rules
     WHERE resolution_type = $1::public.import_resolution_type AND stable_key = $2
     LIMIT 1`,
    [resolutionType, stableKey],
  );
  const row = result.rows[0];
  if (!row) return null;
  return {
    id: row.id,
    resolutionType: row.resolution_type,
    stableKey: row.stable_key,
    facilityId: row.facility_id,
    providerId: row.provider_id,
    payload: row.payload ?? {},
  };
}

export async function hasProviderManualClaimAllowed(providerRegistryKey: string): Promise<boolean> {
  const rule = await getImportResolutionRule('provider_manual_claim_allowed', providerRegistryKey);
  return rule !== null;
}

export async function hasManualValidationApproved(registrationNumber: string): Promise<boolean> {
  const { normalizeMdpczNumber } = await import('../lib/registry-keys.js');
  const key = normalizeMdpczNumber(registrationNumber);
  const approved = await getImportResolutionRule('manual_validation_approved', key);
  return approved !== null;
}

export async function hasManualValidationRejected(registrationNumber: string): Promise<boolean> {
  const { normalizeMdpczNumber } = await import('../lib/registry-keys.js');
  const key = normalizeMdpczNumber(registrationNumber);
  const rejected = await getImportResolutionRule('manual_validation_rejected', key);
  return rejected !== null;
}

export async function getProviderEmailOverride(providerRegistryKey: string): Promise<string | null> {
  const rule = await getImportResolutionRule('provider_email_override', providerRegistryKey);
  const email = rule?.payload?.email;
  return typeof email === 'string' && email.trim() ? email.trim() : null;
}
