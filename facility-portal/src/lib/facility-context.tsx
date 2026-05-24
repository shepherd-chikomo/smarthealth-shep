'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { createClient } from './supabase/client';
import type { PortalProfile } from './api';

interface FacilityContextValue {
  profile: PortalProfile | null;
  facilityId: string | null;
  setFacilityId: (id: string) => void;
  loading: boolean;
  authError: string | null;
  refresh: () => Promise<void>;
}

const FacilityContext = createContext<FacilityContextValue | null>(null);

const STORAGE_KEY = 'sh_facility_id';

export function FacilityProvider({ children }: { children: ReactNode }) {
  const [profile, setProfile] = useState<PortalProfile | null>(null);
  const [facilityId, setFacilityIdState] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [authError, setAuthError] = useState<string | null>(null);
  const supabase = createClient();

  async function refresh() {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session?.access_token) {
      setProfile(null);
      setAuthError(null);
      setLoading(false);
      return;
    }

    try {
      const res = await fetch('/v1/facility/me', {
        headers: { Authorization: `Bearer ${session.access_token}` },
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        setProfile(null);
        setAuthError(
          err?.error?.message ?? 'This account does not have access to the facility portal',
        );
        setLoading(false);
        return;
      }
      const data = await res.json();
      setProfile(data.profile);
      setAuthError(null);

      const stored = localStorage.getItem(STORAGE_KEY);
      const valid = data.profile.facilities.find((f: { id: string }) => f.id === stored);
      setFacilityIdState(valid ? stored : data.profile.facilities[0]?.id ?? null);
    } catch {
      setProfile(null);
      setAuthError('Cannot reach the API. Make sure the backend is running on port 3000.');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    refresh();
    const { data: { subscription } } = supabase.auth.onAuthStateChange(() => {
      refresh();
    });
    return () => subscription.unsubscribe();
  }, []);

  function setFacilityId(id: string) {
    localStorage.setItem(STORAGE_KEY, id);
    setFacilityIdState(id);
  }

  return (
    <FacilityContext.Provider value={{ profile, facilityId, setFacilityId, loading, authError, refresh }}>
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
