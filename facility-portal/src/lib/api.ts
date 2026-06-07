export interface LinkedFacility {
  id: string;
  name: string;
  city: string | null;
  isClaimed: boolean;
  isVerified: boolean;
  canClaimOwnership: boolean;
  isOwnedByMe?: boolean;
}

export interface ProviderSummary {
  id: string;
  name: string;
  specialty: string | null;
  registrationNumber: string | null;
}

export interface PortalProfile {
  id: string;
  role: string;
  firstName: string | null;
  lastName: string | null;
  email: string | null;
  phone: string | null;
  facilities: { id: string; name: string; role: string; membershipId: string }[];
  linkedFacilities?: LinkedFacility[];
  provider?: ProviderSummary;
  portalMode?: 'provider' | 'facility';
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export interface ListParams {
  page?: number;
  limit?: number;
  q?: string;
  status?: string;
  from?: string;
  to?: string;
  sortOrder?: 'asc' | 'desc';
}

const API_BASE = '/v1';

async function getToken(): Promise<string | null> {
  if (typeof window === 'undefined') return null;
  const { createClient } = await import('./supabase/client');
  const supabase = createClient();
  const { data: { session } } = await supabase.auth.getSession();
  return session?.access_token ?? null;
}

async function request<T>(
  path: string,
  facilityId: string,
  init?: RequestInit,
): Promise<T> {
  const token = await getToken();
  const headers: Record<string, string> = {
    Accept: 'application/json',
    'X-Facility-Id': facilityId,
    ...(init?.headers as Record<string, string>),
  };
  if (token) headers.Authorization = `Bearer ${token}`;
  if (init?.body && !headers['Content-Type']) {
    headers['Content-Type'] = 'application/json';
  }

  const sep = path.includes('?') ? '&' : '?';
  const url = `${API_BASE}${path}${sep}facilityId=${facilityId}`;

  const res = await fetch(url, { ...init, headers });
  if (res.status === 401) {
    if (typeof window !== 'undefined') window.location.href = '/login';
    throw new Error('Unauthorized');
  }
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err?.error?.message ?? `HTTP ${res.status}`);
  }
  const ct = res.headers.get('content-type') ?? '';
  if (ct.includes('text/csv')) return (await res.text()) as T;
  if (ct.includes('application/json')) return res.json() as Promise<T>;
  return (await res.text()) as T;
}

function qs(params?: ListParams): string {
  if (!params) return '';
  const sp = new URLSearchParams();
  Object.entries(params).forEach(([k, v]) => {
    if (v !== undefined && v !== '') sp.set(k, String(v));
  });
  const s = sp.toString();
  return s ? `&${s}` : '';
}

