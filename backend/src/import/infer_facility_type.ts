/**
 * Infer public.facility_type from facility names, categories, and provider specialties.
 */

export type FacilityType =
  | 'hospital'
  | 'clinic'
  | 'pharmacy'
  | 'laboratory'
  | 'dental'
  | 'optometry'
  | 'imaging'
  | 'other';

const FACILITY_TYPES: FacilityType[] = [
  'hospital',
  'clinic',
  'pharmacy',
  'laboratory',
  'dental',
  'optometry',
  'imaging',
  'other',
];

/** Strong name patterns in specificity order (first match wins). */
const NAME_TYPE_RULES: Array<{ type: FacilityType; patterns: RegExp[] }> = [
  {
    type: 'pharmacy',
    patterns: [/\bpharmacy\b/i, /\bchemist\b/i, /\bdispensary\b/i],
  },
  {
    type: 'laboratory',
    patterns: [
      /\blaboratory\b/i,
      /\blaboratories\b/i,
      /\bpathology\b/i,
      /\bdiagnostic\s+cent(?:re|er)\b/i,
      /\bdiagnostics\b/i,
      /\blab\s+services\b/i,
    ],
  },
  {
    type: 'dental',
    patterns: [
      /\bdental\b/i,
      /\bdentist\b/i,
      /\bdentistry\b/i,
      /\borthodont/i,
    ],
  },
  {
    type: 'optometry',
    patterns: [
      /\boptometry\b/i,
      /\boptometrist\b/i,
      /\beye\s+clinic\b/i,
      /\bophthalm/i,
    ],
  },
  {
    type: 'imaging',
    patterns: [
      /\bimaging\b/i,
      /\bradiology\b/i,
      /\bx-?ray\b/i,
      /\bscan\s+cent(?:re|er)\b/i,
    ],
  },
  {
    type: 'hospital',
    patterns: [/\bhospital\b/i, /\bmaternity\s+hospital\b/i],
  },
];

/** Specialty slug/name → facility type (non-clinic types prioritized in voting). */
const SPECIALTY_TYPE_MAP: Record<string, FacilityType> = {
  dentistry: 'dental',
  dental: 'dental',
  dentist: 'dental',
  optometry: 'optometry',
  optometrist: 'optometry',
  radiology: 'imaging',
  'general-practice': 'clinic',
  paediatrics: 'clinic',
  obgyn: 'clinic',
  'internal-medicine': 'clinic',
  psychiatry: 'clinic',
  orthopaedics: 'clinic',
  dermatology: 'clinic',
  cardiology: 'clinic',
  'general-surgery': 'clinic',
};

/** Priority when multiple non-clinic specialty votes tie (higher wins). */
const TYPE_VOTE_PRIORITY: Record<FacilityType, number> = {
  imaging: 6,
  optometry: 5,
  dental: 4,
  laboratory: 3,
  pharmacy: 2,
  hospital: 1,
  clinic: 0,
  other: 0,
};

export function isFacilityType(value: string): value is FacilityType {
  return (FACILITY_TYPES as string[]).includes(value);
}

export function inferFacilityTypeFromName(name: string): FacilityType | null {
  const text = name.trim();
  if (!text) return null;

  for (const rule of NAME_TYPE_RULES) {
    for (const pattern of rule.patterns) {
      if (pattern.test(text)) return rule.type;
    }
  }
  return null;
}

function normalizeSpecialtySignal(raw: string): string {
  return raw
    .trim()
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .replace(/[^a-z0-9-]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
}

function specialtySignalToType(signal: string): FacilityType {
  const key = normalizeSpecialtySignal(signal);
  if (!key) return 'clinic';

  if (SPECIALTY_TYPE_MAP[key]) return SPECIALTY_TYPE_MAP[key];

  if (key.includes('dent')) return 'dental';
  if (key.includes('optom') || key.includes('ophthalm')) return 'optometry';
  if (key.includes('radiolog') || key.includes('imaging')) return 'imaging';
  if (key.includes('pharm')) return 'pharmacy';
  if (key.includes('patholog') || key.includes('laborator')) return 'laboratory';
  if (key.includes('hospital')) return 'hospital';

  return 'clinic';
}

export function inferFacilityTypeFromSpecialtySignals(
  texts: string[],
): FacilityType | null {
  const signals = texts
    .map((t) => t?.trim())
    .filter((t): t is string => Boolean(t));
  if (signals.length === 0) return null;

  const votes = new Map<FacilityType, number>();
  for (const signal of signals) {
    const type = specialtySignalToType(signal);
    votes.set(type, (votes.get(type) ?? 0) + 1);
  }

  const nonClinic = [...votes.entries()].filter(([t]) => t !== 'clinic');
  if (nonClinic.length === 0) return null;

  let best: FacilityType | null = null;
  let bestCount = 0;
  let bestPriority = -1;

  for (const [type, count] of nonClinic) {
    const priority = TYPE_VOTE_PRIORITY[type];
    if (
      count > bestCount ||
      (count === bestCount && priority > bestPriority)
    ) {
      best = type;
      bestCount = count;
      bestPriority = priority;
    }
  }

  return best;
}

export function inferFacilityTypeFromCategory(
  category: string | null,
  practiceType: string | null,
): FacilityType {
  const combined = `${category ?? ''} ${practiceType ?? ''}`.toLowerCase();
  if (combined.includes('hospital')) return 'hospital';
  if (combined.includes('pharmacy')) return 'pharmacy';
  if (combined.includes('pathology') || combined.includes('laboratory')) {
    return 'laboratory';
  }
  if (combined.includes('lab') && !combined.includes('labour')) return 'laboratory';
  if (combined.includes('dental')) return 'dental';
  if (combined.includes('optom')) return 'optometry';
  if (combined.includes('imaging') || combined.includes('radiology')) {
    return 'imaging';
  }
  if (combined.includes('clinic')) return 'clinic';
  return 'clinic';
}

export interface ResolveFacilityTypeInput {
  name: string;
  facilityCategory?: string | null;
  practiceType?: string | null;
  specialtyTexts?: string[];
}

export function resolveFacilityType(input: ResolveFacilityTypeInput): FacilityType {
  const fromName = inferFacilityTypeFromName(input.name);
  if (fromName) return fromName;

  const fromSpecialty = inferFacilityTypeFromSpecialtySignals(
    input.specialtyTexts ?? [],
  );
  if (fromSpecialty) return fromSpecialty;

  return inferFacilityTypeFromCategory(
    input.facilityCategory ?? null,
    input.practiceType ?? null,
  );
}

/** @deprecated Use inferFacilityTypeFromCategory or resolveFacilityType */
export function inferFacilityType(
  category: string | null,
  practiceType: string | null,
): string {
  return inferFacilityTypeFromCategory(category, practiceType);
}
