/** Zimbabwe healthcare facility classification — matches backend FACILITY_CLASSIFICATION_VALUES */
export const FACILITY_CLASSIFICATION_OPTIONS = [
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

export type FacilityClassification = (typeof FACILITY_CLASSIFICATION_OPTIONS)[number];

export const AMBULANCE_SERVICE_TYPE_OPTIONS = [
  { value: 'Emergency Ambulance Service', description: 'Public or private emergency response' },
  { value: 'Air Ambulance Service', description: 'Fixed-wing and helicopter evacuation' },
  { value: 'Patient Transfer Service', description: 'Non-emergency transport' },
  { value: 'Rescue Service', description: 'Road traffic accidents, remote rescue' },
  { value: 'Event Medical Service', description: 'Sports and event standby' },
  { value: 'Mine Emergency Medical Service', description: 'Industrial and mining EMS' },
  { value: 'Municipal Ambulance Service', description: 'City-operated ambulance fleet' },
  { value: 'Government Ambulance Service', description: 'Ministry-operated EMS' },
] as const;
