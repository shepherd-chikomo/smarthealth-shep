export interface ClaimRecord {
  id: string;
  type: 'facility' | 'provider';
  status: string;
  facilityId?: string;
  facilityName?: string;
  providerId?: string;
  providerName?: string;
  evidence?: Record<string, unknown>;
  businessRegistrationNumber?: string;
  mdpczNumber?: string;
  notes?: string;
  submittedAt?: string;
}

export interface ClaimableFacility {
  id: string;
  name: string;
  city?: string;
  province?: string;
  isClaimed: boolean;
  pendingClaims: number;
}

export interface ClaimableProvider {
  id: string;
  name: string;
  specialty?: string;
  facilityId: string;
  facilityName: string;
  isClaimed: boolean;
  pendingClaims: number;
}

const API_BASE = '/v1';

async function getToken(): Promise<string | null> {
  if (typeof window === 'undefined') return null;
  const { createClient } = await import('./supabase/client');
  const supabase = createClient();
  const { data: { session } } = await supabase.auth.getSession();
  return session?.access_token ?? null;
}

async function claimRequest<T>(path: string, init?: RequestInit): Promise<T> {
  const token = await getToken();
  const headers: Record<string, string> = {
    Accept: 'application/json',
    ...(init?.headers as Record<string, string>),
  };
  if (token) headers.Authorization = `Bearer ${token}`;
  if (init?.body && !headers['Content-Type']) {
    headers['Content-Type'] = 'application/json';
  }

  const res = await fetch(`${API_BASE}${path}`, { ...init, headers });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err?.error?.message ?? `HTTP ${res.status}`);
  }
  return res.json() as Promise<T>;
}

export const claimApi = {
  searchFacilities: (q?: string, page = 1) =>
    claimRequest<{ facilities: ClaimableFacility[] }>(
      `/claims/search/facilities?page=${page}&limit=20${q ? `&q=${encodeURIComponent(q)}` : ''}`,
    ),

  searchProviders: (q?: string, page = 1) =>
    claimRequest<{ providers: ClaimableProvider[] }>(
      `/claims/search/providers?page=${page}&limit=20${q ? `&q=${encodeURIComponent(q)}` : ''}`,
    ),

  myClaims: () =>
    claimRequest<{ facilityClaims: ClaimRecord[]; providerClaims: ClaimRecord[] }>('/claims/me'),

  createFacilityClaim: (body: {
    facilityId: string;
    businessRegistrationNumber?: string;
    notes?: string;
    evidence?: Record<string, unknown>;
  }) =>
    claimRequest<{ claim: ClaimRecord }>('/claims/facility', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  createProviderClaim: (body: {
    providerId: string;
    mdpczNumber?: string;
    notes?: string;
    evidence?: Record<string, unknown>;
  }) =>
    claimRequest<{ claim: ClaimRecord }>('/claims/provider', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  updateFacilityClaim: (
    id: string,
    body: { businessRegistrationNumber?: string; notes?: string; evidence?: Record<string, unknown> },
  ) =>
    claimRequest<{ claim: ClaimRecord }>(`/claims/facility/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(body),
    }),

  submitFacilityClaim: (id: string) =>
    claimRequest<{ claim: ClaimRecord }>(`/claims/facility/${id}/submit`, { method: 'POST' }),

  submitProviderClaim: (id: string) =>
    claimRequest<{ claim: ClaimRecord }>(`/claims/provider/${id}/submit`, { method: 'POST' }),
};
