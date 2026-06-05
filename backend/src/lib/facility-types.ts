import { ValidationError } from './errors.js';

/** Values of public.facility_type — keep in sync with DB enum. */
export const FACILITY_TYPE_VALUES = [
  'hospital',
  'clinic',
  'pharmacy',
  'laboratory',
  'dental',
  'optometry',
  'imaging',
  'other',
] as const;

export type FacilityTypeValue = (typeof FACILITY_TYPE_VALUES)[number];

export const FACILITY_TYPE_LABELS: Record<FacilityTypeValue, string> = {
  hospital: 'Hospitals',
  clinic: 'Clinics',
  pharmacy: 'Pharmacies',
  laboratory: 'Laboratories',
  dental: 'Dental',
  optometry: 'Optometry',
  imaging: 'Imaging',
  other: 'Other care',
};

const FACILITY_TYPE_SET = new Set<string>(FACILITY_TYPE_VALUES);

export function isFacilityTypeValue(value: string): value is FacilityTypeValue {
  return FACILITY_TYPE_SET.has(value);
}

/** Dedupe, validate, and preserve order for portal/API input. */
export function normalizeFacilityTypes(types: string[]): FacilityTypeValue[] {
  const seen = new Set<string>();
  const out: FacilityTypeValue[] = [];
  for (const raw of types) {
    const value = raw.trim();
    if (!value || seen.has(value)) continue;
    if (!isFacilityTypeValue(value)) {
      throw new ValidationError(`Invalid facility category: ${value}`);
    }
    seen.add(value);
    out.push(value);
  }
  if (out.length === 0) {
    throw new ValidationError('Select at least one facility category');
  }
  return out;
}

export function effectiveFacilityTypes(row: {
  facility_type: string;
  facility_types?: string[] | null;
}): FacilityTypeValue[] {
  const listed = row.facility_types?.filter(isFacilityTypeValue) ?? [];
  if (listed.length > 0) return listed;
  return isFacilityTypeValue(row.facility_type) ? [row.facility_type] : ['clinic'];
}

/** SQL predicate: facility matches a patient-app category filter. */
export function sqlFacilityMatchesType(columnPrefix: string, paramPlaceholder: string): string {
  return `(
    ${columnPrefix}.facility_type = ${paramPlaceholder}::public.facility_type
    OR ${paramPlaceholder}::public.facility_type = ANY(${columnPrefix}.facility_types)
  )`;
}
