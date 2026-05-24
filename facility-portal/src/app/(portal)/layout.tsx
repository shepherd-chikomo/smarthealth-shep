'use client';

import { PortalShell } from '@/components/portal-shell';
import { useFacility } from '@/lib/facility-context';

export default function PortalLayout({ children }: { children: React.ReactNode }) {
  const { facilityId } = useFacility();

  if (!facilityId) {
    return (
      <PortalShell>
        <p className="text-[var(--muted)]">No facility assigned to your account.</p>
      </PortalShell>
    );
  }

  return <PortalShell>{children}</PortalShell>;
}
