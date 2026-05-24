/**
 * One-off repair: link providers to HPA role-holder facilities when names differ
 * only by word order (e.g. MDPCZ "Wazara Matthew" vs HPA "Matthew Wazara").
 */
import pg from 'pg';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { normalizePersonName, reverseNameKey } from './import/normalize_registry.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const envPath = join(__dirname, '..', '.env');
const env = readFileSync(envPath, 'utf8')
  .split(/\r?\n/)
  .reduce<Record<string, string>>((acc, line) => {
    const match = line.match(/^([^#=]+)=(.*)$/);
    if (match) acc[match[1].trim()] = match[2].trim();
    return acc;
  }, {});

const pool = new pg.Pool({ connectionString: env.DATABASE_URL });
const client = await pool.connect();

try {
  await client.query('BEGIN');

  const providers = await client.query<{ id: string; name: string }>(
    `SELECT id, name FROM public.providers WHERE import_source = 'MDPCZ' AND deleted_at IS NULL`,
  );

  const nameToProvider = new Map<string, string>();
  for (const p of providers.rows) {
    const key = normalizePersonName(p.name);
    nameToProvider.set(key, p.id);
    nameToProvider.set(reverseNameKey(key), p.id);
  }

  const intents = await client.query<{
    facility_id: string;
    normalized_full_name: string;
    import_batch_id: string | null;
  }>(
    `SELECT fri.facility_id, fri.normalized_full_name, f.import_batch_id
     FROM public.facility_role_holder_intents fri
     JOIN public.facilities f ON f.id = fri.facility_id`,
  );

  let linked = 0;
  for (const intent of intents.rows) {
    const providerId =
      nameToProvider.get(intent.normalized_full_name) ??
      nameToProvider.get(reverseNameKey(intent.normalized_full_name));
    if (!providerId) continue;

    const existing = await client.query<{ id: string }>(
      `SELECT id FROM public.provider_facility_links
       WHERE provider_id = $1 AND facility_id = $2`,
      [providerId, intent.facility_id],
    );
    if (existing.rows[0]) continue;

    await client.query(
      `INSERT INTO public.provider_facility_links (
         provider_id, facility_id, link_type, is_primary, is_facility_role_holder,
         match_confidence, import_batch_id
       ) VALUES ($1, $2, 'primary', true, true, 'HIGH', $3)`,
      [providerId, intent.facility_id, intent.import_batch_id],
    );

    await client.query(
      `UPDATE public.providers SET
         facility_id = COALESCE(facility_id, $2),
         tenant_id = COALESCE(tenant_id, $2)
       WHERE id = $1`,
      [providerId, intent.facility_id],
    );

    linked++;
  }

  await client.query('COMMIT');
  console.log(`Linked ${linked} provider-facility pairs via reversed-name matching`);

  const wazara = await pool.query(
    `SELECT f.name FROM public.provider_facility_links pfl
     JOIN public.facilities f ON f.id = pfl.facility_id
     JOIN public.providers p ON p.id = pfl.provider_id
     WHERE p.email = 'wazaram@gmail.com'
     ORDER BY f.name`,
  );
  console.log('Wazara facilities:', wazara.rows.map((r) => r.name));
} catch (err) {
  await client.query('ROLLBACK');
  throw err;
} finally {
  client.release();
  await pool.end();
}
