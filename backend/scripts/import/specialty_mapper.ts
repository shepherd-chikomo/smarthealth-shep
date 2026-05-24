import type { SpecialtyRecord } from './types.js';

/** Built-in specialty taxonomy mappings (fallback when DB aliases unavailable). */
const BUILTIN_ALIASES: Record<string, string> = {
  gp: 'general-practice',
  'general doctor': 'general-practice',
  'general practitioner': 'general-practice',
  'family medicine': 'general-practice',
  'family physician': 'general-practice',
  paeds: 'paediatrics',
  pediatrics: 'paediatrics',
  paediatrician: 'paediatrics',
  pediatrician: 'paediatrics',
  'obs & gyn': 'obgyn',
  'obs and gyn': 'obgyn',
  'obstetrics & gynecology': 'obgyn',
  'obstetrics & gynaecology': 'obgyn',
  'obstetrics and gynaecology': 'obgyn',
  'o&g': 'obgyn',
  og: 'obgyn',
  gynae: 'obgyn',
  gynecology: 'obgyn',
  gynaecology: 'obgyn',
  'internal med': 'internal-medicine',
  'internal medicine': 'internal-medicine',
  physician: 'internal-medicine',
  psych: 'psychiatry',
  psychiatric: 'psychiatry',
  psychiatry: 'psychiatry',
  ortho: 'orthopaedics',
  orthopaedic: 'orthopaedics',
  orthopedics: 'orthopaedics',
  orthopaedics: 'orthopaedics',
  derm: 'dermatology',
  dermatology: 'dermatology',
  cardio: 'cardiology',
  cardiology: 'cardiology',
  ent: 'general-surgery',
  surgery: 'general-surgery',
  'general surgery': 'general-surgery',
  dental: 'dentistry',
  dentist: 'dentistry',
  dentistry: 'dentistry',
  optom: 'optometry',
  optometry: 'optometry',
  optometrist: 'optometry',
  radiology: 'radiology',
  rad: 'radiology',
  radiologist: 'radiology',
};

export interface SpecialtyMapper {
  map: (raw: string | null) => { name: string | null; slug: string | null; unmatched: boolean };
  getUnmatched: () => Map<string, number>;
}

export function createSpecialtyMapper(
  specialties: SpecialtyRecord[],
  dbAliases: Map<string, string>,
): SpecialtyMapper {
  const slugToSpecialty = new Map(specialties.map((s) => [s.slug, s]));
  const nameToSpecialty = new Map(
    specialties.map((s) => [s.name.toLowerCase(), s]),
  );
  const unmatchedCounts = new Map<string, number>();

  function normalizeKey(raw: string): string {
    return raw.trim().toLowerCase().replace(/\s+/g, ' ');
  }

  function map(raw: string | null): { name: string | null; slug: string | null; unmatched: boolean } {
    if (!raw) return { name: null, slug: null, unmatched: false };

    const key = normalizeKey(raw);

    const directName = nameToSpecialty.get(key);
    if (directName) {
      return { name: directName.name, slug: directName.slug, unmatched: false };
    }

    const dbSlug = dbAliases.get(key);
    if (dbSlug) {
      const spec = slugToSpecialty.get(dbSlug);
      if (spec) return { name: spec.name, slug: spec.slug, unmatched: false };
    }

    const builtinSlug = BUILTIN_ALIASES[key];
    if (builtinSlug) {
      const spec = slugToSpecialty.get(builtinSlug);
      if (spec) return { name: spec.name, slug: spec.slug, unmatched: false };
    }

    for (const [alias, slug] of Object.entries(BUILTIN_ALIASES)) {
      if (key.includes(alias) || alias.includes(key)) {
        const spec = slugToSpecialty.get(slug);
        if (spec) return { name: spec.name, slug: spec.slug, unmatched: false };
      }
    }

    unmatchedCounts.set(raw, (unmatchedCounts.get(raw) ?? 0) + 1);
    return { name: raw, slug: null, unmatched: true };
  }

  return {
    map,
    getUnmatched: () => unmatchedCounts,
  };
}

export async function loadSpecialtyData(
  queryFn: <T>(sql: string, params?: unknown[]) => Promise<{ rows: T[] }>,
): Promise<{
  specialties: SpecialtyRecord[];
  aliases: Map<string, string>;
}> {
  const specialtiesResult = await queryFn<SpecialtyRecord>(
    `SELECT id, name, slug FROM public.specialties WHERE is_active = true`,
  );

  const aliasesResult = await queryFn<{ alias_normalized: string; slug: string }>(
    `SELECT sa.alias_normalized, s.slug
     FROM public.specialty_aliases sa
     JOIN public.specialties s ON s.id = sa.specialty_id`,
  );

  const aliases = new Map<string, string>();
  for (const row of aliasesResult.rows) {
    aliases.set(row.alias_normalized, row.slug);
  }

  return { specialties: specialtiesResult.rows, aliases };
}
