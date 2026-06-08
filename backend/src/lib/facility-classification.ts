import { ValidationError } from './errors.js';

/** Zimbabwe healthcare facility classification — stored in facilities.facility_category */
export const FACILITY_CLASSIFICATION_VALUES = [
  'Central Hospital',
  'Provincial Hospital',
  'District Hospital',
  'Mission Hospital',
  'Rural Hospital',
  'Urban Council Hospital',
  'Polyclinic',
  'Clinic',
  'Specialist Hospital',
  'Private Hospital',
  'Medical Centre',
  'Specialist Practice',
  'General Practice',
  'Diagnostic Centre',
  'Laboratory',
  'Pharmacy',
  'Ambulance Service',
  'Rehabilitation Centre',
  'Nursing Home',
  'Occupational Health Centre',
] as const;

export type FacilityClassificationValue = (typeof FACILITY_CLASSIFICATION_VALUES)[number];

/** Hospital tiers shown on the emergency hub facilities list */
export const EMERGENCY_HOSPITAL_CLASSIFICATIONS: FacilityClassificationValue[] = [
  'Central Hospital',
  'Provincial Hospital',
  'District Hospital',
  'Mission Hospital',
  'Rural Hospital',
];

export const AMBULANCE_SERVICE_TYPE_VALUES = [
  'Emergency Ambulance Service',
  'Air Ambulance Service',
  'Patient Transfer Service',
  'Rescue Service',
  'Event Medical Service',
  'Mine Emergency Medical Service',
  'Municipal Ambulance Service',
  'Government Ambulance Service',
] as const;

export type AmbulanceServiceTypeValue = (typeof AMBULANCE_SERVICE_TYPE_VALUES)[number];

const CLASSIFICATION_SET = new Set<string>(FACILITY_CLASSIFICATION_VALUES);
const AMBULANCE_TYPE_SET = new Set<string>(AMBULANCE_SERVICE_TYPE_VALUES);

export function isFacilityClassification(value: string): value is FacilityClassificationValue {
  return CLASSIFICATION_SET.has(value);
}

export function normalizeFacilityClassification(value: string | null | undefined): string | null {
  if (value == null) return null;
  const trimmed = value.trim();
  if (!trimmed) return null;
  if (!isFacilityClassification(trimmed)) {
    throw new ValidationError(`Invalid facility classification: ${trimmed}`);
  }
  return trimmed;
}

export function normalizeAmbulanceServiceTypes(types: string[]): AmbulanceServiceTypeValue[] {
  const seen = new Set<string>();
  const out: AmbulanceServiceTypeValue[] = [];
  for (const raw of types) {
    const value = raw.trim();
    if (!value || seen.has(value)) continue;
    if (!AMBULANCE_TYPE_SET.has(value)) {
      throw new ValidationError(`Invalid ambulance service type: ${value}`);
    }
    seen.add(value);
    out.push(value as AmbulanceServiceTypeValue);
  }
  return out;
}

export function sqlEmergencyHospitalClassifications(paramPlaceholder: string): string {
  return `f.facility_category IN (${EMERGENCY_HOSPITAL_CLASSIFICATIONS.map((_, i) => `${paramPlaceholder}${i}`).join(', ')})`;
}
