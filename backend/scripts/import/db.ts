import { config as loadEnv } from 'dotenv';
import pg from 'pg';

loadEnv();

const { Pool } = pg;

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL is required for import scripts');
}

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 10_000,
});

export async function query<T extends pg.QueryResultRow = pg.QueryResultRow>(
  text: string,
  params?: unknown[],
): Promise<pg.QueryResult<T>> {
  return pool.query<T>(text, params);
}

export async function withTransaction<T>(
  fn: (client: pg.PoolClient) => Promise<T>,
): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

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
