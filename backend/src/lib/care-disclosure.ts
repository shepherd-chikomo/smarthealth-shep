/**
 * Consent-gated care disclosure helpers (Tier 1 episodic sharing).
 */

export const CONSENT_VERSION = '2026-06';

export type ShareProfileFlags = Record<string, boolean>;

const FIELD_MAP: Record<string, string> = {
  allergies: 'allergies',
  conditions: 'conditions',
  medications: 'medications',
  bloodGroup: 'bloodGroup',
  emergencyContact: 'emergencyContact',
  medicalAid: 'medicalAid',
};

export function computeValidUntil(scheduledAtIso: string, daysAfter = 7): string {
  const scheduled = new Date(scheduledAtIso);
  const validUntil = new Date(scheduled.getTime() + daysAfter * 24 * 60 * 60 * 1000);
  return validUntil.toISOString();
}

export function isDisclosureActive(validUntilIso: string | null | undefined): boolean {
  if (!validUntilIso) return false;
  return new Date(validUntilIso).getTime() >= Date.now();
}

export function filterSnapshotByFlags(
  snapshot: Record<string, unknown> | null | undefined,
  shareProfile: ShareProfileFlags | null | undefined,
): Record<string, unknown> | null {
  if (!snapshot || typeof snapshot !== 'object') return null;
  if (!shareProfile) return { ...snapshot };

  const filtered: Record<string, unknown> = {};
  for (const [flagKey, snapshotKey] of Object.entries(FIELD_MAP)) {
    if (shareProfile[flagKey] === true && snapshot[snapshotKey] != null) {
      filtered[snapshotKey] = snapshot[snapshotKey];
    }
  }
  return Object.keys(filtered).length > 0 ? filtered : null;
}

export interface AppointmentDisclosureRow {
  id: string;
  metadata: Record<string, unknown>;
  scheduled_at: Date;
}

export function extractDisclosureFromAppointment(row: AppointmentDisclosureRow | undefined) {
  if (!row) return null;
  const meta = row.metadata ?? {};
  const validUntil = meta.validUntil as string | undefined;
  if (!isDisclosureActive(validUntil)) return null;

  const shareProfile = meta.shareProfile as ShareProfileFlags | undefined;
  const snapshot = meta.sharedProfileSnapshot as Record<string, unknown> | undefined;
  const filtered = filterSnapshotByFlags(snapshot, shareProfile);

  return {
    appointmentId: row.id,
    validUntil: validUntil ?? null,
    shareProfile: shareProfile ?? {},
    sharedProfileSnapshot: filtered,
    receiveEncounterSummary: meta.receiveEncounterSummary === true,
    purpose: (meta.purpose as string) ?? 'pre_visit_booking',
  };
}
