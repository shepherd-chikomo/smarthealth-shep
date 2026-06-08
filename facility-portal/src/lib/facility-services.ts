export const PRESET_FACILITY_SERVICES = [
  { key: 'gp', name: 'General Practice', iconKey: 'gp' },
  { key: 'emergency', name: 'Emergency', iconKey: 'emergency' },
  { key: 'maternity', name: 'Maternity', iconKey: 'maternity' },
  { key: 'paediatrics', name: 'Paediatrics', iconKey: 'paediatrics' },
  { key: 'laboratory', name: 'Laboratory', iconKey: 'laboratory' },
  { key: 'radiology', name: 'Radiology', iconKey: 'radiology' },
  { key: 'pharmacy', name: 'Pharmacy', iconKey: 'pharmacy' },
  { key: 'surgery', name: 'Surgery', iconKey: 'surgery' },
  { key: 'physiotherapy', name: 'Physiotherapy', iconKey: 'physiotherapy' },
  { key: 'dentistry', name: 'Dentistry', iconKey: 'dentistry' },
] as const;

export type FacilityServiceEntry = {
  id: string;
  key?: string;
  name: string;
  iconKey: string;
  isCustom: boolean;
};

export type ProfileSettings = {
  services: FacilityServiceEntry[];
  medicalAids: { schemeKey: string; name: string; logoPath?: string }[];
  accessibility: Record<string, boolean | undefined>;
  emergency: Record<string, boolean | undefined>;
  ambulanceServiceTypes: string[];
  smarthealthFeatures: Record<string, boolean | undefined>;
  booking: Record<string, unknown>;
};
