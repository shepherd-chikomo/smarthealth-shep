import { query, withTransaction, pool } from '../lib/db.js';

export { query, withTransaction, pool };

export async function closePool(): Promise<void> {
  await pool.end();
}

/** Normalize phone using DB function for consistency with constraints. */
export async function normalizePhoneDb(phone: string | null): Promise<string | null> {
  if (!phone) return null;
  const result = await query<{ phone: string | null }>(
    'SELECT public.normalize_zimbabwe_phone($1) AS phone',
    [phone],
  );
  return result.rows[0]?.phone ?? null;
}
