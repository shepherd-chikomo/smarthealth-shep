import { query } from '../lib/db.js';
import { NotFoundError } from '../lib/errors.js';
import {
  parseProfileSettings,
  type FacilityProfileSettings,
} from '../lib/facility-profile-settings.js';

const HARARE_TZ = 'Africa/Harare';

interface SlotSettings {
  slotDurationMinutes: number;
  bufferMinutes: number;
  maxAdvanceDays: number;
}

interface HourRow {
  day_of_week: number;
  opens_at: string | null;
  closes_at: string | null;
  is_closed: boolean;
  is_24_hours: boolean;
}

interface ProviderRow {
  id: string;
  name: string;
}

function defaultSlotSettings(): SlotSettings {
  return { slotDurationMinutes: 30, bufferMinutes: 5, maxAdvanceDays: 30 };
}

function parseTime(value: string): number {
  const [h, m] = value.split(':').map(Number);
  return h * 60 + (m ?? 0);
}

function formatTime(minutes: number): string {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`;
}

function harareNow(): Date {
  return new Date(new Date().toLocaleString('en-US', { timeZone: HARARE_TZ }));
}

function dayOfWeekHarare(date: Date): number {
  return date.getDay();
}

function dateKey(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function combineHarareDateTime(day: Date, minutes: number): Date {
  const d = new Date(day);
  d.setHours(Math.floor(minutes / 60), minutes % 60, 0, 0);
  return d;
}

function getDayHours(
  hours: HourRow[],
  dayOfWeek: number,
): { open: number; close: number; is24: boolean; closed: boolean } | null {
  const row = hours.find((h) => h.day_of_week === dayOfWeek);
  if (!row || row.is_closed) return null;
  if (row.is_24_hours) return { open: 0, close: 24 * 60, is24: true, closed: false };
  if (!row.opens_at || !row.closes_at) return null;
  return {
    open: parseTime(row.opens_at.slice(0, 5)),
    close: parseTime(row.closes_at.slice(0, 5)),
    is24: false,
    closed: false,
  };
}

function intersectWindows(
  facility: ReturnType<typeof getDayHours>,
  provider: ReturnType<typeof getDayHours>,
): { open: number; close: number } | null {
  if (!facility || !provider) return null;
  const open = Math.max(facility.open, provider.open);
  const close = Math.min(facility.close, provider.close);
  if (open >= close) return null;
  return { open, close };
}

function generateSlotsForWindow(
  window: { open: number; close: number },
  slotDuration: number,
  buffer: number,
  day: Date,
  now: Date,
): Date[] {
  const slots: Date[] = [];
  for (let t = window.open; t + slotDuration <= window.close; t += slotDuration + buffer) {
    const slotAt = combineHarareDateTime(day, t);
    if (slotAt > now) slots.push(slotAt);
  }
  return slots;
}

async function loadSlotSettings(facilityId: string): Promise<SlotSettings> {
  const row = await query<{ value: SlotSettings }>(
    `SELECT value FROM public.app_settings
     WHERE tenant_id = $1 AND scope = 'tenant' AND key = 'appointment_slots'`,
    [facilityId],
  );
  const value = row.rows[0]?.value;
  return {
    slotDurationMinutes: value?.slotDurationMinutes ?? defaultSlotSettings().slotDurationMinutes,
    bufferMinutes: value?.bufferMinutes ?? defaultSlotSettings().bufferMinutes,
    maxAdvanceDays: value?.maxAdvanceDays ?? defaultSlotSettings().maxAdvanceDays,
  };
}

async function loadFacilityHours(facilityId: string): Promise<HourRow[]> {
  const rows = await query<HourRow>(
    `SELECT day_of_week, opens_at::text, closes_at::text, is_closed, is_24_hours
     FROM public.facility_operating_hours WHERE facility_id = $1`,
    [facilityId],
  );
  return rows.rows;
}

async function loadProviderHours(providerId: string): Promise<HourRow[]> {
  const rows = await query<HourRow>(
    `SELECT day_of_week, opens_at::text, closes_at::text, is_closed, false AS is_24_hours
     FROM public.provider_working_hours WHERE provider_id = $1`,
    [providerId],
  );
  return rows.rows;
}

async function loadBookedSlots(
  facilityId: string,
  providerIds: string[],
  from: Date,
  to: Date,
): Promise<Set<string>> {
  if (providerIds.length === 0) return new Set();
  const rows = await query<{ scheduled_at: Date; provider_id: string }>(
    `SELECT scheduled_at, provider_id
     FROM public.appointments
     WHERE facility_id = $1
       AND provider_id = ANY($2::uuid[])
       AND scheduled_at >= $3
       AND scheduled_at < $4
       AND status NOT IN ('cancelled', 'no_show')
       AND deleted_at IS NULL`,
    [facilityId, providerIds, from.toISOString(), to.toISOString()],
  );
  const booked = new Set<string>();
  for (const row of rows.rows) {
    booked.add(`${row.provider_id}:${row.scheduled_at.toISOString()}`);
  }
  return booked;
}

async function loadProvidersForService(
  facilityId: string,
  serviceId: string | undefined,
  profile: FacilityProfileSettings,
): Promise<ProviderRow[]> {
  if (serviceId) {
    const linked = await query<ProviderRow>(
      `SELECT p.id, p.name
       FROM public.facility_service_providers fsp
       JOIN public.providers p ON p.id = fsp.provider_id
       LEFT JOIN public.provider_facility_links pfl
         ON pfl.provider_id = p.id AND pfl.facility_id = fsp.facility_id
       WHERE fsp.facility_id = $1
         AND fsp.service_id = $2
         AND fsp.is_active = true
         AND p.is_active = true
         AND p.deleted_at IS NULL
         AND COALESCE(pfl.is_accepting_bookings, p.is_accepting_bookings) = true
         AND COALESCE(pfl.is_active, p.is_active) = true
       ORDER BY fsp.display_order ASC, p.name ASC`,
      [facilityId, serviceId],
    );
    if (linked.rows.length > 0) return linked.rows;
  }

  const rows = await query<ProviderRow>(
    `SELECT DISTINCT p.id, p.name
     FROM public.providers p
     LEFT JOIN public.provider_facility_links pfl
       ON pfl.provider_id = p.id AND pfl.facility_id = $1
     WHERE (p.facility_id = $1 OR pfl.facility_id = $1)
       AND p.is_active = true
       AND p.deleted_at IS NULL
       AND COALESCE(pfl.is_accepting_bookings, p.is_accepting_bookings) = true
       AND COALESCE(pfl.is_active, p.is_active) = true
     ORDER BY p.name ASC`,
    [facilityId],
  );

  if (!serviceId || profile.services.length === 0) return rows.rows;
  return rows.rows;
}

function serviceName(profile: FacilityProfileSettings, serviceId: string): string {
  return profile.services.find((s) => s.id === serviceId)?.name ?? 'Service';
}

export interface AvailabilitySlot {
  time: string;
  scheduledAt: string;
  serviceId: string | null;
  serviceName: string;
  providerId: string;
  providerName: string;
}

export interface AvailabilityDay {
  label: string;
  date: string;
  slots: AvailabilitySlot[];
}

export async function getFacilityAvailability(
  facilityId: string,
  opts: { serviceId?: string; days?: number },
): Promise<{ days: AvailabilityDay[] }> {
  const facility = await query<{ settings: unknown }>(
    `SELECT settings FROM public.facilities WHERE id = $1 AND deleted_at IS NULL AND is_active = true`,
    [facilityId],
  );
  if (!facility.rows[0]) throw new NotFoundError('Facility', facilityId);

  const profile = parseProfileSettings(
    (facility.rows[0].settings as { profile?: unknown })?.profile,
  );

  if (profile.booking.enabled === false) {
    return { days: [] };
  }

  const dayCount = Math.min(Math.max(opts.days ?? 2, 1), 14);
  const slotSettings = await loadSlotSettings(facilityId);
  const facilityHours = await loadFacilityHours(facilityId);
  const providers = await loadProvidersForService(facilityId, opts.serviceId, profile);

  if (providers.length === 0) return { days: [] };

  const now = harareNow();
  const startDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const endDay = new Date(startDay);
  endDay.setDate(endDay.getDate() + dayCount);

  const booked = await loadBookedSlots(
    facilityId,
    providers.map((p) => p.id),
    startDay,
    endDay,
  );

  const days: AvailabilityDay[] = [];

  for (let offset = 0; offset < dayCount; offset++) {
    const day = new Date(startDay);
    day.setDate(day.getDate() + offset);
    const dow = dayOfWeekHarare(day);
    const facilityWindow = getDayHours(facilityHours, dow);
    const label =
      offset === 0 ? 'Today' : offset === 1 ? 'Tomorrow' : day.toLocaleDateString('en-ZW', { weekday: 'short' });

    const slots: AvailabilitySlot[] = [];

    for (const provider of providers) {
      const providerHours = await loadProviderHours(provider.id);
      const providerWindow = getDayHours(providerHours, dow);
      const window = intersectWindows(facilityWindow, providerWindow);
      if (!window) continue;

      const generated = generateSlotsForWindow(
        window,
        slotSettings.slotDurationMinutes,
        slotSettings.bufferMinutes,
        day,
        now,
      );

      for (const slotAt of generated) {
        const key = `${provider.id}:${slotAt.toISOString()}`;
        if (booked.has(key)) continue;

        const resolvedServiceId = opts.serviceId ?? profile.services[0]?.id ?? null;
        slots.push({
          time: formatTime(slotAt.getHours() * 60 + slotAt.getMinutes()),
          scheduledAt: slotAt.toISOString(),
          serviceId: resolvedServiceId,
          serviceName: resolvedServiceId ? serviceName(profile, resolvedServiceId) : 'Appointment',
          providerId: provider.id,
          providerName: provider.name,
        });
      }
    }

    slots.sort((a, b) => a.time.localeCompare(b.time));

    days.push({
      label,
      date: dateKey(day),
      slots: slots.slice(0, 12),
    });
  }

  return { days: days.filter((d) => d.slots.length > 0) };
}

export async function getNextAvailableSlot(
  facilityId: string,
  providerId: string,
  serviceId?: string,
): Promise<string | null> {
  const result = await getFacilityAvailability(facilityId, {
    serviceId,
    days: 7,
  });

  for (const day of result.days) {
    const match = day.slots.find((s) => s.providerId === providerId);
    if (match) return match.scheduledAt;
  }
  return null;
}

/** True when at least one bookable slot exists in the next [days] days. */
export async function facilityHasBookableSlots(
  facilityId: string,
  days = 14,
): Promise<boolean> {
  const result = await getFacilityAvailability(facilityId, { days });
  return result.days.some((day) => day.slots.length > 0);
}
