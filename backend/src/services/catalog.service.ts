import { query } from '../lib/db.js';
import { FACILITY_TYPE_LABELS } from '../lib/facility-types.js';
import { toCatalogSlug } from '../lib/catalog-slug.js';
import { searchSpecialties } from './search.service.js';

export async function listFacilityTypeCatalog() {
  const result = await query<{ facility_type: string; count: string }>(
    `SELECT expanded.facility_type, COUNT(*)::text AS count
     FROM public.facilities f
     CROSS JOIN LATERAL (
       SELECT unnest(
         CASE
           WHEN cardinality(f.facility_types) > 0 THEN f.facility_types
           ELSE ARRAY[f.facility_type]
         END
       ) AS facility_type
     ) expanded
     WHERE f.is_active = true AND f.deleted_at IS NULL
     GROUP BY expanded.facility_type
     HAVING COUNT(*) > 0
     ORDER BY COUNT(*) DESC, expanded.facility_type ASC`,
  );

  return {
    types: result.rows.map((row) => ({
      facilityType: row.facility_type,
      label: FACILITY_TYPE_LABELS[row.facility_type as keyof typeof FACILITY_TYPE_LABELS]
        ?? row.facility_type,
      count: Number(row.count),
    })),
  };
}

export async function listCatalogSpecialties(options: { page: number; limit: number }) {
  return searchSpecialties({ page: options.page, limit: options.limit });
}

const CONDITION_LABELS: Record<string, string> = {
  diabetes: 'Diabetes',
  hypertension: 'Hypertension',
  malaria: 'Malaria',
  hiv_aids: 'HIV/AIDS',
  pregnancy: 'Pregnancy',
  asthma: 'Asthma',
  mental_health: 'Mental Health',
};

const AGE_GROUP_LABELS: Record<string, string> = {
  infant: 'Infant (0-1)',
  child: 'Child (1-12)',
  teen: 'Teen (13-17)',
  adult: 'Adult (18-64)',
  senior: 'Senior (65+)',
};

const DEFAULT_CONDITIONS = Object.entries(CONDITION_LABELS).map(([id, label]) => ({
  id,
  label,
  count: 0,
}));

const DEFAULT_AGE_GROUPS = Object.entries(AGE_GROUP_LABELS).map(([id, label]) => ({
  id,
  label,
  count: 0,
}));

const ACTIVE_PROVIDER_SCOPE = `
  p.is_active = true
  AND p.is_verified = true
  AND EXISTS (
    SELECT 1 FROM public.provider_facility_links pfl
    JOIN public.facilities f ON f.id = pfl.facility_id
    WHERE pfl.provider_id = p.id AND pfl.is_primary = true
      AND f.is_active = true AND f.deleted_at IS NULL
  )
`;

async function listUnnestedCatalog(
  column: 'conditions' | 'age_groups',
  labelMap: Record<string, string>,
  defaults: { id: string; label: string; count: number }[],
) {
  const result = await query<{ val: string; count: string }>(
    `SELECT c.val, COUNT(*)::text AS count
     FROM public.providers p
     CROSS JOIN LATERAL unnest(p.${column}) AS c(val)
     WHERE ${ACTIVE_PROVIDER_SCOPE}
       AND c.val IS NOT NULL AND btrim(c.val) <> ''
     GROUP BY c.val
     ORDER BY COUNT(*) DESC, c.val ASC
     LIMIT 50`,
  );

  if (result.rows.length === 0) {
    return { items: defaults };
  }

  const bySlug = new Map<string, { id: string; label: string; count: number }>();

  for (const row of result.rows) {
    const slug = toCatalogSlug(row.val);
    if (!slug) continue;
    const existing = bySlug.get(slug);
    const count = Number(row.count);
    if (existing) {
      existing.count += count;
      continue;
    }
    bySlug.set(slug, {
      id: slug,
      label: labelMap[slug] ?? row.val,
      count,
    });
  }

  const items = [...bySlug.values()].sort((a, b) => b.count - a.count || a.label.localeCompare(b.label));

  return { items: items.length > 0 ? items : defaults };
}

export async function listConditionCatalog() {
  const { items } = await listUnnestedCatalog('conditions', CONDITION_LABELS, DEFAULT_CONDITIONS);
  return { conditions: items };
}

export async function listAgeGroupCatalog() {
  const { items } = await listUnnestedCatalog('age_groups', AGE_GROUP_LABELS, DEFAULT_AGE_GROUPS);
  return { ageGroups: items };
}
