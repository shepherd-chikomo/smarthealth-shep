'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { createClient } from './supabase/client';
import { refreshAuthSession } from './auth-session';
import type { LinkedFacility, PortalProfile } from './api';

interface FacilityContextValue {
  profile: PortalProfile | null;
  linkedFacilities: LinkedFacility[];
  facilityId: string | null;
  portalMode: 'provider' | 'facility' | null;
  hasActiveFacility: boolean;
  setFacilityId: (id: string) => void;
  loadFacility: (id: string) => boolean;
  activateFacility: (id: string) => Promise<boolean>;
  loading: boolean;
  authError: string | null;
  refresh: () => Promise<PortalProfile | null>;
}

const FacilityContext = createContext<FacilityContextValue | null>(null);

const STORAGE_KEY = 'sh_facility_id';

function applyProfile(
  data: { profile: PortalProfile },
  setProfile: (p: PortalProfile) => void,
  setLinkedFacilities: (f: LinkedFacility[]) => void,
  setFacilityIdState: (id: string | null) => void,
) {
  const p = data.profile;
  setProfile(p);
  setLinkedFacilities(p.linkedFacilities ?? []);

  const membershipIds = new Set(p.facilities.map((f) => f.id));
  if (p.portalMode === 'provider' && membershipIds.size === 0) {
    localStorage.removeItem(STORAGE_KEY);
    setFacilityIdState(null);
    return;
  }

  const stored = localStorage.getItem(STORAGE_KEY);
  const validStored = stored && membershipIds.has(stored) ? stored : null;
  setFacilityIdState(validStored ?? p.facilities[0]?.id ?? null);
}

export function FacilityProvider({ children }: { children: ReactNode }) {
  const [profile, setProfile] = useState<PortalProfile | null>(null);
  const [linkedFacilities, setLinkedFacilities] = useState<LinkedFacility[]>([]);
  const [facilityId, setFacilityIdState] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [authError, setAuthError] = useState<string | null>(null);
  const supabase = createClient();

  async function fetchPortalProfile(accessToken: string): Promise<Response> {
    return fetch('/v1/facility/me', {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
  }

  async function refresh(): Promise<PortalProfile | null> {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session?.access_token) {
      setProfile(null);
      setLinkedFacilities([]);
      setAuthError(null);
      setLoading(false);
      return null;
    }

    try {
      let accessToken = session.access_token;
      let res = await fetchPortalProfile(accessToken);

      if (res.status === 403) {
        const refreshed = await refreshAuthSession();
        if (refreshed) {
          const { data: { session: nextSession } } = await supabase.auth.getSession();
          if (nextSession?.access_token) {
            accessToken = nextSession.access_token;
            res = await fetchPortalProfile(accessToken);
          }
        }
      }

      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        setProfile(null);
        setLinkedFacilities([]);
        setAuthError(
          err?.error?.message ?? 'This account does not have access to the facility portal',
        );
        setLoading(false);
        return null;
      }
      const data = await res.json();
      applyProfile(data, setProfile, setLinkedFacilities, setFacilityIdState);
      setAuthError(null);
      return data.profile as PortalProfile;
    } catch {
      setProfile(null);
      setLinkedFacilities([]);
      setAuthError('Cannot reach the API. Make sure the backend is running on port 3000.');
      return null;
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void refresh();
    const { data: { subscription } } = supabase.auth.onAuthStateChange(() => {
      void refresh();
    });
    return () => subscription.unsubscribe();
  }, []);

  function setFacilityId(id: string) {
    if (profile && !profile.facilities.some((f) => f.id === id)) {
      return;
    }
    localStorage.setItem(STORAGE_KEY, id);
    setFacilityIdState(id);
  }

  function loadFacility(id: string) {
    if (profile && !profile.facilities.some((f) => f.id === id)) {
      return false;
    }
    localStorage.setItem(STORAGE_KEY, id);
    setFacilityIdState(id);
    return true;
  }

  async function activateFacility(id: string): Promise<boolean> {
    const p = await refresh();
    if (!p?.facilities.some((f) => f.id === id)) {
      return false;
    }
    localStorage.setItem(STORAGE_KEY, id);
    setFacilityIdState(id);
    return true;
  }

  const portalMode = profile?.portalMode ?? (profile?.facilities.length ? 'facility' : 'provider');
  const hasActiveFacility = Boolean(
    facilityId && profile?.facilities.some((f) => f.id === facilityId),
  );

  return (
    <FacilityContext.Provider
      value={{
        profile,
        linkedFacilities,
        facilityId,
        portalMode,
        hasActiveFacility,
        setFacilityId,
        loadFacility,
        activateFacility,
        loading,
        authError,
        refresh,
      }}
    >
      {children}
    </FacilityContext.Provider>
  );
}

export function useFacility() {
  const ctx = useContext(FacilityContext);
  if (!ctx) throw new Error('useFacility must be used within FacilityProvider');
  return ctx;
}

export async function getAccessToken(): Promise<string | null> {
  const supabase = createClient();
  const { data: { session } } = await supabase.auth.getSession();
  return session?.access_token ?? null;
}
