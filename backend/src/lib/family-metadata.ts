import { emergencyMedicalMetadataSchema } from '../schemas/common.js';
import { stripHtmlTags } from './sanitize.js';

function sanitizePlainText(input: string, maxLength: number): string {
  return stripHtmlTags(input.trim()).slice(0, maxLength);
}

const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

const DB_FAMILY_RELATIONSHIPS = new Set([
  'self',
  'spouse',
  'child',
  'parent',
  'sibling',
  'other',
]);

export function isUuid(value: unknown): value is string {
  return typeof value === 'string' && UUID_RE.test(value);
}

export function normalizeMetadata(raw: unknown): Record<string, unknown> {
  if (raw == null) return {};
  if (typeof raw === 'string') {
    try {
      const parsed = JSON.parse(raw) as unknown;
      if (typeof parsed === 'object' && parsed !== null && !Array.isArray(parsed)) {
        return parsed as Record<string, unknown>;
      }
    } catch {
      return {};
    }
    return {};
  }
  if (typeof raw === 'object' && !Array.isArray(raw)) {
    return raw as Record<string, unknown>;
  }
  return {};
}

function sanitizeMedications(raw: unknown): Array<{ name: string; frequency?: string }> {
  if (!Array.isArray(raw)) return [];

  const medications: Array<{ name: string; frequency?: string }> = [];
  for (const item of raw) {
    if (!item || typeof item !== 'object' || Array.isArray(item)) continue;
    const record = item as Record<string, unknown>;
    const name =
      typeof record.name === 'string' ? sanitizePlainText(record.name, 200) : '';
    if (!name) continue;

    const entry: { name: string; frequency?: string } = { name: name.slice(0, 200) };
    const frequency =
      typeof record.frequency === 'string'
        ? sanitizePlainText(record.frequency, 40)
        : '';
    if (frequency) entry.frequency = frequency.slice(0, 40);
    medications.push(entry);
  }
  return medications;
}

function sanitizeNestedStrings(
  raw: unknown,
  keys: string[],
  maxLength: number,
): Record<string, string> | undefined {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return undefined;

  const source = raw as Record<string, unknown>;
  const result: Record<string, string> = {};
  for (const key of keys) {
    const value = source[key];
    if (typeof value === 'string' && value.trim()) {
      result[key] = sanitizePlainText(value, maxLength);
    }
  }
  return Object.keys(result).length > 0 ? result : undefined;
}

function sanitizeMedicalAid(raw: unknown): Record<string, string> | undefined {
  return sanitizeNestedStrings(raw, ['schemeKey', 'provider', 'memberNumber'], 120);
}

function sanitizeEmergencyContact(raw: unknown): Record<string, string> | undefined {
  return sanitizeNestedStrings(raw, ['name', 'relationship', 'phone'], 120);
}

function sanitizeCustomConditionLabels(raw: unknown): Record<string, string> | undefined {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return undefined;

  const source = raw as Record<string, unknown>;
  const result: Record<string, string> = {};
  for (const [key, value] of Object.entries(source)) {
    if (typeof key !== 'string' || typeof value !== 'string') continue;
    const slug = key.trim().slice(0, 80);
    const label = sanitizePlainText(value, 120);
    if (slug && label) result[slug] = label;
  }
  return Object.keys(result).length > 0 ? result : undefined;
}

function sanitizePrimaryProvider(raw: unknown): Record<string, string> | undefined {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return undefined;

  const source = raw as Record<string, unknown>;
  const result = sanitizeNestedStrings(raw, ['facilityName', 'doctorName', 'phone'], 200) ?? {};
  if (isUuid(source.facilityId)) result.facilityId = source.facilityId;
  if (isUuid(source.providerId)) result.providerId = source.providerId;

  return Object.keys(result).length > 0 ? result : undefined;
}

export function sanitizeMetadataInput(raw: unknown): Record<string, unknown> {
  const normalized = normalizeMetadata(raw);
  const candidate = {
    bloodGroup:
      typeof normalized.bloodGroup === 'string' && normalized.bloodGroup.trim()
        ? sanitizePlainText(normalized.bloodGroup, 10)
        : undefined,
    medications: sanitizeMedications(normalized.medications),
    emergencyContact: sanitizeEmergencyContact(normalized.emergencyContact),
    medicalAid: sanitizeMedicalAid(normalized.medicalAid),
    primaryProvider: sanitizePrimaryProvider(normalized.primaryProvider),
    customConditionLabels: sanitizeCustomConditionLabels(normalized.customConditionLabels),
  };

  const parsed = emergencyMedicalMetadataSchema.safeParse(candidate);
  if (parsed.success) {
    return parsed.data as Record<string, unknown>;
  }

  return { medications: candidate.medications };
}

export function metadataForStorage(raw: unknown): string {
  return JSON.stringify(sanitizeMetadataInput(raw));
}

export function metadataForResponse(raw: unknown) {
  const sanitized = sanitizeMetadataInput(raw);
  const parsed = emergencyMedicalMetadataSchema.safeParse(sanitized);
  if (parsed.success) return parsed.data;

  return { medications: [] };
}

export function mergeMetadata(
  existing: Record<string, unknown>,
  patch: Record<string, unknown>,
): Record<string, unknown> {
  const merged: Record<string, unknown> = { ...existing, ...patch };

  for (const key of ['emergencyContact', 'medicalAid', 'primaryProvider'] as const) {
    const patchValue = patch[key];
    if (patchValue && typeof patchValue === 'object' && !Array.isArray(patchValue)) {
      const current = existing[key];
      merged[key] = {
        ...(typeof current === 'object' && current !== null && !Array.isArray(current)
          ? (current as Record<string, unknown>)
          : {}),
        ...(patchValue as Record<string, unknown>),
      };
    }
  }

  if (Array.isArray(patch.medications)) {
    merged.medications = patch.medications;
  }

  if (patch.customConditionLabels && typeof patch.customConditionLabels === 'object') {
    const current =
      typeof existing.customConditionLabels === 'object' &&
      existing.customConditionLabels !== null &&
      !Array.isArray(existing.customConditionLabels)
        ? (existing.customConditionLabels as Record<string, unknown>)
        : {};
    merged.customConditionLabels = {
      ...current,
      ...(patch.customConditionLabels as Record<string, unknown>),
    };
  }

  return sanitizeMetadataInput(merged);
}

export function normalizeFamilyRelationship(value: string): string {
  const normalized = value.trim().toLowerCase();
  if (DB_FAMILY_RELATIONSHIPS.has(normalized)) return normalized;
  return 'other';
}
