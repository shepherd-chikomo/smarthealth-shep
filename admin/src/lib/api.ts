export interface PlatformAdmin {
  id: string;
  firstName: string | null;
  lastName: string | null;
  email: string | null;
  phone: string | null;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export type OtpContext = 'staff' | 'mobile' | 'recovery';
export type OtpChannel = 'email' | 'phone';

export interface OtpSendRequest {
  context?: OtpContext;
  email?: string;
  phone?: string;
  channel?: OtpChannel;
}

export interface OtpVerifyRequest {
  context?: OtpContext;
  email?: string;
  phone?: string;
  otp: string;
  channel: OtpChannel;
}

export interface OtpSendResponse {
  message: string;
  channel: 'email' | 'sms';
  destination: string;
}

export interface AdminProfile {
  id: string;
  role: string;
  firstName: string | null;
  lastName: string | null;
  email: string | null;
  phone: string | null;
  facilities: { id: string; name: string; role: string }[];
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export interface AuditLogEntry {
  id: string;
  source: string;
  userId: string | null;
  facilityId: string | null;
  category: string;
  actionType: string;
  entityType: string | null;
  entityId: string | null;
  outcome: string;
  ipAddress: string | null;
  userAgent: string | null;
  details: Record<string, unknown>;
  createdAt: string;
}

export interface ListParams {
  page?: number;
  limit?: number;
  q?: string;
  status?: string;
  facilityId?: string;
  category?: string;
  actionType?: string;
  userId?: string;
  entityType?: string;
  outcome?: string;
  from?: string;
  to?: string;
}

const API_BASE = import.meta.env.VITE_API_BASE ?? '/v1';

import {
  clearTokens,
  getAccessToken,
  getRefreshToken,
  setTokens,
} from './token-storage';
import { redirectToLogin } from './paths';

export { setTokens as setToken, clearTokens, getAccessToken as getToken } from './token-storage';

async function refreshAccessToken(): Promise<boolean> {
  const refreshToken = getRefreshToken();
  if (!refreshToken) return false;
  try {
    const res = await fetch(`${API_BASE}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });
    if (!res.ok) return false;
    const data = (await res.json()) as { accessToken: string; refreshToken: string };
    setTokens(data.accessToken, data.refreshToken);
    return true;
  } catch {
    return false;
  }
}

async function request<T>(path: string, init?: RequestInit, retried = false): Promise<T> {
  const token = getAccessToken();
  const headers: Record<string, string> = {
    Accept: 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
    ...(init?.headers as Record<string, string>),
  };
  if (token) headers.Authorization = `Bearer ${token}`;
  if (init?.body && !headers['Content-Type']) {
    headers['Content-Type'] = 'application/json';
  }

  const res = await fetch(`${API_BASE}${path}`, { ...init, headers });
  if (res.status === 401 && !retried) {
    const refreshed = await refreshAccessToken();
    if (refreshed) return request<T>(path, init, true);
    clearTokens();
    redirectToLogin();
    throw new Error('Unauthorized');
  }
  if (res.status === 401) {
    clearTokens();
    redirectToLogin();
    throw new Error('Unauthorized');
  }
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err?.error?.message ?? `HTTP ${res.status}`);
  }
  const ct = res.headers.get('content-type') ?? '';
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
  return s ? `?${s}` : '';
}

export const api = {
  sendOtp: (body: OtpSendRequest) =>
    request<OtpSendResponse>('/auth/otp/send', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  login: (body: OtpVerifyRequest) =>
    request<{ accessToken: string; refreshToken: string; expiresIn: number }>(
      '/auth/otp/verify',
      {
        method: 'POST',
        body: JSON.stringify(body),
      },
    ),

  me: () => request<{ profile: AdminProfile }>('/admin/me'),

  dashboardStats: () => request<{ stats: Record<string, unknown> }>('/admin/dashboard/stats'),

  facilityAdmins: (params?: ListParams) =>
    request<{ admins: unknown[]; pagination: PaginationMeta }>(`/admin/facility-admins${qs(params)}`),

  createFacilityAdmin: (body: { userId: string; facilityId: string }) =>
    request('/admin/facility-admins', { method: 'POST', body: JSON.stringify(body) }),

  deleteFacilityAdmin: (id: string) =>
    request(`/admin/facility-admins/${id}`, { method: 'DELETE' }),

  platformAdmins: (params?: ListParams) =>
    request<{ admins: PlatformAdmin[]; pagination: PaginationMeta }>(
      `/admin/platform-admins${qs(params)}`,
    ),

  promotePlatformAdmin: (body: {
    userId?: string;
    phone?: string;
    email?: string;
    firstName?: string;
    lastName?: string;
  }) =>
    request<{ id: string }>('/admin/platform-admins', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  revokePlatformAdmin: (userId: string) =>
    request(`/admin/platform-admins/${userId}`, { method: 'DELETE' }),

  liveQueue: (params?: ListParams) =>
    request<{ queue: unknown[]; pagination: PaginationMeta }>(`/admin/queue/live${qs(params)}`),

  queueStats: () => request<{ stats: Record<string, unknown> }>('/admin/queue/stats'),

  moderateQueue: (id: string, body: { action: string; reason?: string; priority?: number }) =>
    request(`/admin/queue/${id}/moderate`, { method: 'POST', body: JSON.stringify(body) }),

  providers: (params?: ListParams) =>
    request<{ providers: unknown[]; pagination: PaginationMeta }>(`/admin/providers${qs(params)}`),

  updateProvider: (
    id: string,
    body: {
      title?: string | null;
      firstName?: string;
      lastName?: string;
      specialty?: string | null;
      email?: string | null;
      phone?: string | null;
      gender?: 'male' | 'female' | 'other' | null;
      qualification?: string | null;
      registrationNumber?: string | null;
    },
  ) =>
    request(`/admin/providers/${id}`, { method: 'PATCH', body: JSON.stringify(body) }),

  verifyProvider: (id: string, verified: boolean) =>
    request(`/admin/providers/${id}/verify`, { method: 'PATCH', body: JSON.stringify({ verified }) }),

  suspendProvider: (id: string, suspended: boolean, reason?: string) =>
    request(`/admin/providers/${id}/suspend`, {
      method: 'PATCH',
      body: JSON.stringify({ suspended, reason }),
    }),

  specialties: (params?: ListParams) =>
    request<{ specialties: unknown[]; pagination: PaginationMeta }>(`/admin/specialties${qs(params)}`),

  appointments: (params?: ListParams) =>
    request<{ appointments: unknown[]; pagination: PaginationMeta }>(`/admin/appointments${qs(params)}`),

  appointmentAnalytics: () =>
    request<{ series: unknown[] }>('/admin/appointments/analytics'),

  hours: () => request<{ hours: unknown[] }>('/admin/hours'),

  saveHours: (body: Record<string, unknown>) =>
    request('/admin/hours', { method: 'PUT', body: JSON.stringify(body) }),

  emergencyServices: (params?: ListParams) =>
    request<{ services: unknown[]; pagination: PaginationMeta }>(`/admin/content/emergency${qs(params)}`),

  settings: (scope: string) =>
    request<{ settings: unknown[] }>(`/admin/content/settings/${scope}`),

  saveSetting: (body: Record<string, unknown>) =>
    request('/admin/content/settings', { method: 'PUT', body: JSON.stringify(body) }),

  revenueReports: (params?: ListParams) =>
    request<{ reports: unknown[]; pagination: PaginationMeta }>(`/admin/reports/revenue${qs(params)}`),

  exportCsv: (type: string) =>
    request<string>(`/admin/reports/export/${type}`, { headers: { Accept: 'text/csv' } }),

  rowChangeLogs: (params?: ListParams) =>
    request<{ logs: unknown[]; pagination: PaginationMeta }>(`/admin/security/audit-logs${qs(params)}`),

  auditLogs: (params?: ListParams) =>
    request<{ logs: AuditLogEntry[]; pagination: PaginationMeta }>(`/admin/audit${qs(params)}`),

  securityEvents: (params?: ListParams) =>
    request<{ events: unknown[]; pagination: PaginationMeta }>(`/admin/security/events${qs(params)}`),

  medicalAccessLogs: (params?: ListParams) =>
    request<{ logs: unknown[]; pagination: PaginationMeta }>(
      `/admin/security/medical-access-logs${qs(params)}`,
    ),

  auditSummary: (facilityId?: string) =>
    request<{ last24Hours: { category: string; total: number; denied: number }[] }>(
      `/admin/audit/summary${facilityId ? `?facilityId=${facilityId}` : ''}`,
    ),

  exportAuditLogs: async (params?: ListParams) => {
    const token = getAccessToken();
    const res = await fetch(`${API_BASE}/admin/audit/export${qs(params)}`, {
      headers: { Accept: 'text/csv', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    });
    if (!res.ok) throw new Error('Export failed');
    return res.text();
  },

  platformAnalytics: () =>
    request<{ dashboard: Record<string, unknown> }>('/analytics/platform'),

  exportPlatformAnalytics: (type: 'dau' | 'facilities') =>
    request<string>(`/analytics/platform/export?type=${type}`, { headers: { Accept: 'text/csv' } }),

  claims: (params?: ListParams) =>
    request<{
      facilityClaims: unknown[];
      providerClaims: unknown[];
      pagination: PaginationMeta;
    }>(`/admin/claims${qs(params)}`),

  reviewClaim: (
    type: 'facility' | 'provider',
    id: string,
    action: 'approve' | 'reject',
    reviewNotes?: string,
  ) =>
    request(`/admin/claims/${type}/${id}/review`, {
      method: 'POST',
      body: JSON.stringify({ action, reviewNotes }),
    }),

  claimHistory: (type: 'facility' | 'provider', entityId: string) =>
    request<{ history: unknown[] }>(`/admin/claims/${type}/${entityId}/history`),

  claimDuplicates: (type: 'facility' | 'provider', entityId: string) =>
    request<{ pendingCount: number; claimantIds: string[]; isDuplicate: boolean }>(
      `/admin/claims/${type}/${entityId}/duplicates`,
    ),

  importBatches: (params?: ListParams) =>
    request<{ batches: unknown[]; pagination: PaginationMeta }>(`/admin/import/batches${qs(params)}`),

  importBatch: (id: string) =>
    request<{ batch: unknown }>(`/admin/import/batches/${id}`),

  importFailures: (params?: ListParams & { batchId?: string }) =>
    request<{ failures: unknown[]; pagination: PaginationMeta }>(`/admin/import/failures${qs(params)}`),

  resolveImportFailure: (id: string, notes?: string) =>
    request(`/admin/import/failures/${id}/resolve`, {
      method: 'POST',
      body: JSON.stringify({ notes }),
    }),

  importDuplicates: (params?: ListParams) =>
    request<{ reviews: unknown[]; pagination: PaginationMeta }>(`/admin/import/duplicates${qs(params)}`),

  reviewImportDuplicate: (id: string, action: 'approve' | 'reject') =>
    request(`/admin/import/duplicates/${id}/review`, {
      method: 'POST',
      body: JSON.stringify({ action }),
    }),

  importUnmatchedSpecialties: (params?: ListParams) =>
    request<{ specialties: unknown[]; pagination: PaginationMeta }>(
      `/admin/import/unmatched-specialties${qs(params)}`,
    ),

  mapImportSpecialty: (id: string, specialtyId: string) =>
    request(`/admin/import/unmatched-specialties/${id}/map`, {
      method: 'POST',
      body: JSON.stringify({ specialtyId }),
    }),

  verifyImportedProvider: (id: string, verified: boolean) =>
    request(`/admin/import/providers/${id}/verify`, {
      method: 'POST',
      body: JSON.stringify({ verified }),
    }),

  adminFacilities: (params?: ListParams & { queue?: string }) =>
    request<{ facilities: Array<{
      id: string;
      name: string;
      address: string | null;
      city: string | null;
      isVerified: boolean;
      isClaimed: boolean;
      primaryRoleHolder: string | null;
      linkedProviderCount: number;
    }>; pagination: PaginationMeta }>(`/admin/facilities${qs(params)}`),

  importReviewQueue: (params?: ListParams & { queueType?: string }) =>
    request<{ items: Array<{
      id: string;
      queueType: string;
      facilityId: string | null;
      facilityName: string | null;
      providerId: string | null;
      providerName: string | null;
      registrationNumber: string | null;
      notes: string | null;
    }>; pagination: PaginationMeta }>(`/admin/import-review-queue${qs(params)}`),

  associatePractitioner: (body: { facilityId: string; providerId: string; queueItemId?: string }) =>
    request('/admin/facilities/associate', { method: 'POST', body: JSON.stringify(body) }),

  searchProvidersForAssociation: (params?: ListParams) =>
    request<{ providers: Array<{ id: string; name: string; registrationNumber: string | null }> }>(
      `/admin/providers/search-for-association${qs(params)}`,
    ),

  registryDiffRuns: (params?: ListParams) =>
    request<{ runs: Array<{
      id: string;
      sourceType: string;
      sourceFile: string;
      status: string;
      addedCount: number;
      updatedCount: number;
      removedCount: number;
      startedAt: string;
    }>; pagination: PaginationMeta }>(`/admin/registry-changes${qs(params)}`),

  registryDiffItems: (runId: string, params?: ListParams & { status?: string }) =>
    request<{ items: Array<{
      id: string;
      entityType: string;
      changeType: string;
      stableKey: string;
      fieldChanges: Record<string, { old: string; new: string }>;
      status: string;
    }>; pagination: PaginationMeta }>(`/admin/registry-changes/${runId}/items${qs(params)}`),

  reviewRegistryDiffItem: (id: string, action: 'approve' | 'ignore', reviewNotes?: string) =>
    request(`/admin/registry-changes/items/${id}/review`, {
      method: 'POST',
      body: JSON.stringify({ action, reviewNotes }),
    }),

  manualValidationTickets: (params?: ListParams & { status?: string }) =>
    request<{ tickets: Array<{
      id: string;
      registrationNumber: string;
      specialty: string | null;
      submitterName: string | null;
      submitterEmail: string | null;
      status: string;
    }> }>(`/admin/manual-validation${qs(params)}`),
};
