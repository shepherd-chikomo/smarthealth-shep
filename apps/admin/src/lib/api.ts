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

export interface EmergencyServiceRecord {
  id: string;
  name: string;
  serviceType: string;
  phone: string;
  alternatePhone: string | null;
  address: string | null;
  city: string;
  province: string;
  latitude: number;
  longitude: number;
  is24Hours: boolean;
  isActive: boolean;
}

export interface EmergencyServiceInput {
  name: string;
  serviceType: string;
  phone: string;
  alternatePhone?: string | null;
  address?: string | null;
  city: string;
  province: string;
  latitude: number;
  longitude: number;
  is24Hours?: boolean;
  isActive?: boolean;
}

export interface ProfileConditionRecord {
  id: string;
  slug: string;
  label: string;
  isCommon: boolean;
  sortOrder: number;
  isActive: boolean;
}

export interface ProfileConditionInput {
  label: string;
  isCommon?: boolean;
  sortOrder?: number;
  isActive?: boolean;
}

export interface ConditionSubmissionRecord {
  id: string;
  userId: string;
  familyMemberId: string | null;
  proposedLabel: string;
  proposedSlug: string;
  status: 'pending' | 'approved' | 'rejected';
  reviewedBy: string | null;
  reviewedAt: string | null;
  resultingConditionId: string | null;
  createdAt: string;
  userEmail?: string | null;
}

export interface FacilityServiceRecord {
  id: string;
  slug: string;
  label: string;
  iconKey: string;
  isPreset: boolean;
  sortOrder: number;
  isActive: boolean;
}

export interface FacilityServiceInput {
  label: string;
  iconKey?: string;
  isPreset?: boolean;
  sortOrder?: number;
  isActive?: boolean;
}

export interface ServiceSubmissionRecord {
  id: string;
  facilityId: string;
  submittedBy: string;
  proposedLabel: string;
  proposedSlug: string;
  proposedIconKey: string;
  status: 'pending' | 'approved' | 'rejected';
  reviewedBy: string | null;
  reviewedAt: string | null;
  resultingServiceId: string | null;
  createdAt: string;
  facilityName?: string | null;
}

export interface MedicalAidSchemeRecord {
  id: string;
  schemeKey: string;
  name: string;
  logoPath: string | null;
  sortOrder: number;
  isActive: boolean;
}

export interface MedicalAidSchemeInput {
  name: string;
  schemeKey?: string;
  logoPath?: string;
  sortOrder?: number;
  isActive?: boolean;
}

export interface MedicalAidSubmissionRecord {
  id: string;
  facilityId: string;
  submittedBy: string;
  proposedName: string;
  proposedSchemeKey: string;
  status: 'pending' | 'approved' | 'rejected';
  reviewedBy: string | null;
  reviewedAt: string | null;
  resultingSchemeId: string | null;
  createdAt: string;
  facilityName?: string | null;
}

export interface PlatformBroadcast {
  id: string;
  title: string;
  body: string;
  actionUrl: string | null;
  recipientCount: number;
  createdAt: string;
  createdByEmail: string | null;
}

export interface ImportReviewQueueItem {
  id: string;
  queueType: string;
  facilityId: string | null;
  facilityName: string | null;
  facilityCity?: string | null;
  providerId: string | null;
  providerName: string | null;
  registrationNumber: string | null;
  rowNumber?: number | null;
  rawData?: unknown;
  notes: string | null;
  createdAt?: string | null;
}

