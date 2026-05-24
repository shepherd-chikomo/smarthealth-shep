'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { PortalShell } from '@/components/portal-shell';
import { useFacility } from '@/lib/facility-context';

export default function PortalLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const { facilityId, hasActiveFacility, loading, profile, portalMode } = useFacility();

  const needsProviderPortal =
    portalMode === 'provider' || !hasActiveFacility || !facilityId;

  useEffect(() => {
    if (loading) return;

    if (!profile) {
      router.replace('/login');
      return;
    }

    if (needsProviderPortal) {
      router.replace('/provider/facilities');
    }
  }, [loading, profile, authError, needsProviderPortal, router]);

  useEffect(() => {
    if (loading || !needsProviderPortal) return;

    const timeout = window.setTimeout(() => {
      window.location.assign('/provider/facilities');
    }, 1500);

    return () => window.clearTimeout(timeout);
  }, [loading, needsProviderPortal]);

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center text-[var(--muted)]">
        Loading…
      </div>
    );
  }

  if (needsProviderPortal) {
    return (
      <div className="flex min-h-screen items-center justify-center text-[var(--muted)]">
        Redirecting to your facilities…
      </div>
    );
  }

  return <PortalShell>{children}</PortalShell>;
}
