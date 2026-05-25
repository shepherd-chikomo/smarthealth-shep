import type pg from 'pg';
import type { ImportResolutionType } from '../../src/services/import-resolution.service.js';

export async function fetchImportResolutionRule(
  client: pg.PoolClient,
  resolutionType: ImportResolutionType,
  stableKey: string,
): Promise<{
  id: string;
  facility_id: string | null;
  provider_id: string | null;
  payload: Record<string, unknown>;
} | null> {
  const result = await client.query<{
    id: string;
    facility_id: string | null;
    provider_id: string | null;
    payload: Record<string, unknown>;
  }>(
    `SELECT id, facility_id, provider_id, payload
     FROM public.import_resolution_rules
     WHERE resolution_type = $1::public.import_resolution_type AND stable_key = $2
     LIMIT 1`,
    [resolutionType, stableKey],
  );
  return result.rows[0] ?? null;
}

export async function hasImportResolutionRule(
  client: pg.PoolClient,
  resolutionType: ImportResolutionType,
  stableKey: string,
): Promise<boolean> {
  const rule = await fetchImportResolutionRule(client, resolutionType, stableKey);
  return rule !== null;
}
