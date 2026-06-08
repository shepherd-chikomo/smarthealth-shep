import { randomUUID } from 'node:crypto';
import { z } from 'zod';
import { AMBULANCE_SERVICE_TYPE_VALUES } from './facility-classification.js';

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

export const facilityServiceSchema = z.object({
  id: z.string().uuid(),
  key: z.string().optional(),
  name: z.string().min(1).max(120),
  iconKey: z.string().min(1).max(40),
  isCustom: z.boolean().default(false),
});

export const medicalAidEntrySchema = z.object({
  schemeKey: z.string().min(1).max(60),
  name: z.string().min(1).max(120),
  logoPath: z.string().optional(),
});

export const facilityProfileSettingsSchema = z.object({
  services: z.array(facilityServiceSchema).default([]),
  medicalAids: z.array(medicalAidEntrySchema).default([]),
  accessibility: z
    .object({
      wheelchair: z.boolean().optional(),
      parking: z.boolean().optional(),
      elevator: z.boolean().optional(),
      babyFacilities: z.boolean().optional(),
    })
    .default({}),
  emergency: z
    .object({
      department: z.boolean().optional(),
      ambulance: z.boolean().optional(),
      trauma: z.boolean().optional(),
      icu: z.boolean().optional(),
      is24Hour: z.boolean().optional(),
    })
    .default({}),
  ambulanceServiceTypes: z.array(z.enum(AMBULANCE_SERVICE_TYPE_VALUES)).default([]),
  smarthealthFeatures: z
    .object({
      onlineBooking: z.boolean().optional(),
      digitalPrescriptions: z.boolean().optional(),
      labResults: z.boolean().optional(),
      patientPortal: z.boolean().optional(),
      telehealth: z.boolean().optional(),
    })
    .default({}),
  booking: z
    .object({
      enabled: z.boolean().optional(),
      showSlots: z.boolean().optional(),
      slotDurationMinutes: z.number().int().min(15).max(120).optional(),
      maxAdvanceDays: z.number().int().min(1).max(365).optional(),
      cancellationPolicy: z.string().max(500).optional(),
    })
    .default({}),
});

export type FacilityProfileSettings = z.infer<typeof facilityProfileSettingsSchema>;

export const facilityProfileSettingsPatchSchema = facilityProfileSettingsSchema.partial();

export function defaultProfileSettings(): FacilityProfileSettings {
  return facilityProfileSettingsSchema.parse({});
}

export function parseProfileSettings(raw: unknown): FacilityProfileSettings {
  if (!raw || typeof raw !== 'object') return defaultProfileSettings();
  const parsed = facilityProfileSettingsSchema.safeParse(raw);
  return parsed.success ? parsed.data : defaultProfileSettings();
}

export function mergeProfileSettings(
  current: FacilityProfileSettings,
  patch: z.infer<typeof facilityProfileSettingsPatchSchema>,
): FacilityProfileSettings {
  return facilityProfileSettingsSchema.parse({
    services: patch.services ?? current.services,
    medicalAids: patch.medicalAids ?? current.medicalAids,
    accessibility: { ...current.accessibility, ...patch.accessibility },
    emergency: { ...current.emergency, ...patch.emergency },
    ambulanceServiceTypes: patch.ambulanceServiceTypes ?? current.ambulanceServiceTypes,
    smarthealthFeatures: { ...current.smarthealthFeatures, ...patch.smarthealthFeatures },
    booking: { ...current.booking, ...patch.booking },
  });
}

export function createCustomService(name: string, iconKey = 'custom') {
  return {
    id: randomUUID(),
    name: name.trim(),
    iconKey,
    isCustom: true,
  };
}

export function presetServiceToEntry(key: string) {
  const preset = PRESET_FACILITY_SERVICES.find((s) => s.key === key);
  if (!preset) return null;
  return {
    id: randomUUID(),
    key: preset.key,
    name: preset.name,
    iconKey: preset.iconKey,
    isCustom: false,
  };
}