export interface AdminFacility {
  id: string;
  name: string;
  address: string | null;
  city: string | null;
  province: string | null;
  isVerified: boolean;
  isClaimed: boolean;
  primaryRoleHolder: string | null;
  linkedProviderCount: number;
  geocodeQuality: string | null;
  geocodedAt: string | null;
  isGeocodedUpToDate: boolean;
  geocodeStatus: 'ok' | 'missing' | 'low_quality';
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

export interface ImportUploadResult {
  batchId: string;
  sourceType: 'MDPCZ' | 'HPA';
  dryRun: boolean;
  created: number;
  failed: number;
  details: Record<string, number>;
}

async function uploadFile<T>(
  path: string,
  file: File,
  retried = false,
): Promise<T> {
  const token = getAccessToken();
  const form = new FormData();
  form.append('file', file);

  const headers: Record<string, string> = {
    Accept: 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };
  if (token) headers.Authorization = `Bearer ${token}`;

  const res = await fetch(`${API_BASE}${path}`, { method: 'POST', body: form, headers });
  if (res.status === 401 && !retried) {
    const refreshed = await refreshAccessToken();
    if (refreshed) return uploadFile<T>(path, file, true);
    clearTokens();
    redirectToLogin();
    throw new Error('Unauthorized');
  }
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err?.error?.message ?? `HTTP ${res.status}`);
  }
  return res.json() as Promise<T>;
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
    request<{ services: EmergencyServiceRecord[]; pagination: PaginationMeta }>(
      `/admin/content/emergency${qs(params)}`,
    ),

  createEmergencyService: (body: EmergencyServiceInput) =>
    request<{ service: EmergencyServiceRecord }>('/admin/content/emergency', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  updateEmergencyService: (id: string, body: Partial<EmergencyServiceInput>) =>
    request<{ service: EmergencyServiceRecord }>(`/admin/content/emergency/${id}`, {
      method: 'PUT',
      body: JSON.stringify(body),
    }),

  deleteEmergencyService: (id: string) =>
    request(`/admin/content/emergency/${id}`, { method: 'DELETE' }),

  profileConditions: (params?: ListParams) =>
    request<{ conditions: ProfileConditionRecord[]; pagination: PaginationMeta }>(
      `/admin/content/conditions${qs(params)}`,
    ),

  createProfileCondition: (body: ProfileConditionInput) =>
    request<{ condition: ProfileConditionRecord }>('/admin/content/conditions', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  updateProfileCondition: (id: string, body: Partial<ProfileConditionInput>) =>
    request<{ condition: ProfileConditionRecord }>(`/admin/content/conditions/${id}`, {
      method: 'PUT',
      body: JSON.stringify(body),
    }),

  deleteProfileCondition: (id: string) =>
    request(`/admin/content/conditions/${id}`, { method: 'DELETE' }),

  conditionSubmissions: (params?: ListParams) =>
    request<{ submissions: ConditionSubmissionRecord[]; pagination: PaginationMeta }>(
      `/admin/content/condition-submissions${qs(params)}`,
    ),

  approveConditionSubmission: (id: string, body: { isCommon?: boolean }) =>
    request<{ submission: ConditionSubmissionRecord; condition: ProfileConditionRecord }>(
      `/admin/content/condition-submissions/${id}/approve`,
      { method: 'POST', body: JSON.stringify(body) },
    ),

  rejectConditionSubmission: (id: string) =>
    request<{ submission: ConditionSubmissionRecord }>(
      `/admin/content/condition-submissions/${id}/reject`,
      { method: 'POST' },
    ),

  facilityServices: (params?: ListParams) =>
    request<{ services: FacilityServiceRecord[]; pagination: PaginationMeta }>(
      `/admin/content/facility-services${qs(params)}`,
    ),

  createFacilityService: (body: FacilityServiceInput) =>
    request<{ service: FacilityServiceRecord }>('/admin/content/facility-services', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  updateFacilityService: (id: string, body: Partial<FacilityServiceInput>) =>
    request<{ service: FacilityServiceRecord }>(`/admin/content/facility-services/${id}`, {
      method: 'PUT',
      body: JSON.stringify(body),
    }),

  deleteFacilityService: (id: string) =>
    request(`/admin/content/facility-services/${id}`, { method: 'DELETE' }),

  serviceSubmissions: (params?: ListParams) =>
    request<{ submissions: ServiceSubmissionRecord[]; pagination: PaginationMeta }>(
      `/admin/content/service-submissions${qs(params)}`,
    ),

  approveServiceSubmission: (id: string, body: { isPreset?: boolean }) =>
    request<{ submission: ServiceSubmissionRecord; service: FacilityServiceRecord }>(
      `/admin/content/service-submissions/${id}/approve`,
      { method: 'POST', body: JSON.stringify(body) },
    ),

  rejectServiceSubmission: (id: string) =>
    request<{ submission: ServiceSubmissionRecord }>(
      `/admin/content/service-submissions/${id}/reject`,
      { method: 'POST' },
    ),

  medicalAidSchemes: (params?: ListParams) =>
    request<{ schemes: MedicalAidSchemeRecord[]; pagination: PaginationMeta }>(
      `/admin/content/medical-aid-schemes${qs(params)}`,
    ),

  createMedicalAidScheme: (body: MedicalAidSchemeInput) =>
    request<{ scheme: MedicalAidSchemeRecord }>('/admin/content/medical-aid-schemes', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  updateMedicalAidScheme: (id: string, body: Partial<MedicalAidSchemeInput>) =>
    request<{ scheme: MedicalAidSchemeRecord }>(`/admin/content/medical-aid-schemes/${id}`, {
      method: 'PUT',
      body: JSON.stringify(body),
    }),

  deleteMedicalAidScheme: (id: string) =>
    request(`/admin/content/medical-aid-schemes/${id}`, { method: 'DELETE' }),

  medicalAidSubmissions: (params?: ListParams) =>
    request<{ submissions: MedicalAidSubmissionRecord[]; pagination: PaginationMeta }>(
      `/admin/content/medical-aid-submissions${qs(params)}`,
    ),

  approveMedicalAidSubmission: (id: string) =>
    request<{ submission: MedicalAidSubmissionRecord; scheme: MedicalAidSchemeRecord }>(
      `/admin/content/medical-aid-submissions/${id}/approve`,
      { method: 'POST' },
    ),

  rejectMedicalAidSubmission: (id: string) =>
    request<{ submission: MedicalAidSubmissionRecord }>(
      `/admin/content/medical-aid-submissions/${id}/reject`,
      { method: 'POST' },
    ),

  broadcastNotification: (body: { title: string; body: string; actionUrl?: string }) =>
    request<{ broadcastId: string; recipientCount: number }>('/admin/notifications/broadcast', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  listBroadcasts: (params?: ListParams) =>
    request<{ broadcasts: PlatformBroadcast[]; pagination: PaginationMeta }>(
      `/admin/notifications/broadcasts${qs(params)}`,
    ),

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

  uploadPractitioners: (file: File, dryRun = false) =>
    uploadFile<ImportUploadResult>(
      `/admin/import/practitioners${dryRun ? '?dryRun=true' : ''}`,
      file,
    ),

  uploadFacilities: (file: File, dryRun = false) =>
    uploadFile<ImportUploadResult>(
      `/admin/import/facilities${dryRun ? '?dryRun=true' : ''}`,
      file,
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
    request<{ facilities: AdminFacility[]; pagination: PaginationMeta }>(`/admin/facilities${qs(params)}`),

  geocodeFacility: (id: string) =>
    request<{ geocoded: boolean; facility: AdminFacility }>(`/admin/facilities/${id}/geocode`, {
      method: 'POST',
    }),

  updateFacilityAddress: (
    id: string,
    body: { name?: string; address?: string; city?: string },
  ) =>
    request<{ facility: AdminFacility }>(`/admin/facilities/${id}/address`, {
      method: 'PATCH',
      body: JSON.stringify(body),
    }),

  importReviewQueue: (params?: ListParams & { queueType?: string }) =>
    request<{ items: ImportReviewQueueItem[]; pagination: PaginationMeta }>(
      `/admin/import-review-queue${qs(params)}`,
    ),

  getImportReviewQueueItem: (id: string) =>
    request<{ item: ImportReviewQueueItem }>(`/admin/import-review-queue/${id}`),

  associatePractitioner: (body: { facilityId: string; providerId: string; queueItemId?: string }) =>
    request('/admin/facilities/associate', { method: 'POST', body: JSON.stringify(body) }),

  resolveAmbiguousFacility: (body: {
    queueItemId: string;
    mode: 'merged' | 'distinct';
    facilityName?: string;
    address?: string;
    city?: string;
    practitionerFirstName?: string;
    practitionerLastName?: string;
  }) =>
    request('/admin/facilities/resolve-ambiguous', { method: 'POST', body: JSON.stringify(body) }),

  resolveUnlinkedPractitioner: (
    id: string,
    body: { action: 'associate' | 'no_link'; facilityId?: string; reason?: string },
  ) =>
    request(`/admin/import-review-queue/${id}/resolve-unlinked`, {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  resolveNoEmailPractitioner: (
    id: string,
    body: { action: 'set_email' | 'manual_claim_only'; email?: string; notes?: string },
  ) =>
    request(`/admin/import-review-queue/${id}/resolve-no-email`, {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  searchProvidersForAssociation: (params?: ListParams) =>
    request<{ providers: Array<{ id: string; name: string; registrationNumber: string | null }> }>(
      `/admin/providers/search-for-association${qs(params)}`,
    ),

  searchFacilitiesForAssociation: (params?: ListParams) =>
    request<{ facilities: Array<{ id: string; name: string; city: string | null; address: string | null }> }>(
      `/admin/facilities/search-for-association${qs(params)}`,
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
      providerName?: string | null;
      mdpczNotes?: string | null;
    }> }>(`/admin/manual-validation${qs(params)}`),

  approveManualValidation: (id: string, body: { claimantId: string; mdpczNotes?: string }) =>
    request(`/admin/manual-validation/${id}/approve`, { method: 'POST', body: JSON.stringify(body) }),

  rejectManualValidation: (id: string, body?: { mdpczNotes?: string }) =>
    request(`/admin/manual-validation/${id}/reject`, { method: 'POST', body: JSON.stringify(body ?? {}) }),
};
