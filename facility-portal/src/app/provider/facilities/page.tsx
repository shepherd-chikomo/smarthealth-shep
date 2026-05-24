'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FacilityTabPanel, FacilityTabs } from '@/components/facility-tabs';
import { PageHeader } from '@/components/ui';
import { claimApi } from '@/lib/claim-api';
import { refreshAuthSession } from '@/lib/auth-session';
import { useFacility } from '@/lib/facility-context';

export default function ProviderFacilitiesPage() {
  const router = useRouter();
  const { profile, linkedFacilities, refresh, activateFacility, loading } = useFacility();
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [claimingId, setClaimingId] = useState<string | null>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    if (linkedFacilities.length > 0 && !selectedId) {
      setSelectedId(linkedFacilities[0].id);
    }
  }, [linkedFacilities, selectedId]);

  const selected = linkedFacilities.find((f) => f.id === selectedId) ?? null;

  async function claimFacility(id: string) {
    setClaimingId(id);
    setError('');
    try {
      await claimApi.instantClaimFacility(id);
      await refreshAuthSession();
      await refresh();
      setSelectedId(id);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not claim facility');
    } finally {
      setClaimingId(null);
    }
  }

  function manageFacility(id: string) {
    void (async () => {
      await refreshAuthSession();
      const ok = await activateFacility(id);
      if (ok) {
        window.location.assign('/');
      } else {
        setError('Could not open this facility. Claim ownership first or try again.');
      }
    })();
  }

  if (loading) {
    return <p className="text-[var(--muted)]">Loading facilities…</p>;
  }

  if (!profile?.provider) {
    return (
      <div className="card text-center">
        <p className="text-sm text-[var(--muted)]">
          Claim your practitioner profile first to see linked facilities.
        </p>
        <button
          type="button"
          className="btn-primary mt-4"
          onClick={() => router.push('/claim/profile')}
        >
          Claim profile
        </button>
      </div>
    );
  }

  return (
    <div>
      <PageHeader
        title="Your facilities"
        description="Registry-linked sites where you are the HPA role-holder. Claim each facility, then manage it in the facility portal."
      />

      {error && (
        <p className="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">
          {error}
        </p>
      )}

      <div className="card">
        <FacilityTabs
          facilities={linkedFacilities}
          selectedId={selectedId}
          onSelect={setSelectedId}
        />
        <FacilityTabPanel
          facility={selected}
          claimingId={claimingId}
          onClaim={(id) => void claimFacility(id)}
          onManage={manageFacility}
        />
      </div>
    </div>
  );
}
