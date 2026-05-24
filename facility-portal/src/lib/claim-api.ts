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
  facilityId?: string | null;
  facilityName: string;
  isClaimed: boolean;
  pendingClaims: number;
}

export interface LinkedFacility {
  id: string;
  name: string;
  city: string | null;
  isClaimed: boolean;
  isVerified: boolean;
  canClaimOwnership: boolean;
  isOwnedByMe?: boolean;
}

export interface ProviderLookupResult {
  matched: boolean;
  alreadyClaimed?: boolean;
  ambiguous?: boolean;
  provider?: {
    id: string;
    name: string;
    specialty: string | null;
    registrationNumber: string | null;
  };
  linkedFacilities?: LinkedFacility[];
  providers?: Array<{
    id: string;
    name: string;
    specialty: string | null;
    registrationNumber: string | null;
    isClaimed: boolean;
  }>;
}

export interface PractitionerClaimResult {
  providerId: string;
  providerName: string;
  alreadyClaimed: boolean;
  linkedFacilities: LinkedFacility[];
}

export interface OnboardingStatus {
  phase: 'unclaimed' | 'profile_claimed' | 'has_facilities';
  provider?: {
    id: string;
    name: string;
    specialty: string | null;
  };
  linkedFacilities?: LinkedFacility[];
}

export interface RegistryEmailMatchResult {
  matched: boolean;
  skipDocuments: boolean;
  provider?: {
    id: string;
    name: string;
    specialty?: string | null;
    registrationNumber?: string | null;
  };
  linkedFacilities?: LinkedFacility[];
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

async function publicClaimRequest<T>(path: string): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, { headers: { Accept: 'application/json' } });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err?.error?.message ?? `HTTP ${res.status}`);
  }
  return res.json() as Promise<T>;
}

export const claimApi = {
  lookupProviderByEmail: (email: string) =>
    publicClaimRequest<ProviderLookupResult>(
      `/claims/lookup/provider?email=${encodeURIComponent(email)}`,
    ),

  onboardingStatus: () => claimRequest<OnboardingStatus>('/claims/me/onboarding-status'),

  instantClaimFacility: (facilityId: string) =>
    claimRequest<{
      facility: { id: string; name: string; city: string | null; isClaimed: boolean };
      alreadyClaimed: boolean;
    }>(`/claims/facility/${facilityId}/instant-claim`, { method: 'POST' }),

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

  registryEmailMatch: () =>
    claimRequest<RegistryEmailMatchResult>('/claims/me/registry-email-match'),

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

  validatePractitionerCredentials: (body: {
    registrationNumber: string;
    email: string;
    specialty: string;
  }) =>
    claimRequest<{ providerId: string; providerName: string }>('/claims/practitioner/validate', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  sendPractitionerClaimOtp: (body: {
    registrationNumber: string;
    email: string;
    specialty: string;
  }) =>
    claimRequest<{ sessionId: string; message: string }>('/claims/practitioner/otp/send', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  verifyPractitionerClaimOtp: (body: { sessionId: string; otp: string }) =>
    claimRequest<{ providerId: string; primaryFacilities: ClaimableFacility[] }>(
      '/claims/practitioner/otp/verify',
      { method: 'POST', body: JSON.stringify(body) },
    ),

  submitManualValidation: (body: {
    registrationNumber: string;
    specialty: string;
    submitterName?: string;
    submitterEmail?: string;
    submitterPhone?: string;
    evidence?: Record<string, unknown>;
  }) =>
    claimRequest<{ ticketId: string }>('/claims/practitioner/manual-validation', {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  myPrimaryFacilities: () =>
    claimRequest<{ facilities: LinkedFacility[] }>('/claims/me/primary-facilities'),

  myInvitations: () =>
    claimRequest<{ invitations: Array<{ id: string; facilityName: string; facilityCity?: string }> }>(
      '/claims/invitations',
    ),

  respondToInvitation: (id: string, action: 'accept' | 'decline') =>
    claimRequest<{ status: string }>(`/claims/invitations/${id}/respond`, {
      method: 'POST',
      body: JSON.stringify({ action }),
    }),
};