export const api = {
  dashboard: (fid: string) =>
    request<{ stats: Record<string, unknown> }>(`/facility/dashboard`, fid),

  facilityProfile: (fid: string) =>
    request<{ facility: Record<string, unknown>; profileSettings?: Record<string, unknown> }>(
      `/facility/profile`,
      fid,
    ),

  updateFacilityProfile: (fid: string, body: Record<string, unknown>) =>
    request(`/facility/profile`, fid, { method: 'PATCH', body: JSON.stringify(body) }),

  updateProfileSettings: (fid: string, body: Record<string, unknown>) =>
    request(`/facility/profile-settings`, fid, { method: 'PATCH', body: JSON.stringify(body) }),

  medicalAidCatalog: (fid: string) =>
    request<{ schemes: unknown[] }>(`/facility/medical-aid-catalog`, fid),

  servicesCatalog: (fid: string) =>
    request<{
      preset: { id: string; label: string; iconKey: string }[];
      other: { id: string; label: string; iconKey: string }[];
    }>(`/facility/services-catalog`, fid),

  submitServiceProposal: (fid: string, body: { label: string; iconKey?: string }) =>
    request<{ submission: unknown | null; skipped: boolean; reason: string | null }>(
      `/facility/service-submissions`,
      fid,
      { method: 'POST', body: JSON.stringify(body) },
    ),

  submitMedicalAidProposal: (fid: string, body: { name: string }) =>
    request<{ submission: unknown | null; skipped: boolean; reason: string | null }>(
      `/facility/medical-aid-submissions`,
      fid,
      { method: 'POST', body: JSON.stringify(body) },
    ),

  uploadLogo: async (fid: string, file: File) => {
    const token = await getToken();
    const form = new FormData();
    form.append('file', file);
    const res = await fetch(`${API_BASE}/facility/logo?facilityId=${fid}`, {
      method: 'POST',
      headers: token ? { Authorization: `Bearer ${token}` } : {},
      body: form,
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err?.error?.message ?? `HTTP ${res.status}`);
    }
    return res.json();
  },

  removeLogo: (fid: string) => request(`/facility/logo`, fid, { method: 'DELETE' }),

  updateDoctorServices: (fid: string, doctorId: string, serviceIds: string[]) =>
    request(`/facility/doctors/${doctorId}/services`, fid, {
      method: 'PUT',
      body: JSON.stringify({ serviceIds }),
    }),

  doctors: (fid: string, params?: ListParams) =>
    request<{ doctors: unknown[]; pagination: PaginationMeta }>(
      `/facility/doctors${qs(params) ? '?' + qs(params).slice(1) : ''}`,
      fid,
    ),

  createDoctor: (fid: string, body: Record<string, unknown>) =>
    request(`/facility/doctors`, fid, { method: 'POST', body: JSON.stringify(body) }),

  lookupProvider: (fid: string, mdpczNumber: string) =>
    request<{
      found: boolean;
      provider?: {
        id: string;
        name: string;
        specialty: string | null;
        mdpczNumber: string | null;
        phone: string | null;
        email: string | null;
        isActive: boolean;
        alreadyAtFacility: boolean;
      };
    }>(`/facility/doctors/lookup?mdpczNumber=${encodeURIComponent(mdpczNumber)}`, fid),

  attachDoctor: (fid: string, providerId: string) =>
    request<{ id: string; attached: boolean }>(`/facility/doctors/attach`, fid, {
      method: 'POST',
      body: JSON.stringify({ providerId }),
    }),

  updateDoctor: (fid: string, id: string, body: Record<string, unknown>) =>
    request(`/facility/doctors/${id}`, fid, { method: 'PATCH', body: JSON.stringify(body) }),

  hours: (fid: string) => request<{ hours: unknown[] }>(`/facility/hours`, fid),

  updateHours: (fid: string, hours: unknown[]) =>
    request(`/facility/hours`, fid, { method: 'PUT', body: JSON.stringify({ hours }) }),

  availability: (fid: string, providerId?: string) =>
    request<{ availability: unknown[] }>(
      `/facility/availability${providerId ? `?providerId=${providerId}` : ''}`,
      fid,
    ),

  updateAvailability: (fid: string, providerId: string, hours: unknown[]) =>
    request(`/facility/availability/${providerId}`, fid, {
      method: 'PUT',
      body: JSON.stringify({ hours }),
    }),

  slots: (fid: string) => request<{ settings: Record<string, unknown> }>(`/facility/slots`, fid),

  updateSlots: (fid: string, settings: Record<string, unknown>) =>
    request(`/facility/slots`, fid, { method: 'PUT', body: JSON.stringify(settings) }),

  patients: (fid: string, params?: ListParams) =>
    request<{ patients: unknown[]; pagination: PaginationMeta }>(
      `/facility/patients${qs(params) ? '?' + qs(params).slice(1) : ''}`,
      fid,
    ),

  registerPatient: (fid: string, body: Record<string, unknown>) =>
    request(`/facility/patients`, fid, { method: 'POST', body: JSON.stringify(body) }),

  patientHistory: (fid: string, id: string) =>
    request<{ patient: unknown; appointments: unknown[]; walkIns: unknown[] }>(
      `/facility/patients/${id}/history`,
      fid,
    ),

  appointments: (fid: string, params?: ListParams) =>
    request<{ appointments: unknown[]; pagination: PaginationMeta }>(
      `/facility/appointments${qs(params) ? '?' + qs(params).slice(1) : ''}`,
      fid,
    ),

  createAppointment: (fid: string, body: Record<string, unknown>) =>
    request(`/facility/appointments`, fid, { method: 'POST', body: JSON.stringify(body) }),

  rescheduleAppointment: (fid: string, id: string, body: Record<string, unknown>) =>
    request(`/facility/appointments/${id}/reschedule`, fid, {
      method: 'PATCH',
      body: JSON.stringify(body),
    }),

  cancelAppointment: (fid: string, id: string, reason?: string) =>
    request(`/facility/appointments/${id}/cancel`, fid, {
      method: 'PATCH',
      body: JSON.stringify({ reason }),
    }),

  queue: (fid: string, params?: ListParams) =>
    request<{ queue: unknown[]; pagination: PaginationMeta }>(
      `/facility/queue${qs(params) ? '?' + qs(params).slice(1) : ''}`,
      fid,
    ),

  queueStats: (fid: string) =>
    request<{ stats: Record<string, unknown>; paused: boolean }>(`/facility/queue/stats`, fid),

  registerWalkIn: (fid: string, body: Record<string, unknown>) =>
    request(`/facility/queue/walk-in`, fid, { method: 'POST', body: JSON.stringify(body) }),

  updateQueueStatus: (fid: string, id: string, status: string) =>
    request(`/facility/queue/${id}/status`, fid, {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    }),

  delayQueuePatient: (fid: string, id: string, additionalMinutes = 15) =>
    request(`/facility/queue/${id}/delay`, fid, {
      method: 'PATCH',
      body: JSON.stringify({ additionalMinutes }),
    }),

  setQueuePaused: (fid: string, paused: boolean) =>
    request<{ paused: boolean }>(`/facility/queue/pause`, fid, {
      method: 'PUT',
      body: JSON.stringify({ paused }),
    }),

  emergency: (fid: string) =>
    request<{ availability: Record<string, unknown> }>(`/facility/emergency`, fid),

  updateEmergency: (fid: string, body: Record<string, unknown>) =>
    request(`/facility/emergency`, fid, { method: 'PUT', body: JSON.stringify(body) }),

  scheduleOverrides: (fid: string) =>
    request<{ overrides: Record<string, unknown> }>(`/facility/schedule-overrides`, fid),

  updateScheduleOverrides: (fid: string, body: Record<string, unknown>) =>
    request(`/facility/schedule-overrides`, fid, {
      method: 'PUT',
      body: JSON.stringify(body),
    }),

  billing: (fid: string) => request<Record<string, unknown>>(`/facility/billing`, fid),

  inventory: (fid: string, params?: ListParams) =>
    request<{ products: unknown[]; pagination: PaginationMeta }>(
      `/facility/inventory${qs(params) ? '?' + qs(params).slice(1) : ''}`,
      fid,
    ),

  inventoryAlerts: (fid: string) =>
    request<{ alerts: unknown[] }>(`/facility/inventory/alerts`, fid),

  createProduct: (fid: string, body: Record<string, unknown>) =>
    request(`/facility/inventory`, fid, { method: 'POST', body: JSON.stringify(body) }),

  updateProduct: (fid: string, id: string, body: Record<string, unknown>) =>
    request(`/facility/inventory/${id}`, fid, { method: 'PATCH', body: JSON.stringify(body) }),

  adjustStock: (fid: string, id: string, body: Record<string, unknown>) =>
    request(`/facility/inventory/${id}/stock`, fid, { method: 'POST', body: JSON.stringify(body) }),

  staff: (fid: string, params?: ListParams) =>
    request<{ staff: unknown[]; pagination: PaginationMeta }>(
      `/facility/staff${qs(params) ? '?' + qs(params).slice(1) : ''}`,
      fid,
    ),

  addStaff: (fid: string, body: Record<string, unknown>) =>
    request(`/facility/staff`, fid, { method: 'POST', body: JSON.stringify(body) }),

  removeStaff: (fid: string, id: string) =>
    request(`/facility/staff/${id}`, fid, { method: 'DELETE' }),

  invitePractitioner: (fid: string, registrationNumber: string) =>
    request(`/facility/practitioners/invite`, fid, {
      method: 'POST',
      body: JSON.stringify({ registrationNumber }),
    }),

  removePractitioner: (fid: string, providerId: string) =>
    request(`/facility/practitioners/${providerId}`, fid, { method: 'DELETE' }),

  inviteFacilityAdmin: (fid: string, email: string) =>
    request(`/facility/admins/invite`, fid, {
      method: 'POST',
      body: JSON.stringify({ email }),
    }),

  analytics: (fid: string) =>
    request<{ dashboard: Record<string, unknown> }>(`/facility/analytics`, fid),

  exportAnalytics: (fid: string, type: 'daily' | 'providers') =>
    request<string>(`/analytics/facility/export?type=${type}`, fid),

  providerAnalytics: (fid: string, providerId: string) =>
    request<{ dashboard: Record<string, unknown> }>(
      `/analytics/provider?providerId=${providerId}`,
      fid,
    ),

  exportProviderAnalytics: (fid: string, providerId: string) =>
    request<string>(`/analytics/provider/export?providerId=${providerId}`, fid),

  revenueReport: (fid: string, params?: ListParams) =>
    request<{ reports: unknown[]; pagination: PaginationMeta }>(
      `/facility/reports/revenue${qs(params) ? '?' + qs(params).slice(1) : ''}`,
      fid,
    ),

  doctorReport: (fid: string) =>
    request<{ doctors: unknown[] }>(`/facility/reports/doctors`, fid),

  appointmentTrends: (fid: string) =>
    request<{ trends: unknown[] }>(`/facility/reports/appointments`, fid),

  exportReport: (fid: string, type: string) =>
    request<string>(`/facility/reports/export?type=${type}`, fid),
};
