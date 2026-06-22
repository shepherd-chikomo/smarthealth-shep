/// Portal tab labels — keep in sync with facility-portal `FacilityProfileTabs`.
const facilityProfileTabs = [
  'General',
  'Logo',
  'Services',
  'Medical Aid',
  'Accessibility',
  'Booking',
  'Features',
];

/// Zimbabwe healthcare facility classification — matches backend.
const facilityClassificationOptions = [
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
];

const facilityCategoryOptions = [
  (id: 'clinic', label: 'Clinics'),
  (id: 'pharmacy', label: 'Pharmacies'),
  (id: 'laboratory', label: 'Laboratories'),
  (id: 'dental', label: 'Dental'),
  (id: 'hospital', label: 'Hospitals'),
  (id: 'imaging', label: 'Imaging'),
  (id: 'optometry', label: 'Optometry'),
  (id: 'other', label: 'Other care'),
];

const ambulanceServiceTypeOptions = [
  (value: 'Emergency Ambulance Service', description: 'Public or private emergency response'),
  (value: 'Air Ambulance Service', description: 'Fixed-wing and helicopter evacuation'),
  (value: 'Patient Transfer Service', description: 'Non-emergency transport'),
  (value: 'Rescue Service', description: 'Road traffic accidents, remote rescue'),
  (value: 'Event Medical Service', description: 'Sports and event standby'),
  (value: 'Mine Emergency Medical Service', description: 'Industrial and mining EMS'),
  (value: 'Municipal Ambulance Service', description: 'City-operated ambulance fleet'),
  (value: 'Government Ambulance Service', description: 'Ministry-operated EMS'),
];

const accessibilityFlags = [
  ('wheelchair', 'Wheelchair accessible'),
  ('parking', 'Parking available'),
  ('elevator', 'Elevator available'),
  ('babyFacilities', 'Baby facilities'),
];

const emergencyFlags = [
  ('department', 'Emergency department'),
  ('ambulance', 'Ambulance service'),
  ('trauma', 'Trauma unit'),
  ('icu', 'ICU'),
  ('is24Hour', '24-hour emergency'),
];

const smarthealthFeatureFlags = [
  ('onlineBooking', 'Online booking enabled'),
  ('digitalPrescriptions', 'Digital prescriptions'),
  ('labResults', 'Lab results available'),
  ('patientPortal', 'Patient portal enabled'),
  ('telehealth', 'Telehealth enabled'),
];

/// Fallback when the services catalog API is unreachable.
const fallbackServiceCatalogItems = [
  (id: 'gp', label: 'General Practice', iconKey: 'gp'),
  (id: 'emergency', label: 'Emergency', iconKey: 'emergency'),
  (id: 'maternity', label: 'Maternity', iconKey: 'maternity'),
  (id: 'paediatrics', label: 'Paediatrics', iconKey: 'paediatrics'),
  (id: 'laboratory', label: 'Laboratory', iconKey: 'laboratory'),
  (id: 'radiology', label: 'Radiology', iconKey: 'radiology'),
  (id: 'pharmacy', label: 'Pharmacy', iconKey: 'pharmacy'),
  (id: 'surgery', label: 'Surgery', iconKey: 'surgery'),
  (id: 'physiotherapy', label: 'Physiotherapy', iconKey: 'physiotherapy'),
  (id: 'dentistry', label: 'Dentistry', iconKey: 'dentistry'),
];

/// Fallback when the medical aid catalog API is unreachable or empty.
const fallbackMedicalAidCatalogItems = [
  (schemeKey: 'cimas', name: 'CIMAS'),
  (schemeKey: 'psmas', name: 'PSMAS'),
  (schemeKey: 'first_mutual', name: 'First Mutual Health'),
  (schemeKey: 'masca', name: 'MASCA'),
  (schemeKey: 'fidelity', name: 'Fidelity Life Assurance'),
  (schemeKey: 'econet_health', name: 'Econet Health'),
  (schemeKey: 'cellmed', name: 'Cellmed'),
  (schemeKey: 'cah', name: 'Corporate 24 Medical Aid'),
];
