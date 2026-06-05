/** Patient-app facility categories (matches public.facility_type enum). */
export const FACILITY_CATEGORY_OPTIONS = [
  { id: 'clinic', label: 'Clinics' },
  { id: 'pharmacy', label: 'Pharmacies' },
  { id: 'laboratory', label: 'Laboratories' },
  { id: 'dental', label: 'Dental' },
  { id: 'hospital', label: 'Hospitals' },
  { id: 'imaging', label: 'Imaging' },
  { id: 'optometry', label: 'Optometry' },
  { id: 'other', label: 'Other care' },
] as const;

export type FacilityCategoryId = (typeof FACILITY_CATEGORY_OPTIONS)[number]['id'];
